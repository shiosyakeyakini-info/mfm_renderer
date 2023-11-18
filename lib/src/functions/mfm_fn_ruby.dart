import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MfmFnRuby extends StatefulWidget {
  final Widget child;
  final String rt;
  final TextStyle? style;

  const MfmFnRuby({
    super.key,
    required this.child,
    required this.rt,
    required this.style,
  });

  @override
  State<StatefulWidget> createState() => MfmFnRubyState();
}

class MfmFnRubyState extends State<MfmFnRuby> {
  double _width = 0;
  double _rtWidth = 0;
  final _key = GlobalKey();

  late final rtStyle = widget.style?.copyWith(
    fontSize: (widget.style?.fontSize ?? 22) * 0.5,
  );

  double calculateLetterSpacing() {
    if (_width == 0) {
      return 0;
    }
    if (widget.rt.length < 2) {
      return 0;
    }
    if (_rtWidth == 0) {
      final painter = TextPainter(
        text: TextSpan(style: rtStyle, text: widget.rt),
        maxLines: 1,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      _rtWidth = painter.width;
    }

    if (_width < _rtWidth) {
      return 0;
    } else {
      return (_width - _rtWidth) / (widget.rt.length - 1);
    }
  }

  @override
  void didUpdateWidget(covariant MfmFnRuby oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rtWidth = 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = (_key.currentContext?.findRenderObject() as RenderBox?)?.size;
    if (_width != size?.width) {
      scheduleMicrotask(() => setState(() => _width = (size?.width ?? 0)));
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text.rich(
          textScaler: TextScaler.noScaling,
          TextSpan(children: [
            if (widget.rt.length > 2) ...[
              TextSpan(
                text: widget.rt.substring(0, widget.rt.length - 1),
                style: rtStyle?.copyWith(
                  letterSpacing: calculateLetterSpacing(),
                ),
              ),
              TextSpan(
                text:
                    widget.rt.substring(widget.rt.length - 1, widget.rt.length),
              )
            ] else
              TextSpan(text: widget.rt, style: rtStyle)
          ]),
          textAlign: TextAlign.center,
          style: rtStyle?.copyWith(
            wordSpacing: 0,
          ),
        ),
        EmptyWidget(key: _key, child: widget.child)
      ],
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final Widget child;

  const EmptyWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
