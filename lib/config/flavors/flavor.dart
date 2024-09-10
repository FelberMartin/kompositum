import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/ui_string.dart';
import 'package:kompositum/util/my_share.dart';


abstract class Flavor {
  static late Flavor instance;

  static void init() {
    const String? appFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR') != '' ?
    String.fromEnvironment('FLUTTER_APP_FLAVOR') : null;

    switch (appFlavor) {
      case 'en':
        instance = _FlavorEn();
        break;
      case 'de':
        instance = _FlavorDe();
        break;
      default:
        instance = _FlavorDe();
    }
  }

  UiString get uiString;

  abstract String appTitle;
  abstract Locale locale;

  abstract String storeAppName;
  abstract String playStoreLink;
  abstract String appStoreLink;
}

class _FlavorDe extends Flavor {

  UiString get uiString => UiStringDe(this);
  String appTitle = "Wort + Schatz";
  Locale locale = const Locale('de', 'DE');

  String storeAppName = MyShare.deStoreAppName;
  String playStoreLink = MyShare.dePlayStoreUrl;
  String appStoreLink = MyShare.deAppStoreUrl;

}

class _FlavorEn extends Flavor {

    UiString get uiString => UiStringEn(this);
    String appTitle = "Word + Treasure";
    Locale locale = const Locale('en', 'US');

    String storeAppName = MyShare.enStoreAppName;
    String playStoreLink = MyShare.enPlayStoreUrl;
    String appStoreLink = MyShare.enAppStoreUrl;

}