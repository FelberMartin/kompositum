import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';


void main() => runApp(MaterialApp(
  theme: myTheme,
  home: PreRedesignUpdateDialog(),
));


class PreRedesignUpdateDialog extends StatelessWidget {
  const PreRedesignUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "💡 Demnächst: Redesign!",
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(
              style: Theme.of(context).textTheme.labelLarge,
              children: <TextSpan>[
                new TextSpan(text: "Innerhalb der nächsten Wochen bekommt die App ein "),
                new TextSpan (
                    text: "visuelles Update ",
                    style: new TextStyle(
                      color: MyColorPalette.of(context).primaryShade,
                    )
                ),
                new TextSpan(text: ", hin zu einem einheitlicheren, moderneren Look!"),
              ],
            ),
          ),
          SizedBox(height: 48),
          // TODO: insert new app icon
          SvgPicture.asset(
            MyIcons.treasureChestClosedSvg,
            width: 64,
          ),
          SizedBox(height: 48),
          Text(
            "Halte einfach Ausschau nach dem neuen App-Icon!",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48),
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