import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kompositum/util/ads/ad_mob_ad_source.dart';
import 'package:kompositum/util/ads/placeholder_ad_ad_source.dart';

import 'ad_source.dart';

class AdManager {

  AdSource adMob = AdMobAdSource();
  AdSource placeholderAd = PlaceholderAdAdSource();

  AdManager() {
    adMob.loadAd();
  }

  Future<void> showAd(BuildContext context) async {
    try {
      await adMob.showAd(context);
    } catch (e) {
      print(e);
      // If the AdMob ad failed to show (eg ad not loaded, no internet connection),
      // show the placeholder ad.
      if (context.mounted) {
        await placeholderAd.showAd(context);
      }
    }

    // Try to load the next ad
    adMob.loadAd();
  }
}


