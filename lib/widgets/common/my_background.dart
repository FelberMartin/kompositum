
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/theme.dart';

void main() =>
    runApp(MaterialApp(theme: myTheme, home: MyBackground()));



/// A widget that draws the background of the app.
/// The background consists of multiple layered rounded shapes.
class MyBackground extends StatelessWidget {

  const MyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return SvgPicture.asset(
      "assets/background.svg",
      fit: BoxFit.cover,
      // colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
    );
  }
}