## 3.0.5

- flutter_oss_licenses now does nothing but just re-export the functionality of dart_pubspec_licenses and exists for backward compatibility only
  - Projects had better use dart_pubspec_licenses directly

## 3.0.4

- Merge PR #17, #19, #26

## 3.0.3

- Minor fixes

## 3.0.2

- Minor fixes

## 3.0.1

- Minor fixes

## 3.0.0

- New data structure to handle dependencies and devDependencies

## 2.0.3

- Downgrade meta to 1.11.0

## 2.0.2

- Internal generation logic update
- Dependency updates

## 2.0.1

- dart_pubspec_licenses 2.0.2

## 2.0.0+1

- Update example code.

## 2.0.0

- Introduces Package class to make the package more modern (#9)

## 1.1.4

- Minor fix.

## 1.1.3

- dart_pubspec_licenses 1.0.3

## 1.1.2

- dart_pubspec_licenses 1.0.2 for [#7](https://github.com/espresso3389/flutter_oss_licenses/issues/7)
- Update command line module to support `-json` option (#8)

## 1.1.1

- FIXED: command name should be bin/generate.dart

## 1.1.0

- It now depends on a new module named [dart_pubspec_licenses](https://pub.dev/packages/dart_pubspec_licenses); based on PR #6 by [dustin-graham](https://github.com/dustin-graham).

## 1.0.1

- FIX: Doesn't run on Flutter 2.0 (#2)
- Better formatting on oss_licenses.dart.

## 1.0.0

- Supports null-safety.

## 0.6.6

- Updating settings.

## 0.6.4

- Updating README.md.

## 0.6.3

- Recent flutter builds uses LOCALAPPDATA for pub cache on Windows.

## 0.6.2

- Minor error fixes.

## 0.6.1

- Minor error fixes.

## 0.6.0

- _BREAKING CHANGE_: The output format is completely changed to provide more information about packages.

## 0.5.2

- Minor fix :(

## 0.5.1

- Minor fix.

## 0.5.0

- For Windows, new pub-cache directory is `%APPDATA%\Pub\Cache`.

## 0.4.1

- FIXED: Generation process stops if `PUB_CACHE` is not explicitly defined.

## 0.3.0

- Loosen version restriction on dependency packages because it conflicts with certain well-used packages.

## 0.2.0

- Addresses facial things warned by pub.dev health suggestions.

## 0.1.0

- First release.
