import 'dart:ui';

import 'package:flutter/material.dart';


Color getFontColorForBackground(Color background) {
  return (background.computeLuminance() > 0.179)? Colors.black : Colors.white;
}

extension ColorExtension on Color {

  Color addHsv({double? hue, double? saturation, double? value}) {
    final hueAddition = hue ?? 0;
    final hueValue = HSVColor.fromColor(this).hue + hueAddition;
    clampDouble(hueValue, 0, 360);
    final saturationAddition = saturation ?? 0;
    final saturationValue = HSVColor.fromColor(this).saturation + saturationAddition;
    clampDouble(saturationValue, 0, 1);
    final valueAddition = value ?? 0;
    final valueValue = HSVColor.fromColor(this).value + valueAddition;
    clampDouble(valueValue, 0, 1);
    return HSVColor.fromAHSV(this.alpha / 255, hueValue, saturationValue, valueValue).toColor();
  }

  Color darken([double amount = 0.1]) {
    return addHsv(saturation: amount, value: -amount);
  }

  Color lighten([double amount = 0.2]) {
    return addHsv(saturation: -amount, value: amount);
  }
}