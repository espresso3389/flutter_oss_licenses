#!/usr/bin/env dart

/// A command-line tool to print license information for all direct
/// (non-transitive and non-development) dependencies from a Dart project's
/// `pubspec.lock` file.
///
/// Takes a path to the Dart project as an argument.  If no argument is
/// specified, uses the current working directory.

import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:dart_pubspec_licenses/dart_pubspec_licenses.dart' as oss;

void main(List<String> args) async {
  final projectRoot = args.isEmpty ? '.' : args.first;
  final pubspecLockPath = path.join(projectRoot, 'pubspec.lock');
  if (!io.File(pubspecLockPath).existsSync()) {
    io.stderr.writeln('"$pubspecLockPath" not found.');
    io.exitCode = 1;
    return;
  }

  final info = await oss.generateLicenseInfo(pubspecLockPath: pubspecLockPath);

  var firstIteration = true;
  for (var entry in info.entries) {
    if (!(entry.value['isDirectDependency'] ?? false)) {
      continue;
    }

    if (!firstIteration) {
      print('-' * 40);
    }

    print(
      '${entry.key}:\n'
      '\n'
      '${entry.value['license']}\n',
    );
    firstIteration = false;
  }
}
