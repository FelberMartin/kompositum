import 'dart:async';

import 'package:flutter/widgets.dart';


abstract class AdSource {

  Future<void> loadAd();

  Future<void> showAd(BuildContext context);

  void disposeAd();
}