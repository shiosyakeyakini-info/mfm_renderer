import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/mfm_renderer.dart';
import 'package:mfm_renderer/src/extension/string_extension.dart';
import 'package:mfm_renderer/src/mfm_element_widget.dart';
import 'package:mfm_renderer/src/mfm_fn_blur.dart';

class MfmFnElementWidget extends StatelessWidget {
  const MfmFnElementWidget({super.key, required this.function});

  final MfmFn function;

  @override
  Widget build(BuildContext context) {
    if (function.name == "x2") {
      return DefaultTextStyle.merge(
          style: TextStyle(
              fontSize:
                  (DefaultTextStyle.of(context).style.fontSize ?? 22) * 2),
          child: MfmElementWidget(nodes: function.children));
    }
    if (function.name == "x3") {
      return DefaultTextStyle.merge(
          style: TextStyle(
              fontSize:
                  (DefaultTextStyle.of(context).style.fontSize ?? 22) * 3),
          child: MfmElementWidget(nodes: function.children));
    }

    if (function.name == "x4") {
      return DefaultTextStyle.merge(
          style: TextStyle(
              fontSize:
                  (DefaultTextStyle.of(context).style.fontSize ?? 22) * 4),
          child: MfmElementWidget(nodes: function.children));
    }

    if (function.name == "fg") {
      return DefaultTextStyle.merge(
          style: TextStyle(color: (function.args["color"] as String?).color),
          child: MfmElementWidget(nodes: function.children));
    }

    if (function.name == "bg") {
      return Container(
        decoration:
            BoxDecoration(color: (function.args["color"] as String?).color),
        child: MfmElementWidget(nodes: function.children),
      );
    }

    if (function.name == "font") {
      if (function.args.containsKey("serif")) {
        return DefaultTextStyle.merge(
            style: Mfm.of(context).serifStyle,
            child: MfmElementWidget(nodes: function.children));
      } else if (function.args.containsKey("monospace")) {
        return DefaultTextStyle.merge(
            style: Mfm.of(context).monospaceStyle,
            child: MfmElementWidget(nodes: function.children));
      } else {
        return MfmElementWidget(nodes: function.children);
      }
    }

    if (function.name == "rotate") {
      final deg = double.tryParse(function.args["deg"] ?? "") ?? 90.0;
      return Transform.rotate(
          angle: deg * pi / 180,
          child: MfmElementWidget(nodes: function.children));
    }

    if (function.name == "scale") {
      final x = double.tryParse(function.args["x"] ?? "") ?? 1.0;
      final y = double.tryParse(function.args["y"] ?? "") ?? 1.0;

      // scale.x=0, scale.y=0は表示しない
      if (x == 0 || y == 0) {
        return Container();
      }

      return Transform.scale(
        scaleX: x,
        scaleY: y,
        child: MfmElementWidget(nodes: function.children),
      );
    }

    if (function.name == "position") {
      final x = double.tryParse(function.args["x"] ?? "") ?? 0;
      final y = double.tryParse(function.args["y"] ?? "") ?? 0;
      final double defaultFontSize =
          (DefaultTextStyle.of(context).style.fontSize ?? 22) *
              MediaQuery.of(context).textScaleFactor;

      return Transform.translate(
        offset: Offset(x * defaultFontSize, y * defaultFontSize),
        child: MfmElementWidget(nodes: function.children),
      );
    }

    if (function.name == "tada") {
      return DefaultTextStyle.merge(
          style: TextStyle(
              fontSize:
                  (DefaultTextStyle.of(context).style.fontSize ?? 22) * 2),
          child: MfmElementWidget(nodes: function.children));
    }

    if (function.name == "blur") {
      return MfmFnBlur(child: MfmElementWidget(nodes: function.children));
    }

    if (function.name == "flip") {
      final isVertical = function.args.containsKey("v");
      final isHorizontal = function.args.containsKey("h");

      if ((!isVertical && !isHorizontal) || (isHorizontal && !isVertical)) {
        return Transform(
          transform: Matrix4.rotationY(pi),
          alignment: Alignment.center,
          child: MfmElementWidget(nodes: function.children),
        );
      }

      if (isVertical && !isHorizontal) {
        return Transform(
          transform: Matrix4.rotationX(pi),
          alignment: Alignment.center,
          child: MfmElementWidget(nodes: function.children),
        );
      }

      return Transform(
        transform: Matrix4.rotationZ(pi),
        alignment: Alignment.center,
        child: MfmElementWidget(nodes: function.children),
      );
    }

    return MfmElementWidget(nodes: function.children);
  }
}
