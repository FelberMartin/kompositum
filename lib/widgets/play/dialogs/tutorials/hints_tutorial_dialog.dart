import 'package:flutter/material.dart';
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
      title: "💡 Tipps",
      child: Column(
        children: [
          Text(
            "Wenn du Hilfe brauchst und nicht mehr weiter weißt, benutze einen Tipp!",
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
            "Probier es einfach aus, der erste Tipp geht aufs Haus!",
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