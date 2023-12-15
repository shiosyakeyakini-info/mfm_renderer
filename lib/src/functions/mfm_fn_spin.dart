import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';
import 'package:vector_math/vector_math_64.dart';

enum MfmFnSpinDirection { normal, reverse, alternate }

enum MfmFnSpinType { x, y, both }

class MfmFnSpin extends StatefulWidget {
  final Widget child;

  final MfmFnSpinDirection direction;
  final MfmFnSpinType type;
  final double speed;
  final double delay;

  const MfmFnSpin({
    super.key,
    required this.direction,
    required this.type,
    required this.child,
    required this.speed,
    required this.delay,
  });

  @override
  State<StatefulWidget> createState() => MfmFnSpinState();
}

class MfmFnSpinState extends State<MfmFnSpin> with TickerProviderStateMixin {
  AnimationController? _controller;

  Animation<double>? _rotationAnimation;
  final _rotationSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 360.0), weight: 1), // 0% -> 100%
  ]);

  final _rotationReverseSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 360.0, end: 0.0), weight: 1), // 0% -> 100%
  ]);

  final _rotationAlternativeSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 360.0), weight: 1), // 0% -> 100%
    TweenSequenceItem(
        tween: Tween(begin: 360.0, end: 0.0), weight: 1), // 0% -> 100%
  ]);

  void startAnimation() {
    _controller?.stop();
    _controller?.dispose();
    final controller = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: (widget.speed * 1000).toInt().if0(999) *
                (widget.direction == MfmFnSpinDirection.alternate ? 2 : 1)));

    Future(() async {
      await Future.delayed(
          Duration(milliseconds: (widget.delay * 1000).toInt()));

      if (widget.direction == MfmFnSpinDirection.reverse) {
        controller.repeat();
        _rotationAnimation = controller.drive(_rotationReverseSequence);
      } else if (widget.direction == MfmFnSpinDirection.alternate) {
        controller.repeat();
        _rotationAnimation = controller.drive(_rotationAlternativeSequence);
      } else if (widget.direction == MfmFnSpinDirection.normal) {
        controller.repeat();
        _rotationAnimation = controller.drive(_rotationSequence);
      }
    });

    _controller = controller;
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  void didUpdateWidget(covariant MfmFnSpin oldWidget) {
    super.didUpdateWidget(oldWidget);
    startAnimation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final animation = _rotationAnimation;
    if (controller == null || animation == null || widget.speed <= 0) {
      return widget.child;
    }

    return AnimatedBuilder(
        animation: controller,
        child: widget.child,
        builder: (context, child) {
          final degree = animation.value * pi / 180;
          final matrix4 = widget.type == MfmFnSpinType.x
              ? Matrix4.rotationX(degree)
              : widget.type == MfmFnSpinType.y
                  ? Matrix4.rotationY(degree)
                  : Matrix4.rotationZ(degree);

          if (widget.type != MfmFnSpinType.both) {
            matrix4.transform3(matrix4.perspectiveTransform(Vector3.all(128)));
          }

          return Transform(
            transform: matrix4,
            alignment: Alignment.center,
            child: widget.child,
          );
        });
  }
}
