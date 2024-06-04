import 'dart:async';

import 'package:flutter/widgets.dart';


abstract class AdSource {

  Future<void> loadAd();

  void showAd(BuildContext context, Completer<void> completer);

  void disposeAd();
}