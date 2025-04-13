import 'package:flutter/material.dart';
import 'package:follow/core/platform_util.dart';
import 'package:follow/screen/flutter_lyric/lyric_ui/lyric_ui.dart';

///Sample Netease style
///should be extends LyricUI implementation your own UI.
///this property only for change UI,if not demand just only overwrite methods.
class UINetease extends LyricUI {
  double defaultSize;
  double defaultExtSize;
  double otherMainSize;
  double bias;
  double lineGap;
  double inlineGap;
  LyricAlign lyricAlign;
  LyricBaseLine lyricBaseLine;
  bool highlight;
  HighlightDirection highlightDirection;

  UINetease(
      {this.defaultSize = 24,
      this.defaultExtSize = 18,
      this.otherMainSize = 22,
      this.bias = 0.5,
      this.lineGap = 25,
      this.inlineGap = 25,
      this.lyricAlign = LyricAlign.CENTER,
      this.lyricBaseLine = LyricBaseLine.CENTER,
      this.highlight = true,
      this.highlightDirection = HighlightDirection.LTR});

  UINetease.clone(UINetease uiNetease)
      : this(
          defaultSize: uiNetease.defaultSize,
          defaultExtSize: uiNetease.defaultExtSize,
          otherMainSize: uiNetease.otherMainSize,
          bias: uiNetease.bias,
          lineGap: uiNetease.lineGap,
          inlineGap: uiNetease.inlineGap,
          lyricAlign: uiNetease.lyricAlign,
          lyricBaseLine: uiNetease.lyricBaseLine,
          highlight: uiNetease.highlight,
          highlightDirection: uiNetease.highlightDirection,
        );

  @override
  TextStyle getPlayingExtTextStyle() => TextStyle(
        color: Colors.grey[300],
        fontSize: defaultExtSize,
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w900,
      );

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
        color: Colors.grey[400],
        fontSize: defaultExtSize,
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w900,
      );

  @override
  TextStyle getOtherMainTextStyle() => TextStyle(
        color: Colors.grey[300],
        fontSize: otherMainSize,
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w900,
        shadows: <Shadow>[
          Shadow(
            offset: Offset(0.2, 0.5),
            blurRadius: 0.5,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      );

  @override
  TextStyle getPlayingMainTextStyle({Size? size}) => TextStyle(
        color: Colors.grey.shade300,
        fontSize: size == null
            ? defaultSize
            : (PlatformUtil.getScalePoint(size.width) * defaultSize),
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w900,
        shadows: <Shadow>[
          Shadow(
            offset: Offset(0.2, 0.5),
            blurRadius: 0.5,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ],
      );

  @override
  double getInlineSpace() => inlineGap;

  @override
  double getLineSpace() => lineGap;

  @override
  double getPlayingLineBias() => bias;

  @override
  LyricAlign getLyricHorizontalAlign() => lyricAlign;

  @override
  LyricBaseLine getBiasBaseLine() => lyricBaseLine;

  @override
  bool enableHighlight() => highlight;

  @override
  HighlightDirection getHighlightDirection() => highlightDirection;
}
