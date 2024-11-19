# flutter_oss_licenses

## Introduction

[flutter_oss_licenses](https://pub.dev/packages/flutter_oss_licenses) is a tool to generate detail and better OSS license list using `pubspec.yaml/lock` files.

Unlike the package name, it still runs with pure Dart environment :)

## Installing

Adding the package name to `dev_dependencies`; not to `dependencies` because the package does nothing on runtime.

```yaml
dev_dependencies:
  flutter_oss_licenses: ^3.0.4
```

## Generate oss_licenses.dart

Before executing the command, you must update your `pubspec.lock` using `pub get` (or `pub upgrade` if you want).

```shell
flutter pub get
```

And then, the following command generates `oss_licenses.dart` on the project's `lib/` directory:

```shell
dart run flutter_oss_licenses:generate
```

The following fragment is just a part of generated `lib/oss_licenses.dart`:

```dart
const allDependencies = <Package>[
  _args,
  _collection,
  _dart_pubspec_licenses,
  _flutter_lints,
  _json_annotation,
  _lints,
  _meta,
  _path,
  _source_span,
  _string_scanner,
  _term_glyph,
  _yaml
];

/// Direct `dependencies`.
const dependencies = <Package>[
  _args,
  _dart_pubspec_licenses,
  _meta,
  _path,
  _yaml
];

/// Direct `dev_dependencies`.
const devDependencies = <Package>[
  _flutter_lints
];

/// Package license definition.
class Package {
  /// Package name
  final String name;
  /// Description
  final String description;
  /// Website URL
  final String? homepage;
  /// Repository URL
  final String? repository;
  /// Authors
  final List<String> authors;
  /// Version
  final String version;
  /// License
  final String? license;
  /// Whether the license is in markdown format or not (plain text).
  final bool isMarkdown;
  /// Whether the package is included in the SDK or not.
  final bool isSdk;
  /// Direct dependencies
  final List<PackageRef> dependencies;

  const Package({
    required this.name,
    required this.description,
    this.homepage,
    this.repository,
    required this.authors,
    required this.version,
    this.license,
    required this.isMarkdown,
    required this.isSdk,
    required this.dependencies,
  });
}

class PackageRef {
  final String name;

  const PackageRef(this.name);

  Package resolve() => allDependencies.firstWhere((d) => d.name == name);
}

/// args 2.6.0
const _args = Package(
    name: 'args',
    description: 'Library for defining parsers for parsing raw command-line arguments into a set of options and values using GNU and POSIX style options.',
    repository: 'https://github.com/dart-lang/core/main/pkgs/args',
    authors: [],
    version: '2.6.0',
    license: '''Copyright 2013, the Dart project authors. 

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.''',
    isMarkdown: false,
    isSdk: false,
    dependencies: []
  );

...

```

The `Package` class here is defined inside the same file but it's almost identical to [dart_pubspec_licenses](https://pub.dev/packages/dart_pubspec_licenses)'s [Package](https://pub.dev/documentation/dart_pubspec_licenses/2.0.1/dart_pubspec_licenses/Package-class.html) class except it does not have `directory` and `packageYaml` fields.

For a full generated sample, see example code's [oss_licenses.dart](https://github.com/espresso3389/flutter_oss_licenses/blob/master/packages/flutter_oss_licenses/example/lib/oss_licenses.dart).

## Command line options

The following command line generates JSON file instead of dart file:

```shell
dart run flutter_oss_licenses:generate -o licenses.json --json
```

The following table lists the acceptable options:

| Option                        | Abbr. | Description                                                                                                                                                                                                                                                               |
| ----------------------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--output OUTPUT_FILE_PATH`   | `-o`  | Specify output file path. If the file extension is .json, --json option is implied anyway. The default output file path depends on the `--json` flag:<br>with `--json`: `PROJECT_ROOT/assets/oss_licenses.json`<br>without `--json`: `PROJECT_ROOT/lib/oss_licenses.dart` |
| `--ignore PACKAGE[,...]` | `-i` | Ignore packages by names.<br>This option can be specified multiple times, or as a comma-separated list.
| `--project-root PROJECT_ROOT` | `-p`  | Explicitly specify project root directory that contains `pubspec.lock`.                                                                                                                                                                                                   |
| `--json`                      | `-j`  | Generate JSON file rather than dart file.                                                                                                                                                                                                                                 |
| `--help`                      | `-h`  | Show the help.                                                                                                                                                                                                                                                            |

### Environment variables

The `bin/generate.dart` uses one or two environment variable(s) depending on your use case:

- `PUB_CACHE` is used to determine package directory.
- `FLUTTER_ROOT` is for Flutter projects only. If not set, Flutter SDK dependencies are simply ignored and not listed.

They are normally set by `dart run`.

## Reporting issues

Report any bugs on the project's [issues](https://github.com/espresso3389/flutter_oss_licenses/issues).

## URLs

- [Project page on GitHub](https://github.com/espresso3389/flutter_oss_licenses)
- [Flutter package](https://pub.dev/packages/flutter_oss_licenses)
