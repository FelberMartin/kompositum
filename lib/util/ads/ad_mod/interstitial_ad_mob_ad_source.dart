
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_mob_ad_source.dart';

class InterstitialAdMobAdSource extends AdMobAdSource {

  static String testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  final String adUnitId;
  late Completer<void> _adDismissed;

  InterstitialAdMobAdSource(this.adUnitId);

  @override
  String getTestAdUnitId() => testInterstitialAdUnitId;
  @override
  String getRealAdUnitId() => adUnitId;

  @override
  Future<void> loadConcreteAd(String adUnitId) {
    _adDismissed = Completer<void>();
    return InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (loadedAd) {
            loadedAd.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (_ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (_ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (_ad, err) {
                  // Dispose the ad here to free resources.
                  _ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (_ad) {
                  // Dispose the ad here to free resources.
                  _adDismissed.complete();
                  _ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$loadedAd loaded.');
            // Keep a reference to the ad so you can show it later.
            ad = loadedAd;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));

  }

  @override
  Future<void> showConcreteAd() {
    (ad as InterstitialAd).show();
    return _adDismissed.future;
  }
}
