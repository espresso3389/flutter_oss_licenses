# flutter_oss_licenses
A tool for generating OSS license list using pubspec.lock

## Generate oss_licenses.dart

The following command generates `oss_licenses.dart` on the project's `lib/` directory:

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
