// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:whisper_flutter_new/whisper_flutter_new.dart';

// class WhisperNew {
//   // Begin whisper transcription
//   /// China: https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main
//   /// Other: https://huggingface.co/ggerganov/whisper.cpp/resolve/main
//   static final Whisper whisper = Whisper(
//       model: WhisperModel.base,
//       downloadHost:
//           "https://huggingface.co/ggerganov/whisper.cpp/resolve/main");

//   static Future<void> transcribe() async {
//     try {
//       debugPrint('start\n');
//       final Stopwatch _stopwatch = Stopwatch()..start();
//       // Prepare wav file
//       final Directory documentDirectory =
//           await getApplicationDocumentsDirectory();
//       final ByteData documentBytes = await rootBundle.load('assets/jfk.wav');

//       final String jfkPath = '${documentDirectory.path}/jfk.wav';

//       await File(jfkPath).writeAsBytes(
//         documentBytes.buffer.asUint8List(),
//       );
//       var transcription = await whisper.transcribe(
//         transcribeRequest: TranscribeRequest(
//           audio: jfkPath,
//           isTranslate: false,
//           isNoTimestamps: false,
//           splitOnWord: false,
//         ),
//       );
//       debugPrint('take: ${_stopwatch.elapsed.inSeconds}seconds.');
//       _stopwatch.stop();
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
// }
