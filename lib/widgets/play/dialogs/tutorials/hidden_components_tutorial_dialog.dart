import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../../../common/my_dialog.dart';

void main() => runApp(MaterialApp(
  theme: myTheme,
  home: HiddenComponentsTutorialDialog(),
));


class HiddenComponentsTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: Flavor.instance.uiString.ttlHiddenComponents,
      child: Column(
        children: [
          Text(
            Flavor.instance.uiString.lblHiddenComponentsDescription,
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