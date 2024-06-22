import 'package:flutter/material.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';

import '../../../common/my_dialog.dart';

void main() => runApp(MaterialApp(
  theme: myTheme,
  home: MissingCompoundTutorialDialog(),
));


class MissingCompoundTutorialDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "💡 Fehlende Wörter",
      child: Column(
        children: [
          Text(
            "Hast du ein richtiges Wort kombiniert, aber es wird nicht aktzeptiert?",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Icon(
            MyIcons.report,
            size: 50,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(height: 40),
          Text(
            "Du kannst diese Wörter melden und wir kümmern uns darum!",
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