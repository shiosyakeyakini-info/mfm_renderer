import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/mfm_renderer.dart';
import 'package:mfm_renderer/src/extension/string_extension.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_bounce.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_jump.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_ruby.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_shake.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_spin.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_tada.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_twitch.dart';
import 'package:mfm_renderer/src/functions/mfm_jelly.dart';
import 'package:mfm_renderer/src/mfm_element_widget.dart';
import 'package:mfm_renderer/src/functions/mfm_fn_rainbow.dart';
import 'package:mfm_renderer/src/mfm_inline_span.dart';

UnixTimeBuilder _defaultUnixTimeBuilder = (context, date, style) {
  return TextSpan(text: date?.toIso8601String() ?? "");
};

class MfmFnSpan extends TextSpan {
  final MfmFn function;
  final BuildContext context;
  final int depth;
  late final List<InlineSpan> _cachedSpan;

  MfmFnSpan({
    required this.function,
    required super.style,
    required this.context,
    required this.depth,
    super.recognizer,
  }) {
    _cachedSpan = buildChildren();
  }

  bool findChildrenNewLine(List<MfmNode> nodes) {
    for (final node in nodes) {
      if (node is MfmText) {
        if (node.text.contains("\n")) {
          return true;
        } else {
          return findChildrenNewLine(node.children ?? []);
        }
      } else if (node is MfmEmojiCode) {
        return true;
      }
    }
    return false;
  }

  PlaceholderAlignment resolveAlignment(List<MfmNode> nodes) =>
      findChildrenNewLine(nodes)
          ? PlaceholderAlignment.aboveBaseline
          : PlaceholderAlignment.middle;

  double? validTime(String? time) {
    if (time == null) return null;
    final value =
        RegExp(r'^([0-9\.]+)s$').allMatches(time).firstOrNull?.group(1);
    if (value != null) {
      return double.tryParse(value);
    }
    return null;
  }

  List<InlineSpan> buildChildren() {
    if (function.name == "x2") {
      return [
        MfmInlineSpan(
          context: context,
          style: style?.merge(
              TextStyle(height: 0, fontSize: (style?.fontSize ?? 22) * 2)),
          nodes: function.children,
          depth: depth + 1,
        )
      ];
    }
    if (function.name == "x3") {
      return [
        MfmInlineSpan(
          context: context,
          style: style?.merge(
              TextStyle(height: 0, fontSize: (style?.fontSize ?? 22) * 4)),
          nodes: function.children,
          depth: depth + 1,
        )
      ];
    }

    if (function.name == "x4") {
      return [
        MfmInlineSpan(
          context: context,
          style: style?.merge(TextStyle(
              height: 0,
              fontSize:
                  (DefaultTextStyle.of(context).style.fontSize ?? 22) * 6)),
          nodes: function.children,
          depth: depth + 1,
        )
      ];
    }

    if (function.name == "fg") {
      return [
        WidgetSpan(
          style: style,
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.alphabetic,
          child: MfmElementWidget(
            nodes: function.children,
            style: style?.merge(TextStyle(
                color: (function.args["color"] as String?)?.color,
                height: Mfm.of(context).lineHeight)),
            depth: depth + 1,
          ),
        )
      ];
    }

    if (function.name == "bg") {
      return [
        WidgetSpan(
          style: style,
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.ideographic,
          child: Container(
            decoration:
                BoxDecoration(color: (function.args["color"] as String?).color),
            child: MfmElementWidget(
              nodes: function.children,
              style: style?.copyWith(height: Mfm.of(context).lineHeight),
              depth: depth + 1,
            ),
          ),
        )
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
            nodes: function.children,
            context: context,
            style: fontStyle,
            depth: depth + 1)
      ];
    }

    if (function.name == "rotate") {
      final deg = double.tryParse(function.args["deg"] ?? "") ?? 90.0;
      return [
        WidgetSpan(
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.alphabetic,
          child: Transform.rotate(
              angle: deg * pi / 180,
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
                depth: depth + 1,
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
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.alphabetic,
          child: Transform.scale(
            scaleX: x,
            scaleY: y,
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
              depth: depth + 1,
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
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.ideographic,
          child: Transform.translate(
            offset: Offset(x * defaultFontSize, y * defaultFontSize),
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
              depth: depth + 1,
            ),
          ),
        )
      ];
    }

    if (function.name == "tada") {
      final speed = Mfm.of(context).isUseAnimation
          ? validTime(function.args["speed"]) ?? 1
          : 0.0;
      return [
        WidgetSpan(
            alignment: resolveAlignment(function.children ?? []),
            child: MfmFnTada(
              speed: speed,
              child: MfmElementWidget(
                nodes: function.children,
                style: style
                    ?.merge(TextStyle(fontSize: (style?.fontSize ?? 22) * 1.5)),
                depth: depth + 1,
              ),
            ))
      ];
    }

    if (function.name == "blur") {
      return [
        WidgetSpan(
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.alphabetic,
          child: MfmFnBlur(
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
              depth: depth + 1,
            ),
          ),
        )
      ];
    }

