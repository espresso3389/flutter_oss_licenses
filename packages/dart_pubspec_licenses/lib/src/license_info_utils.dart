library dart_oss_licenses;

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

Future<AllProjectDependencies> listDependencies({
  required String pubspecLockPath,
  List<String> ignore = const [],
}) async {
  final pubCacheDir = guessPubCacheDir();
  if (pubCacheDir == null) {
    throw "could not find pub cache directory";
  }
  final pubspecLock = await File(pubspecLockPath).readAsString();
  final pubspec = loadYaml(pubspecLock);
  final packages = pubspec['packages'] as YamlMap;

  final loadedPackages = await Future.wait(
    packages.keys.where((key) => !ignore.contains(key)).map(
          (package) => Package.fromMap(
            outerName: package,
            packageJson: packages[package],
            pubCacheDirPath: pubCacheDir,
            flutterDir: flutterDir,
            pubspecLockPath: pubspecLockPath,
          ),
        ),
  );

  final packagesByName = Map.fromEntries(loadedPackages.where((p) => p != null).map((p) => MapEntry(p!.name, p)));
  final allDeps = packages.entries.fold<Map<String, List<Package>>>({}, (map, e) {
    final package = packagesByName[e.key];
    if (package != null) {
      map.putIfAbsent(e.value['dependency'], () => []).add(package);
    }
    return map;
  });

  final projectDependencies = AllProjectDependencies(
    dependencies: [],
    devDependencies: [],
    allDependencies: packagesByName.values.toList(),
  );
  final processed = <String>{};
  await _createDependencies(
      processed, projectDependencies, packagesByName, allDeps['direct main'], allDeps['direct dev'], null);
  return projectDependencies;
}

Future<void> _createDependencies(
  Set<String> processed,
  ProjectDependencies projectDependencies,
  Map<String, Package> packagesByName,
  List<Package>? dependencies,
  List<Package>? devDependencies,
  String? pubspecYamlPath,
) async {
  if (projectDependencies is Package) {
    if (processed.contains(projectDependencies.name)) {
      return;
    }
    processed.add(projectDependencies.name);
  }

  if (dependencies == null || devDependencies == null) {
    assert(pubspecYamlPath != null);
    final pubspecLock = await File(pubspecYamlPath!).readAsString();
    final pubspec = loadYaml(pubspecLock);
    final dep = pubspec['dependencies'];
    dependencies ??=
        dep is YamlMap ? dep.keys.map((e) => packagesByName[e]).where((p) => p != null).cast<Package>().toList() : [];
    if (projectDependencies is AllProjectDependencies) {
      final devDep = pubspec['dev_dependencies'];
      devDependencies ??= devDep is YamlMap
          ? devDep.keys.map((e) => packagesByName[e]).where((p) => p != null).cast<Package>().toList()
          : [];
    }
  }

  for (final dep in dependencies) {
    await _createDependencies(processed, dep, packagesByName, null, null, dep.pubspecYamlPath);
  }
  projectDependencies.dependencies.addAll(dependencies);
  if (projectDependencies is AllProjectDependencies) {
    for (final dep in devDependencies!) {
      await _createDependencies(processed, dep, packagesByName, null, null, dep.pubspecYamlPath);
    }
    projectDependencies.devDependencies.addAll(devDependencies);
  }
}
