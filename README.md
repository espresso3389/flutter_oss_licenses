## Introduction

[flutter_oss_licenses](https://pub.dev/packages/flutter_oss_licenses) is a tool for generating OSS license list using `pubspec.lock`.

## Installing

Adding the package name to `dev_dependencies`; not to `dependencies` because the package does nothing on runtime.

```
dev_dependencies:
  flutter_oss_licenses: ^0.1.0
```

## Generate oss_licenses.dart

Before executing the command, you must update your `pubspec.lock` using `pub get` (or `pub upgrade` if you want).

```shell
$ flutter pub get
```

And then, the following command generates `oss_licenses.dart` on the project's `lib/` directory:

```shell
$ flutter pub run flutter_oss_licenses:generate.dart
```

## The file structure

The generated file contains a simple `Map<String, String>` that maps each project name to its corresponding license text, that is normally provided by `LICENSE` file on the project:

```dart
Map<String, String> oss_licenses = {
  'some_project': '''Copyright 201X Some Project Owners. All rights reserved.''',
  'another_project': '''Another project's license terms...''',
  ...
};
```

And, you can use the map on your project code in your way. The package does not do anything on the list.

## Command line options

Either running `generate.dart` using `pub run` or directly, it accepts two or less options. 
The first option is output dart file name. The default is `lib/oss_licenses.dart`.
And the another is project root, which is by default detected automatically.

```shell
$ generate.dart [OUTPUT_FILENAME [PROJECT_ROOT]]
```

The `bin/generated.dart` uses two environment variables; one is `FLUTTER_ROOT` and `PUB_CACHE`. They are normally set by `flutter pub run` but if you directly execute the script, you must set them manually.

## Reporting issues

Report any bugs on the project's [issues](https://github.com/espresso3389/flutter_oss_licenses/issues).

## URLs

- [Project page on GitHub](https://github.com/espresso3389/flutter_oss_licenses)
- [Flutter package](https://pub.dev/packages/flutter_oss_licenses)
