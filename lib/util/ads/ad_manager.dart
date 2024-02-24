import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_3d_container.dart';

import '../../config/my_icons.dart';
import '../../widgets/common/my_icon_button.dart';

class AdManager {
  Future<void> showAd(BuildContext context) async {
    final Completer<void> adClosed = Completer<void>();
    final adWidget = PlaceholderAd(completer: adClosed);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            WillPopScope(onWillPop: () async => false, child: adWidget),
      ),
    );

    return adClosed.future;
  }
}

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
                  Expanded(flex: 4, child: Container()),
                  Text("Dir gefällt das Spiel?",
                      style: Theme.of(context).textTheme.titleMedium),
                  Expanded(child: Container()),
                  Image(
                    image: AssetImage('assets/app_icon_fg.png'),
                    height: 280,
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                    width: 200,
                    child: RichText(
                      text: new TextSpan(
                        style: Theme.of(context).textTheme.titleMedium,
                        children: <TextSpan>[
                          new TextSpan(text: "Dann "),
                          new TextSpan(
                              text: "empfehle",
                              style: new TextStyle(
                                  color: MyColorPalette.of(context).primary)),
                          new TextSpan(text: " es deinen Freunden!"),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 5, child: Container()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
