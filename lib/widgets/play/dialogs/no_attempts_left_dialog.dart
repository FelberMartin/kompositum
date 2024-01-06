import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../../../config/theme.dart';
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
      title: "Du hast alle Versuche aufgebraucht!",
      child: Column(
        children: [
          OptionCard(
            icon: FontAwesomeIcons.lightbulb,
            iconSubtitleText: "$hintCost",
            iconSubtitleIcon: FontAwesomeIcons.solidStar,
            actionText: "Mit Tipp fortfahren",
            onActionPressed: () { onActionPressed(NoAttemptsLeftDialogAction.hint); },
            isEnabled: isHintAvailable,
          ),
          SizedBox(height: 16),
          OptionCard(
            icon: FontAwesomeIcons.redo,
            iconSubtitleText: "20s",
            iconSubtitleIcon: FontAwesomeIcons.ad,
            actionText: "Neustarten",
            onActionPressed: () { onActionPressed(NoAttemptsLeftDialogAction.restart); },
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
  });

  final IconData icon;
  final String iconSubtitleText;
  final IconData iconSubtitleIcon;
  final String actionText;
  final Function onActionPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isHintOption = icon == FontAwesomeIcons.lightbulb;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                            color: Theme.of(context).colorScheme.primary
                          ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                          iconSubtitleIcon,
                          size: isHintOption ? 14 : 18,
                          color: isHintOption
                              ? customColors.star
                              : Theme.of(context).colorScheme.primary,
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
