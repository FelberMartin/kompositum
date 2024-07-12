import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_runtime_env/flutter_runtime_env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/ads/ad_mod/rewarded_ad_mod_ad_source.dart';
import 'package:kompositum/util/ads/ad_source.dart';
import 'package:kompositum/util/app_version_provider.dart';

import 'interstitial_ad_mob_ad_source.dart';


abstract class AdMobAdSource extends AdSource {

  /// This is a interstitial ad
  static String restartLevelAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7511009658166869/8610435720'
      : 'ca-app-pub-7511009658166869/8711463337';

  /// This is a rewarded ad
  static String playPastDailyChallengeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7511009658166869/7259833216'
      : 'ca-app-pub-7511009658166869/2205231907';

  factory AdMobAdSource.fromAdContext(AdContext adContext) {
    switch (adContext) {
      case AdContext.restartLevel:
        return InterstitialAdMobAdSource(restartLevelAdUnitId);
      case AdContext.playPastDailyChallenge:
        return RewardedAdMobAdSource(playPastDailyChallengeAdUnitId);
    }
  }

  /// The ad to show. This is `null` until the ad is actually loaded.
  @protected
  Ad? ad;
  late Future<String> _adUnitId;

  AdMobAdSource() {
    _adUnitId = _getAdUnitId();
  }

  Future<String> _getAdUnitId() async {
    if (await _shouldShowTestAd()) {
      return getTestAdUnitId();
    }
    return getRealAdUnitId();
  }

  Future<bool> _shouldShowTestAd() async {
    // Show test ad if the app is not built with release mode (development or profile mode)
    if (!isBuiltWithReleaseMode) {
      return true;
    }

    // Show test ad if the app is run in the Prelaunch report in the PlayConsole.
    return inFirebaseTestLab();
  }

  @protected
  String getTestAdUnitId();

  @protected
  String getRealAdUnitId();

  @override
  Future<void> loadAd() async {
    final adUnitId = await _adUnitId;
    disposeAd();  // Dispose the old ad if it exists
    await loadConcreteAd(adUnitId);
  }

  @protected
  Future<void> loadConcreteAd(String adUnitId);

  @override
  Future<void> showAd(BuildContext context) {
    if (ad == null) {
      return Future.error('Ad not loaded');
    }
    return showConcreteAd();
  }

  Future<void> showConcreteAd();

  @override
  void disposeAd() {
    ad?.dispose();
    ad = null;
  }
}


