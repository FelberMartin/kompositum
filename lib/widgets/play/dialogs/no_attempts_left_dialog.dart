import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/util/corner_radius.dart';

import '../../../config/my_icons.dart';
import '../../../config/my_theme.dart';
import '../../common/my_dialog.dart';

// Preview the dialog:
void main() =>
    runApp(MaterialApp(theme: myTheme, home: NoAttemptsLeftDialog(onActionPressed: (action) {}, isHintAvailable: true, hintCost: 55,)));

enum NoAttemptsLeftDialogAction {
  hint,
  restart;
}

class NoAttemptsLeftDialog extends StatelessWidget {
  const NoAttemptsLeftDialog({
    super.key,
    required this.onActionPressed,
    required this.isHintAvailable,
    required this.hintCost,
  });

  final Function(NoAttemptsLeftDialogAction) onActionPressed;
  final bool isHintAvailable;
  final int hintCost;

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: Flavor.instance.uiString.ttlNoAttemptsLeft,
      child: Column(
        children: [
          OptionCard(
            icon: MyIcons.hint,
            iconSubtitleText: "$hintCost",
            iconSubtitleIcon: MyIcons.star,
            actionText: Flavor.instance.uiString.btnContinueWithHint,
            onActionPressed: () { onActionPressed(NoAttemptsLeftDialogAction.hint); },
            isEnabled: isHintAvailable,
            roundTop: true,
          ),
          SizedBox(height: 8),
          OptionCard(
            icon: FontAwesomeIcons.redo,
            iconSubtitleText: Flavor.instance.uiString.lblAd,
            iconSubtitleIcon: MyIcons.ad,
            actionText: Flavor.instance.uiString.btnRestartGame,
            onActionPressed: () { onActionPressed(NoAttemptsLeftDialogAction.restart); },
            roundBottom: true,
          ),
        ],
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.icon,
    required this.iconSubtitleText,
    required this.iconSubtitleIcon,
    required this.actionText,
    required this.onActionPressed,
    this.isEnabled = true,
    this.roundTop = false,
    this.roundBottom = false,
  });

  final IconData icon;
  final String iconSubtitleText;
  final IconData iconSubtitleIcon;
  final String actionText;
  final Function onActionPressed;
  final bool isEnabled;

  final bool roundTop;
  final bool roundBottom;

  @override
  Widget build(BuildContext context) {
    final isHintOption = icon == MyIcons.hint;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundTop ? CornerRadius.large : 0),
          bottom: Radius.circular(roundBottom ? CornerRadius.large : 0),
        ),
      ),
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 42,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          iconSubtitleText,
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: MyColorPalette.of(context).textSecondary,
                          ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                          iconSubtitleIcon,
                          size: isHintOption ? 14 : 18,
                          color: isHintOption
                              ? MyColorPalette.of(context).star
                              : MyColorPalette.of(context).textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MyPrimaryTextButton(
              enabled: isEnabled,
              onPressed: () => onActionPressed(),
              text: actionText,
            ),
            SizedBox(height: 5),
          ],
        ),
      )
    );
  }
}
