import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:follow/models/segment.dart';
import 'package:follow/models/transcribe_response_model.dart';
import 'package:follow/models/word.dart';

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

  String formatDurationToMMSSxx(double durationInSeconds) {
    // Extract minutes
    int minutes = (durationInSeconds ~/ 60);

    // Extract seconds (whole part)
    int seconds = (durationInSeconds.toInt() % 60);

    // Extract hundredths of a second (fractional part)
    int hundredths =
        ((durationInSeconds - durationInSeconds.toInt()) * 100).round();

    // Format as [MM:SS.xx] with zero-padding
    return '[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundredths.toString().padLeft(2, '0')}]';
  }

  static String convertWordSegmentToLrc(String input) {
    String res = '';

    try {
      TranscribleResponseModel model =
          TranscribleResponseModel.fromJson(jsonDecode(input));
      List<Segment> segments = model.segments;
      List<Word> words = model.words;
      String pharses = '';
      print('words: ${words.length}');
      print('segments: ${segments.length}');
      int lastWordPlayTime = 0;
      for (var segment in segments) {
        int durationTime = ((segment.end - segment.start) * 1000).toInt();
        int playTime = (segment.start * 1000).toInt();
        List<String> wordSplited = segment.text.split(' ');
        String pharseTemp = '';
        for (var item in wordSplited) {
          var itemTemp = removeVietnamesePunctuation(item);
          if (itemTemp == ' ') {
            pharseTemp += ' ';
          } else {
            var temp = words
                .where((x) =>
                    removeVietnamesePunctuation(x.word).toLowerCase() ==
                        itemTemp.toLowerCase() &&
                    x.start >= segment.start &&
                    x.end <= segment.end)
                .toList();
            if (temp.isNotEmpty) {
              Word word = temp.reduce((currentMin, element) =>
                  currentMin.start < element.start ? currentMin : element);
              int wordDurationTime = (word.end == word.start)
                  ? (10 * word.word.length)
                  : ((word.end - word.start) * 1000).toInt();
              int wordPlayTime = (word.start * 1000).toInt();
              if (item.contains('.')) {
                wordDurationTime += 10;
              }
              if (item.contains(',')) {
                wordDurationTime += 5;
              }
              pharseTemp += '$item ($wordPlayTime,$wordDurationTime)';
              if (lastWordPlayTime < wordPlayTime) {
                lastWordPlayTime = wordPlayTime;
              }
            } else {
              if (item.length > 1) {
                debugPrint(
                    'no word found: ${removeVietnamesePunctuation(itemTemp)}');
                int durationOfEmptyWord = 5 * item.length;
                if (item.contains('.')) {
                  durationOfEmptyWord += 10;
                }
                if (item.contains(',')) {
                  durationOfEmptyWord += 5;
                }
                pharseTemp += '$item ($lastWordPlayTime,$durationOfEmptyWord)';
                lastWordPlayTime += durationOfEmptyWord;
              }
            }
          }
        }
        pharses += '[$playTime,$durationTime]$pharseTemp\n';
      }
      res = pharses;
    } catch (e) {
      debugPrint(e.toString());
    }
    return res.isNotEmpty
        ? """
[ti:]
[ar:]
[al:]
[by:]
[offset:0]
$res"""
        : '';
  }

  static String removeVietnamesePunctuation(String text) {
    // Biểu thức chính quy để thay thế các dấu câu tiếng Việt
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }
}
