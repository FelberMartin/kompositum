import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kompositum/util/ads/ad_source.dart';


class AdMobAdSource extends AdSource {

  /// The reward ad to show. This is `null` until the ad is actually loaded.
  RewardedAd? _rewardedAd;

  // TODO: replace this test ad unit with your own ad unit.
  // TODO: add mechanism to dont show ads in dev mode
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';


  @override
  Future<void> loadAd() {
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