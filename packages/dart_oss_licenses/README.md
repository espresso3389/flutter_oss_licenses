## Introduction

[dart_oss_licenses](https://pub.dev/packages/flutter_oss_licenses) is a package that helps gather and assemble OSS license info using `pubspec.lock`.

## Installation
```yaml
dependencies:
  dart_oss_licenses: ^1.0.0
```

## Usage
```dart
import 'package:dart_oss_licenses/dart_oss_licenses.dart' as oss;

void main() async {
  final pubspecLockPath = "path/to/pubspec.lock";
  final info = await oss.generateLicenseInfo(
      pubspecLockPath: project.pubspecLockPath);
  print(info);
}
```

## Reporting issues

Report any bugs on the project's [issues](https://github.com/espresso3389/flutter_oss_licenses/issues).

## URLs

- [Project page on GitHub](https://github.com/espresso3389/flutter_oss_licenses)
- [Flutter package](https://pub.dev/packages/flutter_oss_licenses)
