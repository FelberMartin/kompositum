
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/my_theme.dart';

void main() =>
    runApp(MaterialApp(theme: myTheme, home: MyBackground()));



/// A widget that draws the background of the app.
/// The background consists of multiple layered rounded shapes.
class MyBackground extends StatelessWidget {

  const MyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      placeholderBuilder: (context) => Container(
        color: MyColorPalette.of(context).background,
      ),
      "assets/images/background.svg",
      fit: BoxFit.cover,
    );
  }
}