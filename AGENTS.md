# AGENTS.md

This file provides guidance to AI when working with code in this repository.

## Project Overview

This is a monorepo containing two packages:

1. **dart_pubspec_licenses** (`packages/dart_pubspec_licenses/`) - A library to make it easy to extract OSS license information from Dart packages using pubspec.yaml

- Pure Dart package with no Flutter dependencies

2. **flutter_oss_licenses** (`packages/flutter_oss_licenses/`) - A Flutter package for displaying OSS licenses

- This package now does nothing but just re-export the functionality of dart_pubspec_licenses.
- Provides Flutter example that displays licenses in an app

## Development Commands

### Monorepo Management

This project uses pub workspace and all you have to do is to run `dart pub get` on some directory:

```bash
dart pub get
```

### Basic Flutter Commands

```bash
# For the dart_pubspec_licenses package
cd packages/dart_pubspec_licenses
dart pub get            # Install dependencies
dart analyze            # Run static analysis
dart test               # Run all tests
dart format .           # Format code (120 char line width)

# For the main flutter_oss_licenses package
cd packages/flutter_oss_licenses
flutter pub get          # Install dependencies
flutter analyze          # Run static analysis
flutter test             # Run all tests
flutter format .         # Format code (120 char line width)
```

## Release Process

Both packages may need to be released when changes are made:

### For dart_pubspec_licenses package updates

1. Update version in `packages/dart_pubspec_licenses/pubspec.yaml`
   - Basically, if the changes are not breaking (or relatively small breaking changes), increment the patch version (X.Y.Z -> X.Y.Z+1)
   - If there are breaking changes, increment the minor version (X.Y.Z -> X.Y+1.0)
   - If there are major changes, increment the major version (X.Y.Z -> X+1.0.0)
2. Update `packages/dart_pubspec_licenses/CHANGELOG.md` with changes
   - Don't mention CI/CD changes and `AGENTS.md` related changes (unless they are significant)
3. Update `packages/dart_pubspec_licenses/README.md` if needed
4. Update `README.md` on the repo root if needed
5. Run `dart pub publish` in `packages/dart_pubspec_licenses/`

### For flutter_oss_licenses package updates

1. Update version in `packages/flutter_oss_licenses/pubspec.yaml`
   - If dart_pubspec_licenses was updated, update the dependency version
2. Update `packages/flutter_oss_licenses/CHANGELOG.md` with changes
3. Update `packages/flutter_oss_licenses/README.md` with new version information
   - Changes version in example fragments
   - Consider to add notes for new features or breaking changes
   - Notify the owner if you find any issues with the example app or documentation
4. Update `README.md` on the repo root if needed
5. Run `dart pub get` to update all dependencies
6. Run tests to ensure everything works
   - Run `dart test` in `packages/dart_pubspec_licenses/`
   - Run `flutter test` in `packages/flutter_oss_licenses/`
7. Ensure the command runs correctly
   - Run `dart run dart_pubspec_licenses:generate` in `packages/flutter_oss_licenses/example`
8. Ensure the example app builds correctly
   - Run `flutter build web --wasm` in `packages/flutter_oss_licenses/example` to test the example app
9. Commit changes with message "Release flutter_oss_licenses vX.Y.Z" or "Release dart_pubspec_licenses vX.Y.Z"
10. Tag the commit with `git tag flutter_oss_licenses-vX.Y.Z` or `git tag dart_pubspec_licenses-vX.Y.Z`
11. Push changes and tags to remote
12. Run `flutter pub publish` in `packages/flutter_oss_licenses/`
13. If the changes reference GitHub issues or PRs, add comments on them notifying about the new release
    - Use `gh issue comment` or `gh pr comment` to notify that the issue/PR has been addressed in the new release
    - If the PR references issues, please also comment on the issues
    - Follow the template below for comments (but modify it as needed):

      ```md
      The FIX|UPDATE|SOMETHING for this issue has been released in v[x.y.z](https://pub.dev/packages/flutter_oss_licenses/versions/x.y.z).

      ...Fix/update summary...

      Written by [AI AGENT NAME/SIGNATURE HERE]
      ```

    - Focus on the release notes and what was fixed/changed rather than upgrade instructions
    - Include a link to the changelog for the specific version

## Code Style

- Single quotes for strings
- 120 character line width
- Relative imports within lib/
- Follow flutter_lints with custom rules in analysis_options.yaml

## Dependency Version Policy

### dart_pubspec_licenses

This package follows standard Dart package versioning practices.

### flutter_oss_licenses

This package now does nothing but just re-export the functionality of dart_pubspec_licenses.

## Documentation Guidelines

The following guidelines should be followed when writing documentation including comments, `README.md`, and other markdown files:

- Use proper grammar and spelling
- Use clear and concise language
- Use consistent terminology
- Use proper headings for sections
- Use code blocks for code snippets
- Use bullet points for lists
- Use link to relevant issues/PRs when applicable
- Use backticks (`` ` ``) for code references and file/directory/path names in documentation

### Commenting Guidelines

- Use reference links for classes, enums, and functions in documentation
- Use `///` (dartdoc comments) for public API comments (and even for important private APIs)

### Markdown Documentation Guidelines

- Include links to issues/PRs when relevant
- Use link to [API reference](https://pub.dev/documentation/flutter_oss_licenses/latest/flutter_oss_licenses/) for public APIs if possible
- `README.md` should provide an overview of the project, how to use it, and any important notes
- `CHANGELOG.md` should follow the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) principles
  - Be careful not to include implementation details in the changelog
  - Focus on user-facing changes, new features, bug fixes, and breaking changes
  - Use sections for different versions
  - Use bullet points for changes

## Special Notes

- `CHANGELOG.md` is not an implementation node. So it should be updated only on releasing a new version
- For web search, if `gemini` command is available, use `gemini -p "<query>"`.

## Command Execution Guidelines

- Run commands directly in the repository environment; do not rely on any agent sandbox when executing them.
- If a command cannot be executed without sandboxing, pause and coordinate with the user so it runs on their machine as needed.
- On Windows, use `cmd.exe /C ...` to run any commands to reduce issues caused by missing .bat/.cmd and shebang on shell-scripts
