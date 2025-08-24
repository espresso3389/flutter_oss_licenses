import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'package.dart';

final flutterDir = Platform.environment['FLUTTER_ROOT'];
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

String findPubspecLockFromDirectory(Directory from) {
  final pubspecLockPath = path.join(from.path, 'pubspec.lock');
  if (File(pubspecLockPath).existsSync()) {
    return pubspecLockPath;
  }
  return findPubspecLockFromDirectory(from.parent);
}

String findPubspecLock(String pubspecYamlPath) {
  return findPubspecLockFromDirectory(Directory(path.dirname(pubspecYamlPath)));
}

Future<ProjectStructure> listDependencies({required String pubspecYamlPath, List<String> ignore = const []}) async {
  final pubCacheDir = guessPubCacheDir();
  if (pubCacheDir == null) {
    throw "could not find pub cache directory";
  }

  final myPackage = await Package.fromDirectory(projectRoot: Directory(path.dirname(pubspecYamlPath)));
  if (myPackage == null) {
    throw "could not load package from $pubspecYamlPath";
  }

  final pubspecLockPath = findPubspecLock(pubspecYamlPath);
  final pubspecLock = loadYaml(await File(pubspecLockPath).readAsString());
  final packages = pubspecLock['packages'] as YamlMap;

  final loadedPackages = await Future.wait(
    packages.keys
        .where((key) => !ignore.contains(key))
        .map(
          (package) => Package.fromPubspecLockPackageEntry(
            outerName: package,
            package: packages[package],
            pubCacheDirPath: pubCacheDir,
            flutterDir: flutterDir,
            basePubspecYamlPath: pubspecYamlPath,
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

  return ProjectStructure(
    package: myPackage,
    allDependencies: packagesByName.values.toList(),
    pubspecLockPath: pubspecLockPath,
  );
}
