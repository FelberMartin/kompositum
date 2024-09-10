import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';

import '../../../config/my_icons.dart';
import '../../../config/my_theme.dart';


enum PlayPastDailyDialogResult {
  playWithStars,
  playWithAd,
}

void main() {
  runApp(MaterialApp(
    theme: myTheme,
    home: PlayPastDailyDialog(hasEnoughStars: true),
  ));
}

class PlayPastDailyDialog extends StatelessWidget {

  const PlayPastDailyDialog({
    required this.hasEnoughStars,
    super.key,
  });

  final bool hasEnoughStars;

  void _close(BuildContext context, PlayPastDailyDialogResult result) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return MyDialog(
        title: Flavor.instance.uiString.ttlDialogPlayPastDaily,
        subtitle: Flavor.instance.uiString.lblDialogPlayPastDailySubtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            MySecondaryTextButton(
                onPressed: () {
                  _close(context, PlayPastDailyDialogResult.playWithStars);
                },
                enabled: hasEnoughStars,
                text: "${Costs.pastDailyCost}",
                trailingIcon: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Icon(
                    MyIcons.star,
                    color: MyColorPalette.of(context).star,
                    size: 16,
                  ),
                ),
            ),
            const SizedBox(height: 4),
            MySecondaryTextButton(
                onPressed: () {
                  _close(context, PlayPastDailyDialogResult.playWithAd);
                },
                text: Flavor.instance.uiString.lblAd,
                trailingIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    MyIcons.ad,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
            )
          ]
        ),
    );
  }
}