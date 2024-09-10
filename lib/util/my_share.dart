import 'package:kompositum/config/flavors/flavor.dart';
import 'package:share_plus/share_plus.dart';

class MyShare {

  static const String deStoreAppName = 'Wort + Schatz: Wörter Suche';
  static const String dePlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.development_felber.compose';
  static const String deAppStoreUrl = 'https://apps.apple.com/de/app/wort-schatz-w%C3%B6rter-suche/id6526461190';

  static const String enStoreAppName = 'Word + Treasure: Word Search'; // TODO: english
  static const String enPlayStoreUrl = 'todo';    // TODO: english
  static const String enAppStoreUrl = 'todo';     // TODO: english

  static Future<void> shareApp() {
    return Share.share(Flavor.instance.uiString.shareText);
  }
}