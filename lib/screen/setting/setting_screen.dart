import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:follow/core/audio.dart';
import 'package:follow/core/storage_manager.dart';
import 'package:follow/core/string_utils.dart';
import 'package:follow/screen/animated_mesh_gradient_view.dart';
import 'package:follow/screen/flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:follow/screen/flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:follow/screen/flutter_lyric/lyrics_log.dart';
import 'package:follow/screen/flutter_lyric/lyrics_model_builder.dart';
import 'package:follow/screen/flutter_lyric/lyrics_reader_model.dart';
import 'package:follow/screen/flutter_lyric/lyrics_reader_widget.dart';
import 'package:follow/screen/mesh_gradient_view.dart';
import 'package:follow/screen/setting/const.dart';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  AudioPlayer? audioPlayer;
  double sliderProgress = 111658;
  int playProgress = 111658;
  double max_value = 311658;
  bool isTap = false;

  var exampleLyric = '';

  bool useEnhancedLrc = false;
  LyricsReaderModel? lyricModel;

  var lyricUI = UINetease();

  bool _loading = true;

  String filePath = 'assets/music1.mp3';
  String url = '';
  Uint8List? audioBytes;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initData();
      // await WhisperNew.transcribe();
      setState(() {
        _loading = false;
      });
    });

    super.initState();
  }

  Future<void> _initData() async {
    audioBytes = null;
    // url =
    //     'https://cdn303.savetube.su/download-direct/audio/128/576f0afa3ff9fedaf1c7072b6969cc99d79ef8b6';
    String lyrics = '';
    var storageData = StorageManager.readData(url.isEmpty ? filePath : url);
    if (storageData != null) {
      lyrics = StringUtils.convertWordSegmentToLrc(storageData);
      debugPrint('local result: $lyrics');
      lyricModel =
          LyricsModelBuilder.create().bindLyricToMain(lyrics).getModel();

      return;
    }

    if (url.isNotEmpty) {
      audioBytes = await Audio.getOnlineAudioBytes(url);
      if (audioBytes == null) {
        debugPrint('audioBytes is null');
        return;
      }
      var response = await Audio.transcribeAudio(audioBytes!);
      if (response.isNotEmpty) {
        lyrics = StringUtils.convertWordSegmentToLrc(response);
        debugPrint('url result: $lyrics');
        StorageManager.saveData(url, response);
      }
    } else {
      XFile file = XFile(filePath);
      var response = await Audio.transcribeAudio(await file.readAsBytes());
      if (response.isNotEmpty) {
        lyrics = StringUtils.convertWordSegmentToLrc(response);
        debugPrint('file result: $lyrics');
        StorageManager.saveData(filePath, response);
      }
    }

    if (lyrics.isNotEmpty) {
      lyricModel =
          LyricsModelBuilder.create().bindLyricToMain(lyrics).getModel();
    }
  }

  Future<void> _play() async {
    try {
      if (playing) {
        audioPlayer?.pause();
        return;
      }

      if (audioPlayer == null) {
        audioPlayer = AudioPlayer()
          ..play(url.isNotEmpty
              ? UrlSource(url)
              : AssetSource(filePath.replaceAll('assets/', '')));
        setState(() {
          playing = true;
        });
        audioPlayer?.onDurationChanged.listen((Duration event) {
          setState(() {
            max_value = event.inMilliseconds.toDouble();
          });
        });
        audioPlayer?.onPositionChanged.listen((Duration event) {
          if (isTap) return;
          setState(() {
            sliderProgress = event.inMilliseconds.toDouble();
            playProgress = event.inMilliseconds;
          });
        });

        audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
          setState(() {
            playing = state == PlayerState.playing;
          });
        });
      } else {
        audioPlayer?.resume();
      }
    } catch (e) {
      playing = false;
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildContainer(),
    );
  }

  Widget buildContainer() {
    return _loading
        ? Center(
            child: CupertinoActivityIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: buildReaderWidget(),
              ),
              // Expanded(
              //   child: SingleChildScrollView(
              //     child: Column(
              //       children: [
              //         ...buildPlayControl(),
              //         // ...buildUIControl(),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          );
  }

  var lyricPadding = 40.0;

  Stack buildReaderWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ...buildReaderBackground(),
        LyricsReader(
          padding: EdgeInsets.symmetric(horizontal: lyricPadding),
          model: lyricModel,
          position: playProgress,
          lyricUi: lyricUI,
          playing: playing,
          size: Size(double.infinity, double.infinity),
          emptyBuilder: () => Center(
            child: Text(
              "No lyrics",
              style: lyricUI.getOtherMainTextStyle(),
            ),
          ),
          selectLineBuilder: (progress, confirm) {
            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      LyricsLog.logD("点击事件");
                      confirm.call();
                      setState(() {
                        audioPlayer?.seek(Duration(milliseconds: progress));
                      });
                    },
                    icon: Icon(Icons.play_arrow, color: Colors.green)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.green),
                    height: 1,
                    width: double.infinity,
                  ),
                ),
                Text(
                  progress.toString(),
                  style: TextStyle(color: Colors.green),
                )
              ],
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                iconSize: 36,
                color: Colors.white,
                onPressed: () async => await _play(),
                icon: Icon(playing
                    ? Icons.pause_circle_outlined
                    : Icons.play_circle_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> buildPlayControl() {
    return [
      Container(
        height: 20,
      ),
      Text(
        "Progress:$sliderProgress",
        style: TextStyle(
          fontSize: 16,
          color: Colors.green,
        ),
      ),
      if (sliderProgress < max_value)
        Slider(
          min: 0,
          max: max_value,
          label: sliderProgress.toString(),
          value: sliderProgress,
          activeColor: Colors.blueGrey,
          inactiveColor: Colors.blue,
          onChanged: (double value) {
            setState(() {
              sliderProgress = value;
            });
          },
          onChangeStart: (double value) {
            isTap = true;
          },
          onChangeEnd: (double value) {
            isTap = false;
            setState(() {
              playProgress = value.toInt();
            });
            audioPlayer?.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(onPressed: () async => await _play(), child: Text("Play")),
          Container(
            width: 10,
          ),
          TextButton(
              onPressed: () async {
                audioPlayer?.pause();
              },
              child: Text("Pause")),
          Container(
            width: 10,
          ),
          TextButton(
              onPressed: () async {
                audioPlayer?.stop();
                audioPlayer = null;
              },
              child: Text("Stop")),
        ],
      ),
    ];
  }

  var playing = false;

  List<Widget> buildReaderBackground() {
    return [
      Positioned.fill(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          child: playing
              ? const AnimatedMeshGradientView()
              : const MeshGradientView(),
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      )
    ];
  }

  var mainTextSize = 18.0;
  var extTextSize = 16.0;
  var lineGap = 16.0;
  var inlineGap = 10.0;
  var lyricAlign = LyricAlign.CENTER;
  var highlightDirection = HighlightDirection.LTR;

  List<Widget> buildUIControl() {
    return [
      Container(
        height: 30,
      ),
      Text("UI setting", style: TextStyle(fontWeight: FontWeight.bold)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
              value: lyricUI.enableHighlight(),
              onChanged: (value) {
                setState(() {
                  lyricUI.highlight = (value ?? false);
                  refreshLyric();
                });
              }),
          Text("enable highLight"),
          Checkbox(
              value: useEnhancedLrc,
              onChanged: (value) {
                setState(() {
                  useEnhancedLrc = value!;
                  lyricModel = LyricsModelBuilder.create()
                      .bindLyricToMain(value ? advancedLyric : normalLyric)
                      .bindLyricToExt(transLyric)
                      .getModel();
                });
              }),
          Text("use Enhanced lrc")
        ],
      ),
      buildTitle("highlight direction"),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: HighlightDirection.values
            .map(
              (e) => Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Radio<HighlightDirection>(
                        activeColor: Colors.orangeAccent,
                        value: e,
                        groupValue: highlightDirection,
                        onChanged: (v) {
                          setState(() {
                            highlightDirection = v!;
                            lyricUI.highlightDirection = highlightDirection;
                            refreshLyric();
                          });
                        }),
                    Text(e.toString().split(".")[1])
                  ],
                ),
              )),
            )
            .toList(),
      ),
      buildTitle("lyric padding"),
      Slider(
        min: 0,
        max: 100,
        label: lyricPadding.toString(),
        value: lyricPadding,
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.blue,
        onChanged: (double value) {
          setState(() {
            lyricPadding = value;
          });
        },
      ),
      buildTitle("lyric primary text size"),
      Slider(
        min: 15,
        max: 30,
        label: mainTextSize.toString(),
        value: mainTextSize,
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.blue,
        onChanged: (double value) {
          setState(() {
            mainTextSize = value;
          });
        },
        onChangeEnd: (double value) {
          setState(() {
            lyricUI.defaultSize = mainTextSize;
            refreshLyric();
          });
        },
      ),
      buildTitle("lyric secondary text size"),
      Slider(
        min: 15,
        max: 30,
        label: extTextSize.toString(),
        value: extTextSize,
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.blue,
        onChanged: (double value) {
          setState(() {
            extTextSize = value;
          });
        },
        onChangeEnd: (double value) {
          setState(() {
            lyricUI.defaultExtSize = extTextSize;
            refreshLyric();
          });
        },
      ),
      buildTitle("lyric line spacing"),
      Slider(
        min: 10,
        max: 80,
        label: lineGap.toString(),
        value: lineGap,
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.blue,
        onChanged: (double value) {
          setState(() {
            lineGap = value;
          });
        },
        onChangeEnd: (double value) {
          setState(() {
            lyricUI.lineGap = lineGap;
            refreshLyric();
          });
        },
      ),
      buildTitle("primary and secondary lyric spacing"),
      Slider(
        min: 10,
        max: 80,
        label: inlineGap.toString(),
        value: inlineGap,
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.blue,
        onChanged: (double value) {
          setState(() {
            inlineGap = value;
          });
        },
        onChangeEnd: (double value) {
          setState(() {
            lyricUI.inlineGap = inlineGap;
            refreshLyric();
          });
        },
      ),
      buildTitle("select line bias"),
      Slider(
        min: 0.3,
        max: 0.8,
        label: bias.toString(),
        value: bias,
        activeColor: Colors.blueGrey,
        inactiveColor: Colors.blue,
        onChanged: (double value) {
          setState(() {
            bias = value;
          });
        },
        onChangeEnd: (double value) {
          setState(() {
            lyricUI.bias = bias;
            refreshLyric();
          });
        },
      ),
      buildTitle("lyric align"),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: LyricAlign.values
            .map(
              (e) => Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Radio<LyricAlign>(
                        activeColor: Colors.orangeAccent,
                        value: e,
                        groupValue: lyricAlign,
                        onChanged: (v) {
                          setState(() {
                            lyricAlign = v!;
                            lyricUI.lyricAlign = lyricAlign;
                            refreshLyric();
                          });
                        }),
                    Text(e.toString().split(".")[1])
                  ],
                ),
              )),
            )
            .toList(),
      ),
      buildTitle("select line base"),
      Row(
        children: LyricBaseLine.values
            .map((e) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Radio<LyricBaseLine>(
                            activeColor: Colors.orangeAccent,
                            value: e,
                            groupValue: lyricBiasBaseLine,
                            onChanged: (v) {
                              setState(() {
                                lyricBiasBaseLine = v!;
                                lyricUI.lyricBaseLine = lyricBiasBaseLine;
                                refreshLyric();
                              });
                            }),
                        Text(e.toString().split(".")[1])
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    ];
  }

  void refreshLyric() {
    lyricUI = UINetease.clone(lyricUI);
  }

  var bias = 0.5;
  var lyricBiasBaseLine = LyricBaseLine.CENTER;

  Text buildTitle(String title) => Text(title,
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green));
}
