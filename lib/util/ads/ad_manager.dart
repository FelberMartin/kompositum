import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kompositum/util/ads/ad_mob_ad_source.dart';

import 'ad_source.dart';

class AdManager {

  AdSource adSource = AdMobAdSource();

  AdManager() {
    adSource.loadAd();
  }

  Future<void> showAd(BuildContext context) async {
    // TODO: if no internet conenction, show placeholder ad
    final Completer<void> adClosed = Completer<void>();
    adSource.showAd(context, adClosed);
    adClosed.future.then((value) {
      adSource.loadAd();
    });
    return adClosed.future;
  }
}


