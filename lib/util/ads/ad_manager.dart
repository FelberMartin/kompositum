import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kompositum/util/ads/ad_mob_ad_source.dart';
import 'package:kompositum/util/ads/placeholder_ad_ad_source.dart';

import 'ad_source.dart';


enum AdContext {
  restartLevel,
  playPastDailyChallenge,
}


class AdManager {

  late Map<AdContext, AdSource> adSources;
  AdSource placeholderAd = PlaceholderAdAdSource();

  AdManager({
    required restartLevelAdSource,
    required playPastDailyChallengeAdSource,
  }) {
    adSources = {
      AdContext.restartLevel: restartLevelAdSource,
      AdContext.playPastDailyChallenge: playPastDailyChallengeAdSource,
    };

    adSources.forEach((_, adSource) {
      adSource.loadAd();
    });
  }

  Future<void> showAd(BuildContext context, AdContext adContext) async {
    try {
      await adSources[adContext]!.showAd(context);
    } catch (e) {
      print(e);
      // If the AdMob ad failed to show (eg ad not loaded, no internet connection),
      // show the placeholder ad.
      if (context.mounted) {
        await placeholderAd.showAd(context);
      }
    }

    // Try to load the next ad
    adSources[adContext]!.loadAd();
  }

  void dispose() {
    adSources.forEach((_, adSource) {
      adSource.disposeAd();
    });
    // Placeholder ad does not need to be disposed
  }
}


