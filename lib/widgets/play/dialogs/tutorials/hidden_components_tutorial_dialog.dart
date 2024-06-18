import 'package:flutter/material.dart';
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
      title: "💡 Verdeckte Wörter",
      child: Column(
        children: [
          Text(
            "Verdeckte Wörter werden erst sichtbar, wenn du andere Wörter richtig kombinierst!",
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