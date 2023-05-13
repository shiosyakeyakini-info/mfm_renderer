import 'package:flutter/widgets.dart';

extension StringExtensions on String {
  String get tight {
    return Characters(this)
        .replaceAll(Characters(''), Characters('\u{200B}'))
        .toString();
  }
}

extension NullableStringExtensions on String? {
  Color? get color {
    final colorString = this;
    if (colorString == null) {
      return const Color(0xFFFF0000);
    }

    if (!RegExp(r'^[0-9a-fA-F]+?$').hasMatch(colorString)) {
      return null;
    }

    final String htmlColor;
    if (colorString.length == 3) {
      htmlColor =
          "FF${colorString.substring(0, 1)}${colorString.substring(0, 1)}${colorString.substring(1, 2)}${colorString.substring(1, 2)}${colorString.substring(2, 3)}${colorString.substring(2, 3)}";
    } else if (colorString.length == 6) {
      htmlColor = "FF$colorString";
    } else if (colorString.length == 8) {
      htmlColor = colorString;
    } else {
      return null;
    }
    final intValue = int.tryParse(htmlColor, radix: 16);
    if (intValue == null) return null;
    return Color(intValue);
  }
}
