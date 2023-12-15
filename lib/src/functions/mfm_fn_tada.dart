import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';

class MfmFnTada extends StatefulWidget {
  final Widget child;

  final double speed;
  final double delay;

  const MfmFnTada(
      {super.key,
      required this.child,
      required this.speed,
      required this.delay});

  @override
  State<StatefulWidget> createState() => MfmFnTadaState();
}

class MfmFnTadaState extends State<MfmFnTada> with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scaleAnimation;
  final _scaleSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.9), weight: 10), // 0% -> 10%
    TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 0.9), weight: 10), //10% -> 20%
    TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.1), weight: 10), //20% -> 30%
    TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.1), weight: 90 - 30), //30% -> 90%
    TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0), weight: 10) //90% -> 100%
  ]);

  late Animation<double> _rotateAnimation;
  final _rotateSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -3.0), weight: 10), //0% -> 10%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 3.0), weight: 10), //10% -> 20%
    TweenSequenceItem(
        tween: Tween(begin: 3.0, end: -3.0), weight: 10), //20% -> 30%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 3.0), weight: 10), //30% -> 40%
    TweenSequenceItem(
        tween: Tween(begin: 3.0, end: -3.0), weight: 10), //40% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 3.0), weight: 10), //50% -> 60%
    TweenSequenceItem(
        tween: Tween(begin: 3.0, end: -3.0), weight: 10), //60% -> 70%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 3.0), weight: 10), //70% -> 80%
    TweenSequenceItem(
        tween: Tween(begin: 3.0, end: -3.0), weight: 10), //80% -> 90%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 0.0), weight: 10), //90% -> 100%
  ]);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)));

    _scaleAnimation = _controller.drive(_scaleSequence);
    _rotateAnimation = _controller.drive(_rotateSequence);

    Future(() async {
      await Future.delayed(
          Duration(milliseconds: (widget.delay * 1000).toInt()));
      _controller.repeat();
    });
  }

  @override
  void didUpdateWidget(covariant MfmFnTada oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller.duration =
        Duration(milliseconds: (widget.speed * 1000).toInt().if0(999));
    _controller.reset();
    Future(() async {
      await Future.delayed(
          Duration(milliseconds: (widget.delay * 1000).toInt()));
      _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.speed <= 0) {
      return widget.child;
    }

    return AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          return Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(_scaleAnimation.value,
                  _scaleAnimation.value, _scaleAnimation.value),
              child: Transform.rotate(
                angle: _rotateAnimation.value * (pi / 180),
                child: child,
              ));
        });
  }
}
