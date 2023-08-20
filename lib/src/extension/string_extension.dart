import 'package:flutter/widgets.dart';

extension StringExtensions on String {
  String get tight {
    return Characters(this)
        .replaceAll(Characters(''), Characters('\u{200B}'))
        .toString();
  }

  String get decodeUri {
    try {
      return Uri.decodeComponent(this);
    } catch (e) {
      return this;
    }
  }

  String get nyaize {
    return // ja-JP
        replaceAll('な', 'にゃ')
            .replaceAll('ナ', 'ニャ')
            .replaceAll('ﾅ', 'ﾆｬ')
            // en-US
            .replaceAllMapped(RegExp("(?<=[nN])[aA]/"),
                (x) => x.group(0) == 'A' ? 'YA' : 'ya')
            .replaceAllMapped(RegExp("(?<=morn)ing"),
                (x) => x.group(0) == "ING" ? "YAN" : "yan")
            .replaceAllMapped(RegExp("(?<=every)one"),
                (x) => x.group(0) == "ONE" ? "NYAN" : "nyan");
    // TODO: support ko-KR
    //   .replaceAllMapped(RegExp("[나-낳]"), (match) => )
    // // ko-KR
    //     .replace(//g, match => String.fromCharCode(
    // match.charCodeAt(0)! + '냐'.charCodeAt(0) - '나'.charCodeAt(0),
    // ))
    //     .replace(/(다$)|(다(?=\.))|(다(?= ))|(다(?=!))|(다(?=\?))/gm, '다냥')
    //     .replace(/(야(?=\?))|(야$)|(야(?= ))/gm, '냥');
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
    } else if (colorString.length == 4) {
      htmlColor =
          "${colorString.substring(3, 4)}${colorString.substring(3, 4)}${colorString.substring(0, 1)}${colorString.substring(0, 1)}${colorString.substring(1, 2)}${colorString.substring(1, 2)}${colorString.substring(2, 3)}${colorString.substring(2, 3)}";
    } else if (colorString.length == 6) {
      htmlColor = "FF$colorString";
    } /*
      じつは8桁のカラーコードには対応してない
      else if (colorString.length == 8) {
      htmlColor = colorString;
    } */
    else {
      return null;
    }
    final intValue = int.tryParse(htmlColor, radix: 16);
    if (intValue == null) return null;
    return Color(intValue);
  }
}
