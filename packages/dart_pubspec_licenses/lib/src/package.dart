import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:yaml/yaml.dart';

class Package {
  final Directory? directory;
  final Map? packageYaml;
  final String? name;
  final String? description;
  final String? homepage;
  final String? repository;
  final List<String>? authors;
  final String? version;
  final String? license;
  final bool? isMarkdown;
  final bool? isSdk;
  final bool? isDirectDependency;

  Package({
    this.directory,
    this.packageYaml,
    this.name,
    this.description,
    this.homepage,
    this.repository,
    this.authors,
    this.version,
    this.license,
    this.isMarkdown,
    this.isSdk,
    this.isDirectDependency,
  });

  static Future<Package?> fromMap({
    required String outerName,
    required Map packageJson,
    required String pubCacheDirPath,
    required String? flutterDir,
    required String pubspecLockPath,
  }) async {
    Directory directory;
    bool isSdk = false;
    final source = packageJson['source'];
    final description = packageJson['description'];
    if (source == 'hosted') {
      final host = removePrefix(description['url']);
      final name = description['name'];
      final version = packageJson['version'];
      directory = Directory(path.join(pubCacheDirPath, 'hosted/$host/$name-$version'));
    } else if (source == 'git') {
      final repo = gitRepoName(description['url']);
      final commit = description['resolved-ref'];
      directory = Directory(path.join(pubCacheDirPath, 'git/$repo-$commit', description['path']));
    } else if (source == 'sdk' && flutterDir != null) {
      directory = Directory(path.join(flutterDir, 'packages', outerName));
      isSdk = true;
    } else if (source == 'path') {
      directory = Directory(path.absolute(path.dirname(pubspecLockPath), description['path']));
      isSdk = true;
    } else {
      return null;
    }
    final isDirectDependency = packageJson['dependency'] == "direct main";

    String? license;
    bool isMarkdown = false;
    if (outerName == 'flutter' && flutterDir != null) {
      license = await File(path.join(flutterDir, 'LICENSE')).readAsString();
    } else {
      String licensePath = path.join(directory.path, 'LICENSE');
      try {
        license = await File(licensePath).readAsString();
      } catch (e) {
        if (await File(licensePath + '.md').exists()) {
          license = await File(licensePath + '.md').readAsString();
          isMarkdown = true;
        }
      }
    }

    if (license == null || license == '') {
      license = "no license found";
    }

    dynamic yaml;
    try {
      yaml = loadYaml(await File(path.join(directory.path, 'pubspec.yaml')).readAsString());
    } catch (e) {
      // yaml may not be there
      yaml = {};
    }

    if (yaml['description'] == null) {
      return null;
    }

    String? version = yaml['version'];
    if (outerName == 'flutter' && flutterDir != null) {
      version = await File(path.join(flutterDir, 'version')).readAsString();
    }
    if (version == null) {
      return null;
    }

    return Package(
        directory: directory,
        packageYaml: yaml,
        name: yaml['name'],
        description: yaml['description'],
        homepage: yaml['homepage'],
        repository: yaml['repository'],
        authors: yaml['authors']?.cast<String>()?.toList() ?? (yaml['author'] != null ? [yaml['author']] : []),
        version: version.trim(),
        license: license.trim().replaceAll('\r\n', '\n'),
        isMarkdown: isMarkdown,
        isSdk: isSdk,
        isDirectDependency: isDirectDependency);
  }
}

String removePrefix(String url) {
  if (url.startsWith('https://')) return url.substring(8);
  if (url.startsWith('http://')) return url.substring(7); // are there any?
  return url;
}

String gitRepoName(String url) {
  final name = url.substring(url.lastIndexOf('/') + 1);
  return name.endsWith('.git') ? name.substring(0, name.length - 4) : name;
}
