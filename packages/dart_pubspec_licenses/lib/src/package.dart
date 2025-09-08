import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class ProjectStructure {
  const ProjectStructure({required this.package, required this.allDependencies, required this.pubspecLockPath});
  final Package package;
  final List<Package> allDependencies;
  final String pubspecLockPath;
}

class Package {
  const Package({
    required this.directory,
    required this.name,
    required this.description,
    required this.authors,
    required this.isMarkdown,
    required this.isSdk,
    required this.dependencies,
    required this.devDependencies,
    this.pubspec,
    this.homepage,
    this.repository,
    this.version,
    this.license,
  });
  final Directory directory;
  final Map? pubspec;
  final String name;
  final String description;
  final String? homepage;
  final String? repository;
  final List<String> authors;
  final String? version;
  final String? license;
  final bool isMarkdown;
  final bool isSdk;
  final List<Package> dependencies;
  final List<Package> devDependencies;

  String get pubspecYamlPath => getFilePath('pubspec.yaml');

  String getFilePath(String name) => path.join(directory.path, name);

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

  /// [basePubspecYamlPath] is used to resolve relative path dependencies.
  /// It should be the path to the pubspec.yaml of the project that depends on this
  /// package (not the path to this package's pubspec.yaml).
  static Future<Package?> fromPubspecLockPackageEntry({
    required Map package,
    required String pubCacheDirPath,
    required String? flutterDir,
    required String basePubspecYamlPath,
    String? outerName,
  }) async {
    Directory directory;
    bool isSdk = false;
    outerName ??= package['name'];
    final source = package['source'];
    final desc = package['description'];
    if (source == 'hosted') {
      final host = removePrefix(desc['url']);
      final name = desc['name'];
      final version = package['version'];
      directory = Directory(path.join(pubCacheDirPath, 'hosted', host.replaceAll('/', '%47'), '$name-$version'));
    } else if (source == 'git') {
      final repo = gitRepoName(desc['url']);
      final commit = desc['resolved-ref'];
      directory = Directory(path.join(pubCacheDirPath, 'git/$repo-$commit', desc['path']));
    } else if (source == 'sdk' && flutterDir != null) {
      directory = Directory(path.join(flutterDir, 'packages', outerName));
      isSdk = true;
    } else if (source == 'path') {
      directory = Directory(path.absolute(path.dirname(basePubspecYamlPath), desc['path']));
      isSdk = true;
    } else {
      return null;
    }
    return await fromDirectory(projectRoot: directory, outerName: outerName, isSdk: isSdk, flutterDir: flutterDir);
  }

  static Future<Package?> fromDirectory({
    required Directory projectRoot,
    String? outerName,
    bool isSdk = false,
    String? flutterDir,
  }) async {
    //print('Loading package from ${projectRoot.path}');
    String? license;
    bool isMarkdown = false;
    if (outerName == 'flutter' && flutterDir != null) {
      license = await File(path.join(flutterDir, 'LICENSE')).readAsString();
    } else {
      String licensePath = path.join(projectRoot.path, 'LICENSE');
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
      yaml = loadYaml(await File(path.join(projectRoot.path, 'pubspec.yaml')).readAsString());
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

    return Package(
      directory: projectRoot,
      pubspec: yaml,
      name: name,
      description: description,
      homepage: yaml['homepage'],
      repository: yaml['repository'],
      authors: yaml['authors']?.cast<String>()?.toList() ?? (yaml['author'] != null ? [yaml['author']] : []),
      version: (version as String?)?.trim(),
      license: license?.trim().replaceAll('\r\n', '\n'),
      isMarkdown: isMarkdown,
      isSdk: isSdk,
      dependencies: [],
      devDependencies: [],
    );
  }

  void updateDependencies(Map<String, Package> allPackages) {
    dependencies.clear();
    dependencies.addAll(_getDependenciesFor('dependencies', allPackages));
    devDependencies.clear();
    devDependencies.addAll(_getDependenciesFor('dev_dependencies', allPackages));
  }

  List<Package> _getDependenciesFor(String depType, Map<String, Package> allPackages) {
    final deps = <Package>[];
    for (final depName in (pubspec?[depType] as YamlMap?)?.keys.cast<String>() ?? const []) {
      final dep = allPackages[depName];
      if (dep != null) {
        deps.add(dep);
      }
    }
    return deps;
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
