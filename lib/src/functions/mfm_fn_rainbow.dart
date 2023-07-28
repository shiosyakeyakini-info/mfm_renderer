import 'package:flutter/material.dart';
import 'package:mfm_renderer/src/extension/int_extension.dart';
import 'package:themed/themed.dart';

class MfmRainbow extends StatefulWidget {
  final Widget child;

  final double speed;

  const MfmRainbow({super.key, required this.child, required this.speed});

  @override
  State<StatefulWidget> createState() => MfmRainbowState();
}

class MfmRainbowState extends State<MfmRainbow> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)))
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant MfmRainbow oldWidget) {
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
          return ChangeColors(
              hue: _controller.value * 2 - 1,
              saturation: 1.5,
              brightness: 1.5,
              child: widget.child);
        });
  }
}
