library dart_oss_licenses;

import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

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

Future<Map<String, dynamic>> generateLicenseInfo({required String pubspecLockPath}) async {
  final pubCacheDir = guessPubCacheDir();
  if (pubCacheDir == null) {
    throw "could not find pub cache directory";
  }
  if (flutterDir == null) {
    throw "flutter root not found";
  }
  final pubspecLock = await File(pubspecLockPath).readAsString();
  final pubspec = loadYaml(pubspecLock);
  final packages = pubspec['packages'] as Map;

  final json = <String, dynamic>{};

  for (final node in packages.keys) {
    final package = await Package.fromMap(
      outerName: node,
      packageJson: packages[node],
      pubCacheDirPath: pubCacheDir,
      flutterDir: flutterDir!,
      pubspecLockPath: pubspecLockPath,
    );

    if (package == null || package.name == null) {
      continue;
    }

    json[package.name!] = {
      'name': package.name,
      'description': package.description,
      'homepage': package.homepage,
      'repository': package.repository,
      'authors': package.authors,
      'version': package.version,
      'license': package.license,
      'isMarkdown': package.isMarkdown,
      'isSdk': package.isSdk,
      'isDirectDependency': package.isDirectDependency
    };
  }
  return json;
}
