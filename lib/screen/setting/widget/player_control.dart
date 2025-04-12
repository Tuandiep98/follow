import 'dart:async';

import 'package:flutter/material.dart';
import 'package:follow/screen/wave_blob/wave_blob.dart';

class PlayerControl extends StatefulWidget {
  final bool playing;
  final Color? color;
  const PlayerControl({
    super.key,
    this.playing = false,
    this.color,
  });

  @override
  State<PlayerControl> createState() => _PlayerControlState();
}

class _PlayerControlState extends State<PlayerControl> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.playing) {
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
          setState(() {});
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      height: 75,
      child: WaveBlob(
        blobCount: widget.playing ? 4 : 1,
        speed: 5,
        amplitude: 14250.0,
        scale: 1.0,
        autoScale: true,
        centerCircle: true,
        overCircle: false,
        circleColors: widget.color != null && widget.playing
            ? [widget.color!]
            : [
                Colors.grey,
              ],
        colors: widget.color != null && widget.playing
            ? [
                widget.color!.withOpacity(.7),
                widget.color!.withOpacity(.4),
                widget.color!.withOpacity(.2),
                widget.color!.withOpacity(.05),
              ]
            : [
                Colors.white.withOpacity(.0001),
                Colors.white.withOpacity(.0001),
              ],
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 25.0,
        ),
      ),
    );
  }
}
