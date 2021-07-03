import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "YOUR-CODE";
    } else if (Platform.isIOS) {
      return "YOUR-CODE";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
