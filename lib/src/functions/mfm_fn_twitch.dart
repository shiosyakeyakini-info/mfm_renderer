import 'package:flutter/material.dart';
import 'package:mfm_renderer/src/extension/int_extension.dart';

class MfmFnTwitch extends StatefulWidget {
  final Widget child;

  final double speed;

  const MfmFnTwitch({super.key, required this.child, required this.speed});

  @override
  State<StatefulWidget> createState() => MfmFnTwitchState();
}

class MfmFnTwitchState extends State<MfmFnTwitch>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _translateAnimation;
  final _translateSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: const Offset(7, -2), end: const Offset(-3, 1)),
        weight: 5), // 0% -> 5%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-3, 1), end: const Offset(-7, -1)),
        weight: 5), // 5% -> 10%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-7, -1), end: const Offset(0, -1)),
        weight: 5), // 10% -> 15%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(0, -1), end: const Offset(-8, 6)),
        weight: 5), // 15% -> 20%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-8, 6), end: const Offset(-4, -3)),
        weight: 5), // 20% -> 25%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-4, -3), end: const Offset(-4, -6)),
        weight: 5), // 25% -> 30%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-4, -6), end: const Offset(-8, -8)),
        weight: 5), // 30% -> 35%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-8, -8), end: const Offset(4, 6)),
        weight: 5), // 35% -> 40%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(4, 6), end: const Offset(-3, 1)),
        weight: 5), // 40% -> 45%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-3, 1), end: const Offset(2, -10)),
        weight: 5), // 45% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(2, -10), end: const Offset(-7, 0)),
        weight: 5), // 50% -> 55%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-7, 0), end: const Offset(-2, 4)),
        weight: 5), // 55% -> 60%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-2, 4), end: const Offset(3, -8)),
        weight: 5), // 60% -> 65%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(3, -8), end: const Offset(6, 7)),
        weight: 5), // 65% -> 70%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(6, 7), end: const Offset(-7, -2)),
        weight: 5), // 70% -> 75%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-7, -2), end: const Offset(-7, -8)),
        weight: 5), // 75% -> 80%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-7, -8), end: const Offset(9, 3)),
        weight: 5), // 80% -> 85%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(9, 3), end: const Offset(-3, -2)),
        weight: 5), // 85% -> 90%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-3, -2), end: const Offset(-10, 2)),
        weight: 5), // 90% -> 95%
    TweenSequenceItem(
        tween: Tween(begin: const Offset(-10, 2), end: const Offset(-2, -6)),
        weight: 5), // 95% -> 100%
  ]);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)))
      ..repeat();

    _translateAnimation = _controller.drive(_translateSequence);
  }

  @override
  void didUpdateWidget(covariant MfmFnTwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    _controller.duration =
        Duration(milliseconds: (widget.speed * 1000).toInt().if0(999));
    _controller.reset();
    _controller.repeat();
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
            child: widget.child,
          );
        });
  }
}
