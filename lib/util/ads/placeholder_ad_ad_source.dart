import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/util/ads/ad_source.dart';
import 'package:kompositum/util/my_share.dart';
import 'package:kompositum/widgets/common/util/corner_radius.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/my_icons.dart';
import '../../config/my_theme.dart';
import '../../widgets/common/my_3d_container.dart';
import '../../widgets/common/my_buttons.dart';
import '../../widgets/common/my_icon_button.dart';

void main() {
  runApp(MaterialApp(theme: myTheme, home: _PlaceholderAd(completer: Completer(),),));
}


class PlaceholderAdAdSource extends AdSource {
  @override
  Future<void> loadAd() {
    // Nothing to do
    return Future.value();
  }

  @override
  Future<void> showAd(BuildContext context) {
    final Completer<void> completer = Completer<void>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PopScope(
              canPop: false,
              child: _PlaceholderAd(completer: completer)
            ),
      ),
    );
    return completer.future;
  }

  @override
  void disposeAd() {
    // Do nothing
  }
}

class _PlaceholderAd extends StatefulWidget {
  final Completer<void> completer;

  const _PlaceholderAd({super.key, required this.completer});

  @override
  State<_PlaceholderAd> createState() => _PlaceholderAdState();
}

class _PlaceholderAdState extends State<_PlaceholderAd> {
  static const PLAYHOLDER_AD_DURATION_SECONDS = 12;
  int secondsLeft = PLAYHOLDER_AD_DURATION_SECONDS;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _countDown);
  }

  void _countDown() {
    if (secondsLeft > 0) {
      setState(() {
        secondsLeft--;
      });
      Future.delayed(const Duration(seconds: 1), _countDown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = "assets/images/app_icon/app_icon_rounded_corners.png";
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: secondsLeft > 0
                    ? My3dContainer(
                  topColor: Theme.of(context).colorScheme.secondary,
                  sideColor: MyColorPalette.of(context).secondaryShade,
                  clickable: false,
                  cornerRadius: CornerRadius.rounded,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Center(
                      child: Text(
                        "$secondsLeft",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: MyColorPalette.of(context).textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                    : MyIconButton(
                  icon: MyIcons.close,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.completer.complete();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Expanded(flex: 2, child: Container()),
                  RichText(
                    textAlign: TextAlign.center,
                    text: new TextSpan(
                      style: Theme.of(context).textTheme.titleMedium,
                      children: <TextSpan>[
                        new TextSpan(text: Flavor.instance.uiString.lblDoYouEnjoy + "\n"),
                        new TextSpan(
                            text: Flavor.instance.appTitle,
                            style: new TextStyle(
                                color: MyColorPalette.of(context).primaryShade,
                            )),
                        new TextSpan(text: "?"),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow.withOpacity(0.5),
                          offset: Offset(2, 4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                      width: 200,
                      child: Text(
                        Flavor.instance.uiString.lblThenTellYourFriends,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      )
                  ),
                  Expanded(child: Container()),
                  FittedBox(
                    child: MyPrimaryTextButton(
                      text: Flavor.instance.uiString.btnShare,
                      leadingIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          MyIcons.share,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        MyShare.shareApp();
                      },
                    ),
                  ),
                  Expanded(flex: 3, child: Container()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}