import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';


void main() => runApp(MaterialApp(
  theme: myTheme,
  home: DailyGoalsUpdateDialog(),
));


class DailyGoalsUpdateDialog extends StatelessWidget {
  const DailyGoalsUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "💡 Neu: Tagesziele!",
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(
              style: Theme.of(context).textTheme.labelLarge,
              children: <TextSpan>[
                new TextSpan(text: "Absoliviere die Tagesziele um ein "),
                new TextSpan (
                    text: "verstecktes Level ",
                    style: new TextStyle(
                      color: MyColorPalette.of(context).primaryShade,
                    )),
                new TextSpan(text: "freizuschalten!"),
              ],
            ),
          ),
          SizedBox(height: 48),
          SvgPicture.asset(
            MyIcons.treasureChestClosedSvg,
            width: 64,
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