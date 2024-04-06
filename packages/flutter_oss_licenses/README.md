# flutter_oss_licenses

## Introduction

[flutter_oss_licenses](https://pub.dev/packages/flutter_oss_licenses) is a tool to generate detail and better OSS license list using `pubspec.yaml/lock` files.

Unlike the package name, it still runs with pure Dart environment :)

## Installing

Adding the package name to `dev_dependencies`; not to `dependencies` because the package does nothing on runtime.

```yaml
dev_dependencies:
  flutter_oss_licenses: ^3.0.0
```

## Generate oss_licenses.dart

Before executing the command, you must update your `pubspec.lock` using `pub get` (or `pub upgrade` if you want).

```shell
flutter pub get
```

And then, the following command generates `oss_licenses.dart` on the project's `lib/` directory:

```shell
flutter pub run flutter_oss_licenses:generate.dart
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
  final List<Package> dependencies;

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

...

/// dart_pubspec_licenses 2.0.3
const _dart_pubspec_licenses = Package(
    name: 'dart_pubspec_licenses',
    description: 'A library to make it easy to extract OSS license information from Dart packages using pubspec.yaml',
    homepage: 'https://github.com/espresso3389/flutter_oss_licenses/tree/master/packages/dart_pubspec_licenses',
    repository: 'https://github.com/espresso3389/flutter_oss_licenses',
    authors: [],
    version: '2.0.3',
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
    isMarkdown: false,
    isSdk: true,
    dependencies: [_yaml, _path, _json_annotation]
  );

...

```

The `Package` class here is defined inside the same file but it's almost identical to [dart_pubspec_licenses](https://pub.dev/packages/dart_pubspec_licenses)'s [Package](https://pub.dev/documentation/dart_pubspec_licenses/2.0.1/dart_pubspec_licenses/Package-class.html) class except it does not have `directory` and `packageYaml` fields.

For a full generated sample, see example code's [oss_licenses.dart](https://github.com/espresso3389/flutter_oss_licenses/blob/master/packages/flutter_oss_licenses/example/lib/oss_licenses.dart).

## Command line options

The following command line generates JSON file instead of dart file:

```shell
flutter pub run flutter_oss_licenses:generate.dart -o licenses.json --json
```

The following table lists the acceptable options:

| Option                        | Abbr. | Description                                                                                                                                                                                                                                                               |
| ----------------------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--output OUTPUT_FILE_PATH`   | `-o`  | Specify output file path. If the file extension is .json, --json option is implied anyway. The default output file path depends on the `--json` flag:<br>with `--json`: `PROJECT_ROOT/assets/oss_licenses.json`<br>without `--json`: `PROJECT_ROOT/lib/oss_licenses.dart` |
| `--project-root PROJECT_ROOT` | `-p`  | Explicitly specify project root directory that contains `pubspec.lock`.                                                                                                                                                                                                   |
| `--json`                      | `-j`  | Generate JSON file rather than dart file.                                                                                                                                                                                                                                 |
| `--help`                      | `-h`  | Show the help.                                                                                                                                                                                                                                                            |

### Environment variables

The `bin/generated.dart` uses one or two environment variable(s) depending on your use case:

- `PUB_CACHE` is used to determine package directory.
- `FLUTTER_ROOT` is for Flutter projects only. If not set, Flutter SDK dependencies are simply ignored and not listed.

They are normally set by `dart run` or `flutter pub run`.

## Reporting issues

Report any bugs on the project's [issues](https://github.com/espresso3389/flutter_oss_licenses/issues).

## URLs

- [Project page on GitHub](https://github.com/espresso3389/flutter_oss_licenses)
- [Flutter package](https://pub.dev/packages/flutter_oss_licenses)
