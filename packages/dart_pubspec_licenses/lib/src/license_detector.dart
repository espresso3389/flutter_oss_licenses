import 'dart:async';
import 'dart:io';

class LicenseDetector {
  // Common license patterns and their identifiers
  static const Map<String, List<String>> licensePatterns = {
    'MIT': ['MIT License', 'Permission is hereby granted, free of charge', 'THE SOFTWARE IS PROVIDED "AS IS"', 'MIT'],
    'Apache-2.0': [
      'Apache License',
      'Version 2.0',
      'Licensed under the Apache License, Version 2.0',
      'http://www.apache.org/licenses/LICENSE-2.0',
    ],
    'GPL-3.0': ['GNU GENERAL PUBLIC LICENSE', 'Version 3', 'Free Software Foundation', 'https://www.gnu.org/licenses/'],
    'GPL-2.0': ['GNU GENERAL PUBLIC LICENSE', 'Version 2', 'Free Software Foundation, Inc.'],
    'BSD-3-Clause': [
      'BSD 3-Clause',
      'Redistribution and use in source and binary forms',
      'Neither the name of',
      'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS',
    ],
    'BSD-2-Clause': [
      'BSD 2-Clause',
      'Redistribution and use in source and binary forms',
      'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS',
    ],
    'ISC': ['ISC License', 'Permission to use, copy, modify, and/or distribute', 'THE SOFTWARE IS PROVIDED "AS IS"'],
    'LGPL-2.1': ['GNU LESSER GENERAL PUBLIC LICENSE', 'Version 2.1'],
    'LGPL-3.0': ['GNU LESSER GENERAL PUBLIC LICENSE', 'Version 3'],
    'MPL-2.0': ['Mozilla Public License Version 2.0', 'Mozilla Public License, version 2.0'],
    'Unlicense': ['This is free and unencumbered software', 'UNLICENSE', 'unlicense.org'],
    'CC0-1.0': ['Creative Commons CC0', 'Creative Commons Zero', 'Public Domain Dedication'],
    'OFL-1.1': [
      'SIL OPEN FONT LICENSE',
      'Open Font License',
      'SIL International',
      'scripts.sil.org/OFL',
      'Permission is hereby granted, free of charge, to any person obtaining a copy of the Font Software',
      'Font Software may be sold as part of a larger software package',
      'The Font Software may be modified, altered, or added to',
    ],
  };

  /// Detects the license type from a file path
  static Future<LicenseResult> detectFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return LicenseResult(type: 'Unknown', confidence: 0.0, filePath: filePath, error: 'File does not exist');
      }

      final content = await file.readAsString();
      return detectFromContent(content, filePath);
    } catch (e) {
      return LicenseResult(type: 'Unknown', confidence: 0.0, filePath: filePath, error: 'Error reading file: $e');
    }
  }

  /// Detects the license type from directory (looks for LICENSE or LICENSE.md)
  static Future<LicenseResult> detectFromDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return LicenseResult(
        type: 'Unknown',
        confidence: 0.0,
        filePath: directoryPath,
        error: 'Directory does not exist',
      );
    }

    // Common license file names
    final licenseFileNames = [
      'LICENSE',
      'LICENSE.md',
      'LICENSE.txt',
      'license',
      'license.md',
      'license.txt',
      'COPYING',
      'COPYING.txt',
    ];

    for (final fileName in licenseFileNames) {
      final filePath = '$directoryPath/$fileName';
      final file = File(filePath);
      if (await file.exists()) {
        return await detectFromFile(filePath);
      }
    }

    return LicenseResult(type: 'Unknown', confidence: 0.0, filePath: directoryPath, error: 'No license file found');
  }

  /// Detects the license type from content string
  static LicenseResult detectFromContent(String content, [String? filePath]) {
    final normalizedContent = content.toLowerCase();

    Map<String, double> scores = {};

    // Calculate scores for each license type
    for (final entry in licensePatterns.entries) {
      final licenseType = entry.key;
      final patterns = entry.value;

      double score = 0.0;
      int matchCount = 0;

      for (final pattern in patterns) {
        if (normalizedContent.contains(pattern.toLowerCase())) {
          matchCount++;
          // Give higher weight to exact matches and license names
          if (pattern.toLowerCase() == licenseType.toLowerCase()) {
            score += 2.0;
          } else {
            score += 1.0;
          }
        }
      }

      // Calculate confidence based on matches
      if (matchCount > 0) {
        scores[licenseType] = score / patterns.length;
      }
    }

    if (scores.isEmpty) {
      return LicenseResult(type: 'Unknown', confidence: 0.0, filePath: filePath, content: content);
    }

    // Find the license with the highest score
    final bestMatch = scores.entries.reduce((a, b) => a.value > b.value ? a : b);

    return LicenseResult(
      type: bestMatch.key,
      confidence: bestMatch.value.clamp(0.0, 1.0),
      filePath: filePath,
      content: content,
      allScores: Map.from(scores),
    );
  }
}

class LicenseResult {
  LicenseResult({
    required this.type,
    required this.confidence,
    this.filePath,
    this.content,
    this.error,
    this.allScores,
  });
  final String type;
  final double confidence;
  final String? filePath;
  final String? content;
  final String? error;
  final Map<String, double>? allScores;

  bool get isValid => error == null && confidence > 0.0;

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    if (error != null) {
      return 'Error: $error';
    }

    final buffer = StringBuffer();
    buffer.writeln('License Type: $type');
    buffer.writeln('Confidence: $confidencePercentage');
    if (filePath != null) {
      buffer.writeln('File: $filePath');
    }

    if (allScores != null && allScores!.length > 1) {
      buffer.writeln('\nAll detected licenses:');
      final sortedScores = allScores!.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedScores) {
        final percentage = (entry.value * 100).toStringAsFixed(1);
        buffer.writeln('  ${entry.key}: $percentage%');
      }
    }

    return buffer.toString();
  }
}
