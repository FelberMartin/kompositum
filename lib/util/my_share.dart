import 'package:share_plus/share_plus.dart';

class MyShare {

  static const String appName = 'Wort + Schatz: Wörter Suche';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.development_felber.compose';
  static const String appStoreUrl = 'https://apps.apple.com/app/wort-schatz-w%C3%B6rter-suche/id6526461190';

  static Future<void> shareApp() {
    final shareText = "Entdecke jetzt meine neue Lieblings-App '$appName'!\n\n"
        "Android: $playStoreUrl\niOS: $appStoreUrl";
    return Share.share(shareText);
  }
}