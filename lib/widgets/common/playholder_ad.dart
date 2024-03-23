import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/my_icons.dart';
import '../../config/my_theme.dart';
import 'my_3d_container.dart';
import 'my_buttons.dart';
import 'my_icon_button.dart';

void main() {
  runApp(MaterialApp(theme: myTheme, home: PlaceholderAd(completer: Completer(),),));
}

class PlaceholderAd extends StatefulWidget {
  final Completer<void> completer;

  const PlaceholderAd({super.key, required this.completer});

  @override
  State<PlaceholderAd> createState() => _PlaceholderAdState();
}

class _PlaceholderAdState extends State<PlaceholderAd> {
  int secondsLeft = 12;

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
                  cornerRadius: 24,
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
                        new TextSpan(text: "Dir gefällt "),
                        new TextSpan(
                            text: "Wortschatz",
                            style: new TextStyle(
                                color: MyColorPalette.of(context).primaryShade,
                            )),
                        new TextSpan(text: "?"),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  Image(
                    image: AssetImage('assets/images/app_icon/fg_cropped.png'),
                    height: 200,
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                      width: 200,
                      child: Text(
                        "Dann empfehle es deinen Freunden!",
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      )
                  ),
                  Expanded(child: Container()),
                  FittedBox(
                    child: MyPrimaryTextButton(
                      text: "Teilen",
                      leadingIcon: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          MyIcons.share,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        Share.share("Entdecke jetzt meine neue Lieblings-App 'Wortschatz - Wörter Suche': https://play.google.com/store/apps/details?id=com.development_felber.compose");
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