import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';

class MfmFnBounce extends StatefulWidget {
  final Widget child;

  final double speed;

  const MfmFnBounce({super.key, required this.child, required this.speed});

  @override
  State<StatefulWidget> createState() => MfmFnBounceState();
}

class MfmFnBounceState extends State<MfmFnBounce>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _translateYAnimation;
  final _translateYSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -16.0), weight: 25), // 0% -> 25%
    TweenSequenceItem(
        tween: Tween(begin: -16.0, end: 0.0), weight: 25), // 25% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0), weight: 50), // 50% ->-> 100%
  ]);

  late Animation<double> _scaleXAnimation;
  final _scaleXSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0), weight: 50), // 0% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.5), weight: 25), // 50% -> 75%
    TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 1.0), weight: 25), // 75% -> 100%
  ]);

  late Animation<double> _scaleYAnimation;
  final _scaleYSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0), weight: 50), // 0% -> 50%
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.75), weight: 25), // 50% -> 75%
    TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.0), weight: 25), // 75% -> 100%
  ]);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)))
      ..repeat();

    _translateYAnimation = _controller.drive(_translateYSequence);
    _scaleXAnimation = _controller.drive(_scaleXSequence);
    _scaleYAnimation = _controller.drive(_scaleYSequence);
  }

  @override
  void didUpdateWidget(covariant MfmFnBounce oldWidget) {
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
              offset: Offset(0, _translateYAnimation.value),
              child: Transform.scale(
                scaleX: _scaleXAnimation.value,
                scaleY: _scaleYAnimation.value,
                alignment: Alignment.center,
                child: widget.child,
              ));
        });
  }
}
