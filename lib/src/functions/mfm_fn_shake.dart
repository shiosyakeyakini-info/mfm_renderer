import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';

class MfmFnShake extends StatefulWidget {
  final Widget child;

  final double speed;
  final double delay;

  const MfmFnShake(
      {super.key,
      required this.child,
      required this.speed,
      required this.delay});

  @override
  State<StatefulWidget> createState() => MfmFnShakeState();
}

class MfmFnShakeState extends State<MfmFnShake> with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _translateAnimation;
  final _translateSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-3, -1), end: const Offset(0, -1)),
        weight: 5), // 0% -> 5%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -1), end: const Offset(1, -3)),
        weight: 5), // 5% -> 10%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(1, -3), end: const Offset(1, 1)),
        weight: 5), // 10% -> 15%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(1, 1), end: const Offset(-2, 1)),
        weight: 5), // 15% -> 20%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-2, 1), end: const Offset(-1, -2)),
        weight: 5), // 20% -> 25%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-1, -2), end: const Offset(-1, 2)),
        weight: 5), // 25% -> 30%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-1, 2), end: const Offset(2, 1)),
        weight: 5), // 30% -> 35%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(2, 1), end: const Offset(-2, -3)),
        weight: 5), // 35% -> 40%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-2, -3), end: const Offset(0, -1)),
        weight: 5), // 40% -> 45%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -1), end: const Offset(1, 2)),
        weight: 5), // 45% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(1, 2), end: const Offset(0, -3)),
        weight: 5), // 50% -> 55%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -3), end: const Offset(1, -1)),
        weight: 5), // 55% -> 60%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(1, -1), end: const Offset(0, -1)),
        weight: 5), // 60% -> 65%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -1), end: const Offset(-1, -3)),
        weight: 5), // 65% -> 70%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-1, -3), end: const Offset(0, -2)),
        weight: 5), // 70% -> 75%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -2), end: const Offset(-2, -1)),
        weight: 5), // 75% -> 80%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-2, -1), end: const Offset(1, -3)),
        weight: 5), // 80% -> 85%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(1, -3), end: const Offset(1, 0)),
        weight: 5), // 85% -> 90%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(1, 0), end: const Offset(-2, 0)),
        weight: 5), // 90% -> 95%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-2, 0), end: const Offset(2, 1)),
        weight: 5), // 95% -> 100%
  ]);

  late Animation<double> _rotateAnimation;
  final _rotateSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: -8.0, end: -10.0), weight: 5), // 0% -> 5%
    TweenSequenceItem(
        tween: Tween(begin: -10.0, end: 0.0), weight: 5), // 5% -> 10%
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 11.0), weight: 5), // 10% -> 15%
    TweenSequenceItem(
        tween: Tween(begin: 11.0, end: 1.0), weight: 5), // 15% -> 20%
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: -2.0), weight: 5), // 20% -> 25%
    TweenSequenceItem(
        tween: Tween(begin: -2.0, end: -3.0), weight: 5), // 25% -> 30%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 6.0), weight: 5), // 30% -> 35%
    TweenSequenceItem(
        tween: Tween(begin: 6.0, end: -9.0), weight: 5), // 35% -> 40%
    TweenSequenceItem(
        tween: Tween(begin: -9.0, end: -12.0), weight: 5), // 40% -> 45%
    TweenSequenceItem(
        tween: Tween(begin: -12.0, end: 10.0), weight: 5), // 45% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: 10.0, end: 8.0), weight: 5), // 50% -> 55%
    TweenSequenceItem(
        tween: Tween(begin: 8.0, end: 8.0), weight: 5), // 55% -> 60%
    TweenSequenceItem(
        tween: Tween(begin: 8.0, end: -7.0), weight: 5), // 60% -> 65%
    TweenSequenceItem(
        tween: Tween(begin: -7.0, end: 6.0), weight: 5), // 65% -> 70%
    TweenSequenceItem(
        tween: Tween(begin: 6.0, end: 4.0), weight: 5), // 70% -> 75%
    TweenSequenceItem(
        tween: Tween(begin: 4.0, end: 3.0), weight: 5), // 75% -> 80%
    TweenSequenceItem(
        tween: Tween(begin: 3.0, end: -10.0), weight: 5), // 80% -> 85%
    TweenSequenceItem(
        tween: Tween(begin: -10.0, end: 3.0), weight: 5), // 85% -> 90%
    TweenSequenceItem(
        tween: Tween(begin: 3.0, end: -3.0), weight: 5), // 90% -> 95%
    TweenSequenceItem(
        tween: Tween(begin: -3.0, end: 2.0), weight: 5), // 95% -> 100%
  ]);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)));

    _translateAnimation = _controller.drive(_translateSequence);
    _rotateAnimation = _controller.drive(_rotateSequence);

    Future(() async {
      await Future.delayed(
          Duration(milliseconds: (widget.delay * 1000).toInt()));
      _controller.repeat();
    });
  }

  @override
  void didUpdateWidget(covariant MfmFnShake oldWidget) {
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
          return Transform.translate(
            offset: _translateAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value / 180 * pi,
              child: widget.child,
            ),
          );
        });
  }
}
