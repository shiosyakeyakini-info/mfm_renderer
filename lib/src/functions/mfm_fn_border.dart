import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/widgets.dart';

enum MfmFnBorderStyle {
  hidden,
  dotted,
  dashed,
  solid,
  double,
  groove,
  ridge,
  inset,
  outset
}

class MfmFnBorder extends StatelessWidget {
  final Widget child;
  final double width;
  final Color color;
  final double radius;
  final MfmFnBorderStyle style;
  final bool isClip;

  double _luminance() {
    return (0.298912 * ((color.r * 255.0).round() & 0xff) / 255 +
        0.586611 * ((color.g * 255.0).round() & 0xff) / 255 +
        0.114478 * ((color.b * 255.0).round() & 0xff) / 255);
  }

  Color _lightSide() {
    if (_luminance() > 0.5) {
      return color;
    }
    return Color.fromRGBO(
        ((color.r * 255.0).round() & 0xff) +
            (255 - ((color.r * 255.0).round() & 0xff)) ~/ 3,
        ((color.g * 255.0).round() & 0xff) +
            (255 - ((color.g * 255.0).round() & 0xff)) ~/ 3,
        ((color.b * 255.0).round() & 0xff) +
            (255 - ((color.b * 255.0).round() & 0xff)) ~/ 3,
        1);
  }

  Color _darkSide() {
    if (_luminance() <= 0.5) {
      return color;
    }

    return Color.fromRGBO(
        ((color.r * 255.0).round() & 0xff) -
            (((color.r * 255.0).round() & 0xff) ~/ 3),
        ((color.g * 255.0).round() & 0xff) -
            (((color.g * 255.0).round() & 0xff) ~/ 3),
        ((color.b * 255.0).round() & 0xff) -
            (((color.b * 255.0).round() & 0xff) ~/ 3),
        1);
  }

  BoxDecoration _generate3dBoxDecoration(
      double width, Color topLeftColor, Color bottomRightColor,
      {bool isInset = false, bool hasRadius = true}) {
    final value = BoxDecoration(
      border: Border(
        right: !isInset || radius == 0 || !hasRadius
            ? BorderSide(color: bottomRightColor, width: width)
            : BorderSide.none,
        bottom: !isInset || radius == 0 || !hasRadius
            ? BorderSide(color: bottomRightColor, width: width)
            : BorderSide.none,
        top: isInset || radius == 0 || !hasRadius
            ? BorderSide(color: topLeftColor, width: width)
            : BorderSide.none,
        left: isInset || radius == 0 || !hasRadius
            ? BorderSide(color: topLeftColor, width: width)
            : BorderSide.none,
      ),
      borderRadius:
          !hasRadius || radius == 0 ? null : BorderRadius.circular(radius),
    );

    return value;
  }

  Widget _ifBorderRadiusHas(Widget Function(Widget widget) builder,
      {Widget Function(Widget widget)? builder2, double? forcePadding}) {
    final childWidget = MfmFnBorderInner(
      radius: radius,
      padding: forcePadding ?? width,
      clipPadding: width,
      isClip: isClip,
      child: child,
    );

    if (radius == 0) {
      return builder2 != null ? builder2(childWidget) : childWidget;
    }
    return builder(builder2 != null ? builder2(childWidget) : childWidget);
  }

