import 'dart:io';
class AdHelper{
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1815733895558819/5618253299';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1815733895558819/4876813426';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}