import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../../../common/my_dialog.dart';

void main() => runApp(MaterialApp(
  theme: myTheme,
  home: HintsTutorialDialog(),
));


class HintsTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: Flavor.instance.uiString.ttlHints,
      child: Column(
        children: [
          Text(
            Flavor.instance.uiString.lblHintsDescription,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Icon(
            MyIcons.hint,
            size: 50,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(height: 40),
          Text(
            Flavor.instance.uiString.lblHintsTryIt,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          FittedBox(
            child: MyPrimaryTextButton(
                text: Flavor.instance.uiString.btnGotIt,
                onPressed: () {
                  Navigator.of(context).pop();
                }
            ),
          )
        ],
      ),
    );
  }
}