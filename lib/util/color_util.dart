import 'dart:ui';

import 'package:flutter/material.dart';


Color getFontColorForBackground(Color background) {
  // TODO: this was only adjusted from 0.187 for testing the classic theme
  return (background.computeLuminance() > 0.800)? Colors.black : Colors.white;
}

extension ColorExtension on Color {

  Color addHsv({double? hue, double? saturation, double? value}) {
    final hueAddition = hue ?? 0;
    var hueValue = HSVColor.fromColor(this).hue + hueAddition;
    hueValue = clampDouble(hueValue, 0, 360);
    final saturationAddition = saturation ?? 0;
    var saturationValue = HSVColor.fromColor(this).saturation + saturationAddition;
    saturationValue = clampDouble(saturationValue, 0, 1);
    final valueAddition = value ?? 0;
    var valueValue = HSVColor.fromColor(this).value + valueAddition;
    valueValue = clampDouble(valueValue, 0, 1);
    return HSVColor.fromAHSV(this.alpha / 255, hueValue, saturationValue, valueValue).toColor();
  }

  Color darken([double amount = 0.1]) {
    return addHsv(saturation: amount, value: -amount);
  }

  Color lighten([double amount = 0.2]) {
    return addHsv(saturation: -amount, value: amount);
  }
}