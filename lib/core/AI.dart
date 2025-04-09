import 'package:flutter/material.dart';
import 'package:follow/env/env.dart';
import 'package:openai_dart/openai_dart.dart';

class AI {
  static final client = OpenAIClient(apiKey: Env.apiKey);

  static Future<void> speech(String input) async {
    try {
      // final stream = TTSServiceWeb(Env.apiKey).tts(
      //   'https://api.openai.com/v1/audio/speech',
      //   {
      //     'model': 'tts-1',
      //     'voice': 'onyx',
      //     'speed': 1.0,
      //     'input': input,
      //     'response_format': 'pcm',
      //     'stream': true,
      //   },
      // );

      // final currentSound = SoLoud.instance.setBufferStream(
      //   maxBufferSizeBytes: 1024 * 1024 * 5,
      //   channels: Channels.mono,
      //   format: BufferType.s16le,
      //   onBuffering: (isBuffering, handle, time) async {
      //     debugPrint('isBuffering: $isBuffering handle: $handle, time: $time');
      //   },
      // );

      // int chunkNumber = 0;
      // stream.listen((chunk) async {
      //   try {
      //     SoLoud.instance.addAudioDataStream(
      //       currentSound,
      //       chunk,
      //     );
      //     if (chunkNumber == 0) {
      //       await SoLoud.instance.play(currentSound);
      //     }
      //     chunkNumber++;
      //     // print('chunk number: $chunkNumber');
      //     // print('chunk length: ${chunk.length}');
      //   } on SoLoudPcmBufferFullCppException {
      //     debugPrint('pcm buffer full or stream already set '
      //         'to be ended');
      //   } catch (e) {
      //     debugPrint(e.toString());
      //   }
      // }, onDone: () {
      //   SoLoud.instance.setDataIsEnded(currentSound);
      // });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}
