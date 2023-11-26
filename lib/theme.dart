import 'package:flutter/material.dart';

const Color undefined = Color(0xFFED14FF);

final myTheme = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF4c58bd),
      onPrimary: Colors.white,
      secondary: Color(0xff6884fd),
      onSecondary: Colors.white,
      error: Color(0xffc97e7e),
      onError: undefined,
      background: undefined,
      onBackground: undefined,
      surface: undefined,
      onSurface: undefined,
  ),
  extensions: const [
    CustomColors(
      background1: Color(0xffc1c6fd),
      background2: Color(0xffbec2fd),
      background3: Color(0xffb6bbfd),
      background4: Color(0xffaeb4fd),
      textSecondary: Color(0xffC1C7FF),
      star: Color(0xfff9da56),
    ),
  ],
  fontFamily: 'Exo2',
  textTheme: const TextTheme(
    // Figma 12
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    // Figma 14
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    // Figma 16
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    // Figma 20
    titleSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    // Figma 24
    titleMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {

  const CustomColors({
    required this.background1,
    required this.background2,
    required this.background3,
    required this.background4,
    required this.textSecondary,
    required this.star,
  });

  final Color background1;
  final Color background2;
  final Color background3;
  final Color background4;

  final Color textSecondary;
  final Color star;

  @override
  ThemeExtension<CustomColors> copyWith() {
    return CustomColors(
      background1: background1,
      background2: background2,
      background3: background3,
      background4: background4,
      textSecondary: textSecondary,
      star: star,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(covariant ThemeExtension<CustomColors>? other, double t) {
    if (other == null) return this;
    if (other is! CustomColors) return this;
    return CustomColors(
      background1: Color.lerp(background1, other.background1, t)!,
      background2: Color.lerp(background2, other.background2, t)!,
      background3: Color.lerp(background3, other.background3, t)!,
      background4: Color.lerp(background4, other.background4, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      star: Color.lerp(star, other.star, t)!,
    );
  }

}

