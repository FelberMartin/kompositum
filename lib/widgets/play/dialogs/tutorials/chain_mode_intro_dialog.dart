import 'package:flutter/material.dart';
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
      title: "💡 Neuer Spielmodus: Wortkette!",
      child: Column(
        children: [
          Text(
            "Bei diesem Spielmodus ist das erste Wort gegeben und du musst nur das dazugehörige zweite Wort finden. "
                "Danach geht es immer so weiter und es bildet sich ein lange Wortkette.",
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
            "Probier es einfach aus!",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          FittedBox(
            child: MyPrimaryTextButton(
                text: "Alles klar",
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