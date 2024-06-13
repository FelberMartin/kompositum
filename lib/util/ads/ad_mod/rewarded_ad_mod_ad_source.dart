
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_mob_ad_source.dart';

class RewardedAdMobAdSource extends AdMobAdSource {

  /// Test ad unit ID. This should always be used in development.
  static String testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  final String adUnitId;

  RewardedAdMobAdSource(this.adUnitId);

  @override
  String getTestAdUnitId() => testRewardedAdUnitId;

  @override
  String getRealAdUnitId() => adUnitId;

  @override
  Future<void> loadConcreteAd(String adUnitId) {
    return RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (loadedAd) {
            loadedAd.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (_ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (_ad, err) {
                  debugPrint(err.toString());
                  disposeAd();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (_ad) {
                  disposeAd();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$loadedAd loaded.');
            // Keep a reference to the ad so you can show it later.
            ad = loadedAd;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }

  @override
  Future<void> showConcreteAd() {
    final completer = Completer<void>();
    (ad as RewardedAd).show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      completer.complete();
    });
    return completer.future;
  }
}