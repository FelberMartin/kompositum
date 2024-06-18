
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kompositum/util/extensions/color_util.dart';

import '../../config/my_theme.dart';

void main() =>
    runApp(MaterialApp(theme: myTheme, home: MyBackground()));



/// A widget that draws the background of the app.
/// The background consists of multiple layered rounded shapes.
class MyBackground extends StatelessWidget {

  const MyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyColorPalette.of(context).background.lighten(0.07),
            MyColorPalette.of(context).background.darken(0.02),
          ],
        ),
      ),
    );
  }
}