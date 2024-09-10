import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/my_theme.dart';
import 'package:kompositum/util/my_share.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';


void main() => runApp(MaterialApp(
  theme: myTheme,
  home: IOSUpdateDialog(),
));


class IOSUpdateDialog extends StatelessWidget {
  const IOSUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyDialog(
      title: "💡 Neu: iOS App!",
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
            "Deine Lieblings-App gibt es jetzt auch fürs iPhone! Lass es deine Apfel-liebenden Freunde wissen!",
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 48),
          Row(
            children: [
              MySecondaryTextButton(
                  text: "Alles klar",
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              ),
              SizedBox(width: 8),
              Expanded(
                child: MyPrimaryTextButton(
                    text: "Teilen",
                    onPressed: () {
                      MyShare.shareApp();
                    }
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}