import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Represents the structure of a Dart/Flutter project with its dependencies.
///
/// Contains the main [package] information and all resolved [allDependencies],
/// along with the path to the pubspec.lock file.
class ProjectStructure {
  /// Creates a [ProjectStructure] instance.
  const ProjectStructure({required this.package, required this.allDependencies, required this.pubspecLockPath});

  /// The main package of the project.
  final Package package;

  /// All dependencies including transitive ones.
  final List<Package> allDependencies;

  /// The path to the `pubspec.lock` file used to resolve dependencies.
  final String pubspecLockPath;
}

/// Represents a Dart/Flutter package with its metadata and license information.
///
/// This class encapsulates all relevant information about a package including:
/// - Basic metadata (name, description, version)
/// - Repository information (homepage, repository URL)
/// - License content and format
/// - Dependencies and dev dependencies
/// - Whether it's an SDK package
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

  /// The directory where the package is located.
  final Directory directory;

  /// The parsed pubspec.yaml content as a Map.
  final Map? pubspec;

  /// The name of the package.
  final String name;

  /// A brief description of the package.
  final String description;

  /// The homepage URL, if available.
  final String? homepage;

  /// The repository URL, if available.
  final String? repository;

  /// List of authors as specified in pubspec.yaml.
  ///
  /// This can be empty if no authors are specified.
  final List<String> authors;

  /// The package version, if available.
  final String? version;

  /// The full text of the license, if available.
  final String? license;

  /// Whether the license file is in Markdown format.
  final bool isMarkdown;

  /// Whether the package is included in the SDK or not.
  final bool isSdk;

  /// Direct dependencies
  final List<Package> dependencies;

  /// Direct dev dependencies
  final List<Package> devDependencies;

  /// Gets the path to the package's pubspec.yaml file.
  String get pubspecYamlPath => getFilePath('pubspec.yaml');

  /// Gets the full path for a file within the package directory.
  ///
  /// [name] is the file name relative to the package root.
  String getFilePath(String name) => path.join(directory.path, name);

  /// Converts the package information to a JSON-serializable map.
  ///
  /// Returns a map containing essential package metadata excluding
  /// internal properties like directory and pubspec.
  Map<String, dynamic> toJson({bool? isDirectDependency}) => <String, dynamic>{
    'name': name,
    'description': description,
    'homepage': homepage,
    'repository': repository,
    'authors': authors,
    'version': version,
    'license': license,
    'isMarkdown': isMarkdown,
    'isSdk': isSdk,
    if (isDirectDependency != null) 'isDirectDependency': isDirectDependency,
  };

  /// Creates a [Package] instance from a pubspec.lock package entry.
  ///
  /// [package] is the package entry from pubspec.lock.
  /// [pubCacheDirPath] is the path to the pub cache directory.
  /// [flutterDir] is the Flutter SDK directory path.
  /// [basePubspecYamlPath] is used to resolve relative path dependencies.
  /// It should be the path to the pubspec.yaml of the project that depends on this
  /// package (not the path to this package's pubspec.yaml).
  /// [outerName] can override the package name from the entry.
  ///
  /// Returns a [Package] instance or null if the package cannot be loaded.
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

  /// Creates a [Package] instance from a directory containing a Dart package.
  ///
  /// [projectRoot] is the root directory of the package.
  /// [outerName] can override the package name from pubspec.yaml.
  /// [isSdk] indicates whether this is an SDK package.
  /// [flutterDir] is the Flutter SDK directory path for SDK packages.
  ///
  /// Returns a [Package] instance or null if the package cannot be loaded
  /// (e.g., missing required fields in pubspec.yaml).
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

  /// Updates the dependencies and devDependencies lists based on pubspec.yaml.
  ///
  /// [allPackages] is a map of all available packages by name, used to
  /// resolve dependency references from the pubspec.
  void updateDependencies(Map<String, Package> allPackages) {
    dependencies.clear();
    dependencies.addAll(_getDependenciesFor('dependencies', allPackages));
    devDependencies.clear();
    devDependencies.addAll(_getDependenciesFor('dev_dependencies', allPackages));
  }

  /// Gets the list of packages for a specific dependency type.
  ///
  /// [depType] should be either 'dependencies' or 'dev_dependencies'.
  /// [allPackages] is a map of all available packages by name.
  ///
  /// Returns a list of resolved [Package] instances.
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

/// Removes the protocol prefix from a URL.
///
/// Strips 'https://' or 'http://' from the beginning of [url].
///
/// Returns the URL without the protocol prefix.
String removePrefix(String url) {
  if (url.startsWith('https://')) return url.substring(8);
  if (url.startsWith('http://')) return url.substring(7); // are there any?
  return url;
}

/// Extracts the repository name from a Git URL.
///
/// Takes a Git [url] and extracts the repository name,
/// removing the .git extension if present.
///
/// Returns the repository name.
String gitRepoName(String url) {
  final name = url.substring(url.lastIndexOf('/') + 1);
  return name.endsWith('.git') ? name.substring(0, name.length - 4) : name;
}
