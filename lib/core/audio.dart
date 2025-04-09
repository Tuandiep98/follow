import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:follow/core/string_utils.dart';
import 'package:follow/env/env.dart';
import 'package:just_audio/just_audio.dart';

import 'package:http/http.dart' as http;

class Audio {
  static final FlutterSound player = FlutterSound();

  static Future<void> playBase64Audio(String base64AudioData) async {
    String cleanBase64String = base64AudioData.split(',').last;
    final bytes = base64Decode(cleanBase64String);

    await player.thePlayer.openPlayer();
    await player.thePlayer.setVolume(1.0);
    await player.thePlayer.startPlayer(
      fromDataBuffer: bytes,
      codec: Codec.mp3,
      whenFinished: () {
        debugPrint('Audio finished playing');
      },
    );

    await player.thePlayer.closePlayer();
  }

  static Future<void> detectAudioIntervals(String audioPath) async {
    final player = AudioPlayer();

    await player.setFilePath(audioPath);

    // Volume threshold: if the audio volume goes above this threshold, it's considered significant
    const double volumeThreshold = 0.1;

    // Initialize a list to store the intervals
    List<Map<String, Duration?>> intervals = [];

    debugPrint('started playing');
    // Monitor the audio position and approximate volume
    player.positionStream.listen((position) async {
      double volume =
          player.volume; // This is just an approximation; refine as needed

      if (volume > volumeThreshold) {
        // Mark the interval with volume above threshold
        if (intervals.isEmpty || intervals.last['end'] != null) {
          intervals.add({'start': position, 'end': null});
        }
      } else {
        if (intervals.isNotEmpty && intervals.last['end'] == null) {
          intervals.last['end'] = position;
        }
      }
    });

    // After some time or when audio finishes, check intervals
    player.positionStream.listen((position) {
      if (position == player.duration) {
        // Print out all the intervals with volume above threshold
        for (var interval in intervals) {
          debugPrint(
              'Volume interval: Start - ${interval['start']}, End - ${interval['end']}');
        }
      }
    });
  }

  /// response format: lrc
  /// model: whisper-1
  static Future<String> transcribeAudio(Uint8List audioFileBytes) async {
    print('start\n');
    final Stopwatch _stopwatch = Stopwatch()..start();
    final apiKey = Env.apiKey; // Replace with your Whisper API key
    final uri = Uri.parse(
        'https://api.openai.com/v1/audio/transcriptions'); // Endpoint URL

    // Open the audio file
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['model'] = 'whisper-1'
      ..fields['response_format'] = 'verbose_json';

    // Explicitly add timestamp_granularities as separate entries
    List<String> timestampGranularities = ['word', 'segment'];
    for (String granularity in timestampGranularities) {
      request.files.add(http.MultipartFile.fromString(
          'timestamp_granularities[]', granularity));
    }

    // Add the audio file to the request
    request.files.add(http.MultipartFile.fromBytes('file', audioFileBytes,
        filename: 'audio.wav'));

    // Send the request
    var response = await request.send();

    print('take: ${_stopwatch.elapsed.inSeconds}seconds.');
    _stopwatch.stop();
    // Parse the response
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      debugPrint(responseData);
      return responseData;
    } else {
      return 'Failed to transcribe audio. Status code: ${response.statusCode}';
    }
  }

  static Future<Uint8List?> getOnlineAudioBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('api error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return null;
  }
}
