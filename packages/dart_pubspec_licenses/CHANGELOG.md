## 3.0.14

- Fixed PathNotFoundException when processing Flutter pre-release versions by reading from `bin/cache/flutter.version.json` instead of `version` file ([#33](https://github.com/espresso3389/flutter_oss_licenses/issues/33)).

## 3.0.13

- Added SPDX license detection to expose `spdxIdentifiers` in generated outputs ([#14](https://github.com/espresso3389/flutter_oss_licenses/issues/14)).
- Updated the CLI entrypoint to return an exit code for better script integration.

## 3.0.12

- Fixed the main package being reported as one of its own dependencies in generated outputs.
- Ensure generated JSON and Dart constants always include metadata for the root package.

## 3.0.11

- FIXED: [#31](https://github.com/espresso3389/flutter_oss_licenses/issues/31) Limit concurrent dependency loading to avoid resource exhaustion during generation.

## 3.0.10

- Added `isDirectDependency` field to JSON output to distinguish direct dependencies from transitive ones ([#16](https://github.com/espresso3389/flutter_oss_licenses/issues/16))

## 3.0.9

- FIXED: [#30](https://github.com/espresso3389/flutter_oss_licenses/issues/30) `thisPackage` may not be generated correctly
- Added `devDependencies` field to the `Package` class in generated output

## 3.0.8

- Added comprehensive DartDoc comments to all public APIs for better documentation

## 3.0.7

- Further fix.

## 3.0.6

- Further fix.

## 3.0.5

- pub workspace support
- flutter_oss_licenses now does nothing but just re-export the functionality of dart_pubspec_licenses and exists for backward compatibility only
  - Projects had better use dart_pubspec_licenses directly

## 3.0.4

- Minor fixes

## 3.0.3

- Document updates

## 3.0.2

- Merge PR #27 to support ignoring certain packages

## 3.0.1

- Minor fixes

## 3.0.0

- New data structure to handle dependencies and devDependencies

## 2.0.3

- Internal generation logic update
- Dependency updates

## 2.0.2

- Handle platform separators, handle slashes in the url of hosted dependencies
- Add toJson conversion to a package

## 2.0.1

- Minor null-safety updates.

## 2.0.0

- Sync to flutter_oss_licenses' version up.

## 1.0.3

- Make the `FLUTTER_ROOT` environment variable optional.

## 1.0.2

- Supporting git/local relative path [#7](https://github.com/espresso3389/flutter_oss_licenses/issues/7)

## 1.0.1+1

- Add a standalone example and replace the example in `README.md`.

## 1.0.1

- Renaming the things

## 1.0.0

- Initial release

