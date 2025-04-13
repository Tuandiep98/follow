import 'package:flutter/foundation.dart';

class PlatformUtil {
  static final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);
  static int getScalePoint(double sizeWidth) {
    if (sizeWidth > 1450) {
      return 4;
    } else if (sizeWidth > 900 && sizeWidth <= 1450) {
      return 3;
    } else if (sizeWidth > 551 && sizeWidth <= 900) {
      return 2;
    } else {
      return 1;
    }
  }
}
