import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:follow/core/audio.dart';
import 'package:follow/env/env.dart';
import 'package:path_provider/path_provider.dart';

class AI {
  static List<OpenAIModelModel> models = [];

  static void init() {
    OpenAI.apiKey = Env.apiKey;
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
  }

  static Future<List<OpenAIModelModel>> getModels() async {
    if (models.isEmpty) {
      try {
        models = await OpenAI.instance.model.list();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return models;
  }

  static Future<void> speech(String input) async {
    try {
      // The speech request.
      File speechFile = await OpenAI.instance.audio.createSpeech(
        model: "tts-1",
        input: input,
        voice: "onyx",
        responseFormat: OpenAIAudioSpeechResponseFormat.opus,
        outputFileName: DateTime.now().microsecondsSinceEpoch.toString(),
      );

      await Audio.play(speechFile);
    } catch (e) {
      debugPrint('speech ai error: ${e.toString()}');
    }
  }
}