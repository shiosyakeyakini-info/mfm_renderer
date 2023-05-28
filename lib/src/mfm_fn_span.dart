import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/mfm_renderer.dart';
import 'package:mfm_renderer/src/extension/string_extension.dart';
import 'package:mfm_renderer/src/mfm_element_widget.dart';
import 'package:mfm_renderer/src/mfm_fn_blur.dart';
import 'package:mfm_renderer/src/mfm_inline_span.dart';

class MfmFnSpan extends TextSpan {
  final MfmFn function;
  final BuildContext context;

  const MfmFnSpan({
    required this.function,
    required super.style,
    required this.context,
    super.recognizer,
  });

  @override
  List<InlineSpan> get children {
    if (function.name == "x2") {
      return [
        MfmInlineSpan(
            context: context,
            style: style?.merge(TextStyle(
                height: 0,
                fontSize:
                    (DefaultTextStyle.of(context).style.fontSize ?? 22) * 2)),
            nodes: function.children)
      ];
    }
    if (function.name == "x3") {
      return [
        MfmInlineSpan(
            context: context,
            style: style?.merge(TextStyle(
                height: 0,
                fontSize:
                    (DefaultTextStyle.of(context).style.fontSize ?? 22) * 3)),
            nodes: function.children)
      ];
    }

    if (function.name == "x4") {
      return [
        MfmInlineSpan(
            context: context,
            style: style?.merge(TextStyle(
                height: 0,
                fontSize:
                    (DefaultTextStyle.of(context).style.fontSize ?? 22) * 4)),
            nodes: function.children)
      ];
    }

    if (function.name == "fg") {
      return [
        MfmInlineSpan(
            context: context,
            style: style?.merge(
                TextStyle(color: (function.args["color"] as String?)?.color)),
            nodes: function.children)
      ];
    }

    if (function.name == "bg") {
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              decoration: BoxDecoration(
                  color: (function.args["color"] as String?).color),
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
              ),
            ))
      ];
    }

    if (function.name == "font") {
      var fontStyle = style;
      if (function.args.containsKey("serif")) {
        fontStyle = style?.merge(Mfm.of(context).serifStyle);
      } else if (function.args.containsKey("monospace")) {
        fontStyle = style?.merge(Mfm.of(context).monospaceStyle);
      } else {}

      return [
        MfmInlineSpan(
            nodes: function.children, context: context, style: fontStyle)
      ];
    }

    if (function.name == "rotate") {
      final deg = double.tryParse(function.args["deg"] ?? "") ?? 90.0;
      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.rotate(
              angle: deg * pi / 180,
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
              )),
        )
      ];
    }

    if (function.name == "scale") {
      final x = min(double.tryParse(function.args["x"] ?? "") ?? 1.0, 5.0);
      final y = min(double.tryParse(function.args["y"] ?? "") ?? 1.0, 5.0);

      // scale.x=0, scale.y=0は表示しない
      if (x == 0 || y == 0) {
        return const [TextSpan()];
      }

      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.scale(
            scaleX: x,
            scaleY: y,
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
            ),
          ),
        )
      ];
    }

    if (function.name == "position") {
      final x = double.tryParse(function.args["x"] ?? "") ?? 0;
      final y = double.tryParse(function.args["y"] ?? "") ?? 0;
      final double defaultFontSize = (style?.fontSize ?? 22);

      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.translate(
            offset: Offset(x * defaultFontSize, y * defaultFontSize),
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
            ),
          ),
        )
      ];
    }

    if (function.name == "tada") {
      return [
        MfmInlineSpan(
            context: context,
            style:
                style?.merge(TextStyle(fontSize: (style?.fontSize ?? 22) * 2)),
            nodes: function.children)
      ];
    }

    if (function.name == "blur") {
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnBlur(
                child: MfmElementWidget(
              nodes: function.children,
              style: style,
            )))
      ];
    }

    if (function.name == "flip") {
      final isVertical = function.args.containsKey("v");
      final isHorizontal = function.args.containsKey("h");

      if ((!isVertical && !isHorizontal) || (isHorizontal && !isVertical)) {
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Transform(
              transform: Matrix4.rotationY(pi),
              alignment: Alignment.center,
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
              ),
            ),
          )
        ];
      }

      if (isVertical && !isHorizontal) {
        return [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Transform(
              transform: Matrix4.rotationX(pi),
              alignment: Alignment.center,
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
              ),
            ),
          )
        ];
      }

      return [
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform(
            transform: Matrix4.rotationZ(pi),
            alignment: Alignment.center,
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
            ),
          ),
        )
      ];
    }

    return [
      MfmInlineSpan(context: context, nodes: function.children, style: style)
    ];
  }
}
