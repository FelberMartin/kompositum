
import 'package:flutter/material.dart';
import 'package:kompositum/config/my_theme.dart';

import '../../config/my_icons.dart';

class AdManager {

  Future<void> showAd(BuildContext context) async {
    // TODO: Implement real ads
    return _placeholderAd(context);
  }

  Future<void> _placeholderAd(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: MyColorPalette.of(context).background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MyIcons.ad, size: 100, color: MyColorPalette.of(context).primary,),
                  Text('Placeholder Ad'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 5));
    Navigator.of(context).pop();
  }
}