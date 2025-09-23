import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'limit_concurrency.dart';
import 'package.dart';

/// The Flutter SDK root directory path from `FLUTTER_ROOT` environment variable.
final flutterDir = Platform.environment['FLUTTER_ROOT'];

/// Attempts to guess the location of the pub cache directory.
///
/// Checks in the following order:
/// 1. `PUB_CACHE` environment variable
/// 2. Platform-specific default locations:
///    - Windows: `%APPDATA%/Pub/Cache` or `%LOCALAPPDATA%/Pub/Cache`
///    - Other: `$HOME/.pub-cache`
///
/// Returns the path to the pub cache directory, or null if not found.
String? guessPubCacheDir() {
  var pubCache = Platform.environment['PUB_CACHE'];
  if (pubCache != null && Directory(pubCache).existsSync()) return pubCache;

  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null) {
      pubCache = path.join(appData, 'Pub', 'Cache');
      if (Directory(pubCache).existsSync()) return pubCache;
    }
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null) {
      pubCache = path.join(localAppData, 'Pub', 'Cache');
      if (Directory(pubCache).existsSync()) return pubCache;
    }
  }

  final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (homeDir != null) {
    return path.join(homeDir, '.pub-cache');
  }
  return null;
}

/// Finds the `pubspec.lock` file by traversing up the directory tree.
///
/// Starts from [from] directory and searches for `pubspec.lock`,
/// moving up to parent directories until found.
///
/// Returns the path to the `pubspec.lock` file.
///
/// Throws if `pubspec.lock` is not found in the directory hierarchy.
String findPubspecLockFromDirectory(Directory from) {
  final pubspecLockPath = path.join(from.path, 'pubspec.lock');
  if (File(pubspecLockPath).existsSync()) {
    return pubspecLockPath;
  }
  return findPubspecLockFromDirectory(from.absolute.parent);
}

/// Finds the `pubspec.lock` file for a given pubspec.yaml path.
///
/// Searches for `pubspec.lock` starting from the directory containing
/// the specified [pubspecYamlPath].
///
/// Returns the path to the `pubspec.lock` file.
String findPubspecLock(String pubspecYamlPath) {
  return findPubspecLockFromDirectory(Directory(path.dirname(pubspecYamlPath)));
}

/// Lists all dependencies for a project including transitive dependencies.
///
/// Analyzes the project at [pubspecYamlPath] and extracts license information
/// for all dependencies defined in `pubspec.lock`.
///
/// The [ignore] parameter allows excluding specific packages by name.
///
/// The [generateDevDependencies] flag indicates whether to include dev dependencies.
///
/// The [maxConcurrency] parameter limits the number of concurrent package loading operations.
///
/// Returns a [ProjectStructure] containing the main package and all dependencies.
///
/// Throws if:
/// - The pub cache directory cannot be found
/// - The package cannot be loaded from the specified path
Future<ProjectStructure> listDependencies({
  required String pubspecYamlPath,
  List<String> ignore = const [],
  bool generateDevDependencies = true,
  int maxConcurrency = 10,
}) async {
  final pubCacheDir = guessPubCacheDir();
  if (pubCacheDir == null) {
    throw 'could not find pub cache directory';
  }

  final myPackage = await Package.fromDirectory(projectRoot: Directory(path.dirname(pubspecYamlPath)));
  if (myPackage == null) {
    throw 'could not load package from $pubspecYamlPath';
  }

  final pubspecLockPath = findPubspecLock(pubspecYamlPath);
  final pubspecLock = loadYaml(await File(pubspecLockPath).readAsString());
  final packages = pubspecLock['packages'] as YamlMap;

  final limitConcurrency = LimitConcurrency(maxConcurrency);
  final loadedPackages = await Future.wait(
    packages.keys
        .where((key) => !ignore.contains(key))
        .map(
          (package) => limitConcurrency.run(
            () => Package.fromPubspecLockPackageEntry(
              outerName: package,
              package: packages[package],
              pubCacheDirPath: pubCacheDir,
              flutterDir: flutterDir,
              basePubspecYamlPath: pubspecYamlPath,
            ),
          ),
        ),
  );

  final packagesByName = Map.fromEntries(loadedPackages.where((p) => p != null).map((p) => MapEntry(p!.name, p)));

  final rootDirectory = Directory(path.dirname(pubspecLockPath));
  final rootPubspecYamlFile = File(path.join(rootDirectory.path, 'pubspec.yaml'));
  if (rootPubspecYamlFile.existsSync()) {
    final rootPubspecYaml = loadYaml(await rootPubspecYamlFile.readAsString());
    final workspace = rootPubspecYaml['workspace'] as YamlList?;
    if (workspace != null) {
      for (final entry in workspace.whereType<String>()) {
        final package = await Package.fromDirectory(
          projectRoot: Directory(path.join(rootDirectory.path, entry)),
          flutterDir: flutterDir,
        );
        if (package != null && !ignore.contains(package.name)) {
          packagesByName[package.name] = package;
        }
      }
    }
  }

  for (final package in packagesByName.values) {
    package.updateDependencies(packagesByName);
  }

  myPackage.updateDependencies(packagesByName);
  packagesByName.putIfAbsent(myPackage.name, () => myPackage);

  return ProjectStructure(
    package: myPackage,
    allDependencies: packagesByName.values.toList(),
    pubspecLockPath: pubspecLockPath,
  );
}