    if (function.name == "flip") {
      final isVertical = function.args.containsKey("v");
      final isHorizontal = function.args.containsKey("h");

      if ((!isVertical && !isHorizontal) || (isHorizontal && !isVertical)) {
        return [
          WidgetSpan(
            alignment: resolveAlignment(function.children ?? []),
            baseline: TextBaseline.alphabetic,
            child: Transform(
              transform: Matrix4.rotationY(pi),
              alignment: Alignment.center,
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
                depth: depth + 1,
              ),
            ),
          )
        ];
      }

      if (isVertical && !isHorizontal) {
        return [
          WidgetSpan(
            alignment: resolveAlignment(function.children ?? []),
            baseline: TextBaseline.alphabetic,
            child: Transform(
              transform: Matrix4.rotationX(pi),
              alignment: Alignment.center,
              child: MfmElementWidget(
                nodes: function.children,
                style: style,
                depth: depth + 1,
              ),
            ),
          )
        ];
      }

      return [
        WidgetSpan(
          alignment: resolveAlignment(function.children ?? []),
          baseline: TextBaseline.alphabetic,
          child: Transform(
            transform: Matrix4.rotationZ(pi),
            alignment: Alignment.center,
            child: MfmElementWidget(
              nodes: function.children,
              style: style,
              depth: depth + 1,
            ),
          ),
        )
      ];
    }

    if (function.name == "ruby") {
      final children = function.children;
      if (children == null) return [];
      final String text;
      final alignment = findChildrenNewLine(function.children ?? [])
          ? PlaceholderAlignment.middle
          : PlaceholderAlignment.aboveBaseline;

      if (children.length == 1) {
        final child = children[0];
        text = child is MfmText ? child.text : "";

        final splited = text.split(' ');

        return [
          WidgetSpan(
            style: style,
            alignment: alignment,
            baseline: TextBaseline.ideographic,
            child: MfmFnRuby(
              rt: splited.length >= 2 ? splited[1] : "",
              style: style,
              child: Text.rich(
                textScaler: TextScaler.noScaling,
                TextSpan(text: splited[0]),
                style: style?.copyWith(height: 1.2),
              ),
            ),
          )
        ];
      } else {
        final rt = children.last;
        text = rt is MfmText ? rt.text : "";

        return [
          WidgetSpan(
            style: style,
            alignment: alignment,
            baseline: TextBaseline.ideographic,
            child: MfmFnRuby(
              rt: text.trim(),
              style: style?.copyWith(height: 1.2),
              child: MfmElementWidget(
                nodes: children.sublist(0, children.length - 1),
                depth: depth + 1,
                style: style?.copyWith(height: 1.2),
              ),
            ),
          )
        ];
      }
    }

    if (function.name == "unixtime") {
      final child = function.children?.firstOrNull;
      final unixtime = child is MfmText ? int.tryParse(child.text) : null;
      DateTime? date;
      try {
        date = unixtime == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(unixtime * 1000);
      } catch (e) {
        date = null;
      }

      return [
        Mfm.of(context).unixTimeBuilder?.call(context, date, style) ??
            _defaultUnixTimeBuilder(context, date, style)
      ];
    }

    if (function.name == "rainbow" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 1;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmRainbow(
              speed: speed,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    if (function.name == "shake" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 0.5;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnShake(
              speed: speed,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    if (function.name == "jelly" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 1.0;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnJelly(
              speed: speed,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    if (function.name == "twitch" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 0.5;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnTwitch(
              speed: speed,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    if (function.name == "bounce" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 0.75;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnBounce(
              speed: speed,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    if (function.name == "jump" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 0.75;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnJump(
              speed: speed,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    if (function.name == "spin" && Mfm.of(context).isUseAnimation) {
      final speed = validTime(function.args["speed"]) ?? 1.5;
      final type = function.args.containsKey("x")
          ? MfmFnSpinType.x
          : function.args.containsKey("y")
              ? MfmFnSpinType.y
              : MfmFnSpinType.both;
      final direction = function.args.containsKey("left")
          ? MfmFnSpinDirection.reverse
          : function.args.containsKey("alternate")
              ? MfmFnSpinDirection.alternate
              : MfmFnSpinDirection.normal;
      return [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MfmFnSpin(
              speed: speed,
              direction: direction,
              type: type,
              child: MfmElementWidget(
                  nodes: function.children, style: style, depth: depth + 1),
            ))
      ];
    }

    return [
      MfmInlineSpan(
          context: context,
          nodes: function.children,
          style: style,
          depth: depth + 1)
    ];
  }

  @override
  List<InlineSpan> get children => _cachedSpan;
}
