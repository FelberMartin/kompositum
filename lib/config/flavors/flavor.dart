import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/ui_string.dart';


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
}

class _FlavorDe extends Flavor {

  String appTitle = "Wort + Schatz";
  Locale locale = const Locale('de', 'DE');

  UiString get uiString => UiStringDe();

}

class _FlavorEn extends Flavor {
    String appTitle = "Word + Treasure";
    Locale locale = const Locale('en', 'US');

    UiString get uiString => UiStringEn();
}