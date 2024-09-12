import 'package:flutter/material.dart';
import 'package:kompositum/config/flavors/flavor.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';


void main() => runApp(MaterialApp(
  theme: myTheme,
  home: ChainModeIntroDialog(),
));


class ChainModeIntroDialog extends StatelessWidget {
  const ChainModeIntroDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: Flavor.instance.uiString.ttlChainNewGameMode,
      child: Column(
        children: [
          Text(
            Flavor.instance.uiString.lblChainNewGameModeDescription,
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Icon(
            MyIcons.chain,
            color: MyColorPalette.of(context).onSecondary,
          ),
          SizedBox(height: 32),
          Text(
            Flavor.instance.uiString.lblChainNewGameModeTryIt,
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