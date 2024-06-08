import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_runtime_env/flutter_runtime_env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/ads/ad_source.dart';
import 'package:kompositum/util/app_version_provider.dart';


class AdMobAdSource extends AdSource {

  /// Test ad unit ID. This should always be used in development.
  static String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static String restartLevelAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7511009658166869/3512159894'
      : 'TODO'; // TODO iOS

  static String playPastDailyChallengeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7511009658166869/7259833216'
      : 'TODO'; // TODO iOS

  /// The reward ad to show. This is `null` until the ad is actually loaded.
  RewardedAd? _rewardedAd;

  late Future<String> _adUnitId;

  AdMobAdSource(AdContext adContext) {
    _adUnitId = _getAdUnitId(adContext);
  }

  Future<String> _getAdUnitId(AdContext adContext) async {
    if (await _shouldShowTestAd()) {
      return testAdUnitId;
    }

    switch (adContext) {
      case AdContext.restartLevel:
        return restartLevelAdUnitId;
      case AdContext.playPastDailyChallenge:
        return playPastDailyChallengeAdUnitId;
    }
  }

  Future<bool> _shouldShowTestAd() async {
    // Show test ad if the app is not built with release mode (development or profile mode)
    if (!isBuiltWithReleaseMode) {
      return true;
    }

    // Show test ad if the app is run in the Prelaunch report in the PlayConsole.
    return inFirebaseTestLab();
  }

  @override
  Future<void> loadAd() async {
    final adUnitId = await _adUnitId;
    disposeAd();
    return RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  debugPrint(err.toString());
                  disposeAd();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  disposeAd();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }

  @override
  Future<void> showAd(BuildContext context) {
    if (_rewardedAd == null) {
      return Future.error('Ad not loaded');
    }
    final completer = Completer<void>();
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      completer.complete();
    });
    return completer.future;
  }

  @override
  void disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

}