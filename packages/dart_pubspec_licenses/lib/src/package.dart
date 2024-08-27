import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class ProjectDependencies {
  // Direct dependencies
  final List<Package> dependencies;

  const ProjectDependencies({
    required this.dependencies,
  });
}

class AllProjectDependencies extends ProjectDependencies {
  // Direct devDependencies
  final List<Package> devDependencies;

  /// All dependencies, including transitive dependencies
  final List<Package> allDependencies;

  const AllProjectDependencies(
      {required super.dependencies, required this.devDependencies, required this.allDependencies});
}

class Package extends ProjectDependencies {
  final Directory? directory;
  final Map? packageYaml;
  final String name;
  final String description;
  final String? homepage;
  final String? repository;
  final List<String> authors;
  final String version;
  final String? license;
  final bool isMarkdown;
  final bool isSdk;

  const Package({
    this.directory,
    this.packageYaml,
    required this.name,
    required this.description,
    this.homepage,
    this.repository,
    required this.authors,
    required this.version,
    this.license,
    required this.isMarkdown,
    required this.isSdk,
    required super.dependencies,
  });

  String? get pubspecYamlPath => getFilePath('pubspec.yaml');
  String? get pubspecLockPath => getFilePath('pubspec.lock');

  String? getFilePath(String name) => directory != null ? path.join(directory!.path, name) : null;

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        name: json['name'] as String,
        description: json['description'] as String,
        homepage: json['homepage'] as String?,
        repository: json['repository'] as String?,
        authors: (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
        version: json['version'] as String,
        license: json['license'] as String?,
        isMarkdown: json['isMarkdown'] as bool,
        isSdk: json['isSdk'] as bool,
        dependencies: [],
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'homepage': homepage,
        'repository': repository,
        'authors': authors,
        'version': version,
        'license': license,
        'isMarkdown': isMarkdown,
        'isSdk': isSdk,
      };

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
    final desc = packageJson['description'];
    if (source == 'hosted') {
      final host = removePrefix(desc['url']);
      final name = desc['name'];
      final version = packageJson['version'];
      directory = Directory(path.join(pubCacheDirPath, 'hosted', host.replaceAll('/', '%47'), '$name-$version'));
    } else if (source == 'git') {
      final repo = gitRepoName(desc['url']);
      final commit = desc['resolved-ref'];
      directory = Directory(path.join(pubCacheDirPath, 'git/$repo-$commit', desc['path']));
    } else if (source == 'sdk' && flutterDir != null) {
      directory = Directory(path.join(flutterDir, 'packages', outerName));
      isSdk = true;
    } else if (source == 'path') {
      directory = Directory(path.absolute(path.dirname(pubspecLockPath), desc['path']));
      isSdk = true;
    } else {
      return null;
    }

    String? license;
    bool isMarkdown = false;
    if (outerName == 'flutter' && flutterDir != null) {
      license = await File(path.join(flutterDir, 'LICENSE')).readAsString();
    } else {
      String licensePath = path.join(directory.path, 'LICENSE');
      try {
        license = await File(licensePath).readAsString();
      } catch (e) {
        if (await File('$licensePath.md').exists()) {
          license = await File('$licensePath.md').readAsString();
          isMarkdown = true;
        }
      }
    }

    if (license == '') {
      license = null;
    }

    dynamic yaml;
    try {
      yaml = loadYaml(await File(path.join(directory.path, 'pubspec.yaml')).readAsString());
    } catch (e) {
      // yaml may not be there
      yaml = {};
    }

    final name = yaml['name'];
    final description = yaml['description'];
    if (name is! String || description is! String) {
      return null;
    }

    final version = outerName == 'flutter' && flutterDir != null
        ? await File(path.join(flutterDir, 'version')).readAsString()
        : yaml['version'];
    if (version is! String) {
      return null;
    }

    return Package(
      directory: directory,
      packageYaml: yaml,
      name: name,
      description: description,
      homepage: yaml['homepage'],
      repository: yaml['repository'],
      authors: yaml['authors']?.cast<String>()?.toList() ?? (yaml['author'] != null ? [yaml['author']] : []),
      version: version.trim(),
      license: license?.trim().replaceAll('\r\n', '\n'),
      isMarkdown: isMarkdown,
      isSdk: isSdk,
      dependencies: [],
    );
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
