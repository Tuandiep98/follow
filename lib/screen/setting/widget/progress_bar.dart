import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final int totalMilliseconds;
  final int current;

  const ProgressBar({
    super.key,
    required this.current,
    required this.totalMilliseconds,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool determinate = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      value: 0,
      // value:
      //     widget.current == 0 ? 0 : widget.current / widget.totalMilliseconds,
      duration: Duration(milliseconds: widget.totalMilliseconds),
    )..addListener(() {
        setState(() {});
      });

    // if (widget.current != 0) {
    //   controller.addListener(() {
    //     setState(() {});
    //   });
    // }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Convert milliseconds to MM:SS format
  String millisToMinutesSeconds(int milliseconds) {
    int minutes = (milliseconds / (1000 * 60)).floor();
    int seconds = ((milliseconds / 1000) % 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: determinate ? controller.value : null,
    );
  }
}
