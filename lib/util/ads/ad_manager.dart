import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/common/playholder_ad.dart';

class AdManager {
  Future<void> showAd(BuildContext context) async {
    final Completer<void> adClosed = Completer<void>();
    final adWidget = PlaceholderAd(completer: adClosed);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PopScope(canPop: false, child: adWidget),
      ),
    );

    return adClosed.future;
  }
}
