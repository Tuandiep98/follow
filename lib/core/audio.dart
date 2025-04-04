import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Audio {
  static final AudioPlayer player = AudioPlayer();
  static String sourcePath = '';

  static Future<void> play(File file) async {
    try {
      await player.setAudioSource(AudioSource.file(file.path));
      await player.play();
    } catch (e) {
      debugPrint('audio error: ${e.toString()}');
    }
  }

  static Future<void> test() async {
    try {
      player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
        ),
      );
      await player.play();
      print('Player result:');
    } catch (e) {
      print('Error in AudioPlayer: $e');
    }
  }
}
