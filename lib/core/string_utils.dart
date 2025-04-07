import 'dart:convert';

import 'package:flutter/material.dart';

class StringUtils {
  static String convertWebVttToLrc(String webvtt) {
    String res = '';
    try {
      // Split into lines and filter out empty lines or header
      final lines = LineSplitter.split(webvtt)
          .where((line) => line.trim().isNotEmpty && line != 'WEBVTT')
          .toList();

      final lrcLines = <String>[];
      String? currentText;
      RegExp timestampRegex =
          RegExp(r'(\d{2}:\d{2}:\d{2}\.\d{3}) --> (\d{2}:\d{2}:\d{2}\.\d{3})');

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        // Check if the line is a timestamp
        if (timestampRegex.hasMatch(line)) {
          if (currentText != null && lrcLines.isNotEmpty) {
            // Add the previous text with its timestamp
            lrcLines.last = '${lrcLines.last}$currentText';
          }

          // Extract start timestamp and convert to LRC format
          final match = timestampRegex.firstMatch(line)!;
          final startTime = match.group(1)!; // e.g., "00:00:01.000"
          final lrcTime = webVttTimestampToLrc(startTime);
          lrcLines.add('[$lrcTime]');
          currentText = ''; // Reset text for the next cue
        } else {
          // Accumulate text (could span multiple lines in WebVTT)
          currentText = currentText!.isEmpty ? line : '$currentText\n$line';
        }
      }

      // Add the last text block
      if (currentText != null &&
          currentText.isNotEmpty &&
          lrcLines.isNotEmpty) {
        lrcLines.last = '${lrcLines.last}$currentText';
      }

      res = lrcLines.join('\n');
    } catch (e) {
      debugPrint('Error converting WebVTT to LRC: $e');
      return '';
    }
    return res;
  }

  static String webVttTimestampToLrc(String webvttTime) {
    // Convert "HH:MM:SS.mmm" to "[MM:SS.xx]"
    final parts = webvttTime.split(':'); // ["00", "00", "01.000"]
    final hours = int.parse(parts[0]);
    final minutes =
        int.parse(parts[1]) + (hours * 60); // Convert hours to minutes
    final secondsPart = parts[2]; // "01.000"
    final seconds = double.parse(secondsPart); // 1.000

    // Format to MM:SS.xx (LRC uses hundredths of a second)
    final totalSeconds = seconds.toStringAsFixed(2); // "1.00"
    final lrcMinutes = minutes.toString().padLeft(2, '0');
    final lrcSeconds = totalSeconds.padLeft(5, '0'); // "01.00"

    return '$lrcMinutes:$lrcSeconds'; // e.g., "00:01.00"
  }
}
