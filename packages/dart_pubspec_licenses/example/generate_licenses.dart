// A command-line tool to print license information for all direct
// (non-transitive and non-development) dependencies from a Dart project's
// pubspec.lock file.
//
// Takes a path to the Dart project as an argument.  If no argument is
// specified, uses the current working directory.

import 'dart:io' as io;

import 'package:dart_pubspec_licenses/dart_pubspec_licenses.dart' as oss;
import 'package:path/path.dart' as path;

void main(List<String> args) async {
  final projectRoot = args.isEmpty ? '.' : args.first;
  final pubspecYamlPath = path.join(projectRoot, 'pubspec.yaml');
  if (!io.File(pubspecYamlPath).existsSync()) {
    io.stderr.writeln('"$pubspecYamlPath" not found.');
    io.exitCode = 1;
    return;
  }

  final deps = await oss.listDependencies(pubspecYamlPath: pubspecYamlPath);

  var firstIteration = true;
  for (var entry in deps.allDependencies) {
    if (!firstIteration) {
      print('-' * 40);
    }

    print(
      '${entry.name}:\n'
      '\n'
      '${entry.license}\n',
    );
    firstIteration = false;
  }
}
