import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        title: "Vergangenes tägliches Rätsel!",
        subtitle: "Aber keine Sorge, du kannst es noch nachholen!",
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
                    size: 14,
                    color: MyColorPalette.of(context).star,
                  ),
                ),
            ),
            const SizedBox(height: 4),
            MySecondaryTextButton(
                onPressed: () {
                  _close(context, PlayPastDailyDialogResult.playWithAd);
                },
                text: "Werbung",
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