  const MfmFnBorder({
    super.key,
    required this.style,
    required this.child,
    required this.width,
    required this.color,
    required this.radius,
    required this.isClip,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case MfmFnBorderStyle.hidden:
        return MfmFnBorderInner(
            radius: radius, padding: width, isClip: isClip, child: child);
      case MfmFnBorderStyle.solid:
        return DecoratedBox(
            decoration: width == 0
                ? const BoxDecoration()
                : BoxDecoration(
                    border: Border.all(color: color, width: width),
                    borderRadius:
                        radius != 0 ? BorderRadius.circular(radius) : null),
            child: MfmFnBorderInner(
                radius: radius, padding: width, isClip: isClip, child: child));
      case MfmFnBorderStyle.double:
        return DecoratedBox(
          decoration: width == 0
              ? const BoxDecoration()
              : BoxDecoration(
                  border: Border.all(color: color, width: width / 3),
                  borderRadius:
                      radius != 0 ? BorderRadius.circular(radius) : null),
          child: Padding(
            padding: EdgeInsets.all(width * 2 / 3),
            child: DecoratedBox(
              decoration: width == 0
                  ? const BoxDecoration()
                  : BoxDecoration(
                      border: Border.all(color: color, width: width / 3),
                      borderRadius:
                          radius != 0 ? BorderRadius.circular(radius) : null),
              child: MfmFnBorderInner(
                  radius: radius,
                  padding: width / 3,
                  isClip: isClip,
                  child: child),
            ),
          ),
        );
      case MfmFnBorderStyle.dashed:
        return DottedBorder(
          options: radius == 0
              ? RectDottedBorderOptions(
                  strokeWidth: width,
                  dashPattern: [width * 2.5, width],
                  color: color,
                )
              : RoundedRectDottedBorderOptions(
                  radius: Radius.circular(radius),
                  strokeWidth: width,
                  dashPattern: [width * 2.5, width],
                  color: color,
                ),
          child: MfmFnBorderInner(
              radius: radius,
              padding: 0,
              clipPadding: width * 2,
              isClip: isClip,
              child: child),
        );
      case MfmFnBorderStyle.inset:
        return DecoratedBox(
          decoration:
              _generate3dBoxDecoration(width, _darkSide(), _lightSide()),
          child: _ifBorderRadiusHas(
            (widget) => DecoratedBox(
              decoration: _generate3dBoxDecoration(
                  width, _darkSide(), _lightSide(),
                  isInset: true),
              child: widget,
            ),
          ),
        );
      case MfmFnBorderStyle.outset:
        return DecoratedBox(
          decoration:
              _generate3dBoxDecoration(width, _lightSide(), _darkSide()),
          child: _ifBorderRadiusHas(
            (widget) => DecoratedBox(
                decoration: _generate3dBoxDecoration(
                    width, _lightSide(), _darkSide(),
                    isInset: true),
                child: widget),
          ),
        );
      case MfmFnBorderStyle.groove:
        return DecoratedBox(
          decoration:
              _generate3dBoxDecoration(width / 2, _darkSide(), _lightSide()),
          child: _ifBorderRadiusHas(
            (widget) => DecoratedBox(
              decoration: _generate3dBoxDecoration(
                  width / 2, _darkSide(), _lightSide(),
                  isInset: true),
              child: widget,
            ),
            builder2: (widget) => Padding(
              padding: EdgeInsets.all(width / 2),
              child: DecoratedBox(
                decoration: _generate3dBoxDecoration(
                    width / 2, _lightSide(), _darkSide(),
                    hasRadius: false),
                child: widget,
              ),
            ),
            forcePadding: width / 2,
          ),
        );

      case MfmFnBorderStyle.ridge:
        return DecoratedBox(
          decoration:
              _generate3dBoxDecoration(width / 2, _lightSide(), _darkSide()),
          child: _ifBorderRadiusHas(
            (widget) => DecoratedBox(
              decoration: _generate3dBoxDecoration(
                  width / 2, _lightSide(), _darkSide(),
                  isInset: true),
              child: widget,
            ),
            builder2: (widget) => Padding(
              padding: EdgeInsets.all(width / 2),
              child: DecoratedBox(
                decoration: _generate3dBoxDecoration(
                    width / 2, _darkSide(), _lightSide(),
                    hasRadius: false),
                child: widget,
              ),
            ),
            forcePadding: width / 2,
          ),
        );
      case MfmFnBorderStyle.dotted:
        return DottedBorder(
            options: radius == 0
                ? RectDottedBorderOptions(
                    strokeWidth: width,
                    dashPattern: [max(1, width / 10), width * 2],
                    color: color,
                    strokeCap: StrokeCap.round,
                  )
                : RoundedRectDottedBorderOptions(
                    radius: Radius.circular(radius),
                    strokeWidth: width,
                    dashPattern: [max(1, width / 10), width * 2],
                    color: color,
                    strokeCap: StrokeCap.round,
                  ),
            child: MfmFnBorderInner(
                radius: radius,
                padding: 0,
                clipPadding: width * 2,
                isClip: isClip,
                child: child));
      default:
        return MfmFnBorderInner(
            radius: radius, padding: width, isClip: isClip, child: child);
    }
  }
}

class MfmFnBorderInner extends StatelessWidget {
  final double padding;
  final double? clipPadding;
  final double radius;
  final bool isClip;
  final Widget child;

  const MfmFnBorderInner({
    super.key,
    this.clipPadding,
    required this.padding,
    required this.radius,
    required this.isClip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isClip) {
      return Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      );
    }
    if (radius == 0) {
      return ClipRect(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(clipPadding ?? radius),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}
