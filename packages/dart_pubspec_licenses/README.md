## Introduction

[dart_pubspec_licenses](https://pub.dev/packages/dart_pubspec_licenses) is a package that helps gather and assemble OSS license info using `pubspec.lock`.

## Installing

Adding the package name to `dev_dependencies`; not to `dependencies` because the package does nothing on runtime.

Of course, if you just want to create some program that handles Dart/Flutter dependency information, you can use the package in your `dependencies`.

```yaml
dev_dependencies:
  dart_pubspec_licenses: ^3.0.7
```

## Generate oss_licenses.dart

Before executing the command, you must update your `pubspec.lock` using `pub get` (or `pub upgrade` if you want).

```shell
dart pub get
```

And then, the following command generates `oss_licenses.dart` on the project's `lib/` directory:

```shell
dart run dart_pubspec_licenses:generate
```

The following fragment is just a "simplified" part of generated `lib/oss_licenses.dart`:

```dart
const thisPackage = _example;

const allDependencies = <Package>[
  __fe_analyzer_shared,
  _analyzer,
  _args,
  _async,
  _boolean_selector,
  _build,
  _build_config,
  _build_daemon,
  _build_runner,
  ...
];

/// Direct `dependencies`.
const dependencies = <Package>[
  _flutter,
  _cupertino_icons,
  _url_launcher
];

/// Direct `dev_dependencies`.
const devDependencies = <Package>[
  _flutter_lints,
  _flutter_oss_licenses
];

/// Package license definition.
class Package {
  /// Package name
  final String name;
  /// Description
  final String description;
  /// Authors
  final List<String> authors;
  /// Whether the license is in markdown format or not (plain text).
  final bool isMarkdown;
  /// Whether the package is included in the SDK or not.
  final bool isSdk;
  /// Direct dependencies
  final List<PackageRef> dependencies;
  /// Direct devDependencies
  final List<PackageRef> devDependencies;
  /// Website URL
  final String? homepage;
  /// Repository URL
  final String? repository;
  /// Version
  final String? version;
  /// License
  final String? license;
  /// The [SPDX](https://spdx.org/licenses/) license identifiers, if detected.
  final List<String> spdxIdentifiers;

  ...
}

...

/// dart_pubspec_licenses 3.0.12
const _dart_pubspec_licenses = Package(
    name: 'dart_pubspec_licenses',
    description: 'A library to make it easy to extract OSS license information from Dart packages using pubspec.yaml',
    homepage: 'https://github.com/espresso3389/flutter_oss_licenses/tree/master/packages/dart_pubspec_licenses',
    repository: 'https://github.com/espresso3389/flutter_oss_licenses',
    authors: [],
    version: '3.0.12',
    spdxIdentifiers: ['MIT'],
    isMarkdown: false,
    isSdk: false,
    dependencies: [PackageRef('yaml'), PackageRef('path'), PackageRef('json_annotation'), PackageRef('args'), PackageRef('pana')],
    devDependencies: [PackageRef('lints'), PackageRef('json_serializable'), PackageRef('build_runner')],
    license: '''MIT License

Copyright (c) 2019 Takashi Kawasaki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''',
  );

...

```

The `Package` class here is defined inside the same file but it's almost identical to [dart_pubspec_licenses](https://pub.dev/packages/dart_pubspec_licenses)'s [Package](https://pub.dev/documentation/dart_pubspec_licenses/latest/dart_pubspec_licenses/Package-class.html) class except it does not have `directory` and `packageYaml` fields.

For a full generated sample, see example code's [oss_licenses.dart](https://github.com/espresso3389/flutter_oss_licenses/blob/master/packages/flutter_oss_licenses/example/lib/oss_licenses.dart).

## Command line options

The following command line generates JSON file instead of dart file:

```shell
dart run dart_pubspec_licenses:generate -o licenses.json --json
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
