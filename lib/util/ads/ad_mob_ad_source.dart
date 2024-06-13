import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_runtime_env/flutter_runtime_env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kompositum/util/ads/ad_manager.dart';
import 'package:kompositum/util/ads/ad_source.dart';
import 'package:kompositum/util/app_version_provider.dart';


abstract class AdMobAdSource extends AdSource {

  /// This is a interstitial ad
  static String restartLevelAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7511009658166869/8610435720'
      : 'TODO'; // TODO iOS

  /// This is a rewarded ad
  static String playPastDailyChallengeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-7511009658166869/7259833216'
      : 'TODO'; // TODO iOS

  factory AdMobAdSource.fromAdContext(AdContext adContext) {
    switch (adContext) {
      case AdContext.restartLevel:
        return InterstitialAdMobAdSource(restartLevelAdUnitId);
      case AdContext.playPastDailyChallenge:
        return RewardedAdMobAdSource(playPastDailyChallengeAdUnitId);
    }
  }

  /// The ad to show. This is `null` until the ad is actually loaded.
  Ad? _ad;
  late Future<String> _adUnitId;


  AdMobAdSource() {
    _adUnitId = _getAdUnitId();
  }

  Future<String> _getAdUnitId() async {
    if (await _shouldShowTestAd()) {
      return _getTestAdUnitId();
    }
    return _getRealAdUnitId();
  }

  Future<bool> _shouldShowTestAd() async {
    // Show test ad if the app is not built with release mode (development or profile mode)
    if (!isBuiltWithReleaseMode) {
      return true;
    }

    // Show test ad if the app is run in the Prelaunch report in the PlayConsole.
    return inFirebaseTestLab();
  }

  String _getTestAdUnitId();
  String _getRealAdUnitId();

  @override
  Future<void> loadAd() async {
    final adUnitId = await _adUnitId;
    disposeAd();
    await _loadAd(adUnitId);
  }

  Future<void> _loadAd(String adUnitId);

  @override
  Future<void> showAd(BuildContext context) {
    if (_ad == null) {
      return Future.error('Ad not loaded');
    }
    return _showAd();
  }

  Future<void> _showAd();

  @override
  void disposeAd() {
    _ad?.dispose();
    _ad = null;
  }
}


class InterstitialAdMobAdSource extends AdMobAdSource {

  static String testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  final String adUnitId;
  late Completer<void> _adDismissed;

  InterstitialAdMobAdSource(this.adUnitId);

  @override
  String _getTestAdUnitId() => testInterstitialAdUnitId;
  @override
  String _getRealAdUnitId() => adUnitId;

  @override
  Future<void> _loadAd(String adUnitId) {
    _adDismissed = Completer<void>();
    return InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  _adDismissed.complete();
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _ad = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));

  }

  @override
  Future<void> _showAd() {
    (_ad as InterstitialAd).show();
    return _adDismissed.future;
  }
}


class RewardedAdMobAdSource extends AdMobAdSource {

  /// Test ad unit ID. This should always be used in development.
  static String testRewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  final String adUnitId;

  RewardedAdMobAdSource(this.adUnitId);

  @override
  String _getTestAdUnitId() => testRewardedAdUnitId;

  @override
  String _getRealAdUnitId() => adUnitId;

  @override
  Future<void> _loadAd(String adUnitId) {
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
            _ad = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }

  @override
  Future<void> _showAd() {
    final completer = Completer<void>();
    (_ad as RewardedAd).show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      completer.complete();
    });
    return completer.future;
  }
}