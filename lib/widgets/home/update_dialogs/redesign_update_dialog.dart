import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';


void main() => runApp(MaterialApp(
  theme: myTheme,
  home: RedesignUpdateDialog(),
));


class RedesignUpdateDialog extends StatelessWidget {
  const RedesignUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "💡 Neu: Redesign!",
      child: Column(
        children: [
          Image.asset(
            "assets/images/app_icon/app_icon_rounded_corners_2x.png",
            width: 120,
          ),
          Text(
            "Wort + Schatz",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: MyColorPalette.of(context).textSecondary,
            ),

          ),
          SizedBox(height: 48),
          Text(
            "Das neue visuelle Update der App ist da. Wir hoffen es gefällt dir!",
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