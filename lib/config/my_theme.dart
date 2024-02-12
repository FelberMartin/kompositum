import 'package:flutter/material.dart';
import 'package:kompositum/util/color_util.dart';

const Color undefined = Color(0xFFED14FF);

class MyColorPalette extends ThemeExtension<MyColorPalette> {
  
  static const Color defaultStar = Color(0xfffddb5e);
  
  MyColorPalette({
    required this.primary,
    required this.primaryShade,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryShade,
    required this.onSecondary,
    required this.background,
    required this.textSecondary,
    required this.star,
  });
  
  final Color primary, primaryShade, onPrimary;
  final Color secondary, secondaryShade, onSecondary;
  final Color background;
  final Color textSecondary, star;

  factory MyColorPalette.fromPrimarySecondary(Color primary, Color secondary) {
    final background = secondary.lighten(0.2);
    return MyColorPalette(
      primary: primary,
      primaryShade: primary.darken(),
      onPrimary: getFontColorForBackground(primary),
      secondary: secondary,
      secondaryShade: secondary.darken(),
      onSecondary: getFontColorForBackground(secondary),
      background: background,
      textSecondary: background,
      star: defaultStar,
    );
  }

  static MyColorPalette of(BuildContext context) {
    return Theme.of(context).extension<MyColorPalette>()!;
  }

  static MyColorPalette classic = MyColorPalette.fromPrimarySecondary(
    Color(0xFF4C58BD),
    Color(0xFF6184FF),
  );

  static MyColorPalette classicBright = MyColorPalette(
    primary: Color(0xFF4752B4),
    primaryShade: Color(0xFF3240B5),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF568FFF),
    secondaryShade: Color(0xFF426AF5),
    onSecondary: Color(0xFFFFFFFF),
    background: Color(0xFFBED4FF),
    textSecondary: Color(0xFFBED4FF),
    star: defaultStar,
  );

  static MyColorPalette yellowBlue = MyColorPalette.fromPrimarySecondary(
    Color(0xFFFFD75E),
    Color(0xFF2C72DB),
  );

  static MyColorPalette orangeBlue = MyColorPalette.fromPrimarySecondary(
    Color(0xFFE88C5B),
    Color(0xFF5EA8FF),
  );

  static MyColorPalette redishGreen = MyColorPalette.fromPrimarySecondary(
    Color(0xFFDE786B),
    Color(0xFF80C5CA),
  );



  @override
  ThemeExtension<MyColorPalette> copyWith() {
    return MyColorPalette(
      primary: primary,
      primaryShade: primaryShade,
      onPrimary: onPrimary,
      secondary: secondary,
      secondaryShade: secondaryShade,
      onSecondary: onSecondary,
      background: background,
      textSecondary: textSecondary,
      star: star,
    );
  }

  @override
  ThemeExtension<MyColorPalette> lerp(covariant ThemeExtension<MyColorPalette>? other, double t) {
    if (other == null) return this;
    if (other is! MyColorPalette) return this;
    return MyColorPalette(
      primary: Color.lerp(primary, other!.primary, t)!,
      primaryShade: Color.lerp(primaryShade, other.primaryShade, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryShade: Color.lerp(secondaryShade, other.secondaryShade, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      star: Color.lerp(star, other.star, t)!,
    );
  }
}

final _palette = MyColorPalette.classicBright;
final myTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: _palette.primary,
      onPrimary: _palette.onPrimary,
      secondary: _palette.secondary,
      onSecondary: _palette.onSecondary,
      error: undefined,
      onError: undefined,
      background: undefined,
      onBackground: undefined,
      surface: _palette.secondaryShade,
      onSurface: _palette.secondaryShade,
  ),
  extensions: [
    _palette,
  ],
  fontFamily: 'Exo2',
  textTheme: TextTheme(
    // Figma 12
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: _palette.onSecondary,
      letterSpacing: 0.6,
    ),
    // Figma 14
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: _palette.onSecondary,
    ),
    // Figma 16
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _palette.onSecondary,
    ),
    // Figma 20
    titleSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: _palette.onSecondary,
    ),
    // Figma 24
    titleMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: _palette.onSecondary,
    ),
    // Figma 32
    titleLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: _palette.onSecondary,
    ),
  ),
);
