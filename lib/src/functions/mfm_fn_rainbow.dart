import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';

class MfmRainbow extends StatefulWidget {
  final Widget child;

  final double speed;
  final double delay;

  const MfmRainbow(
      {super.key,
      required this.child,
      required this.speed,
      required this.delay});

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
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)));

    Future(() async {
      await Future.delayed(
          Duration(milliseconds: (widget.delay * 1000).toInt()));
      _controller.repeat();
    });
  }

  @override
  void didUpdateWidget(covariant MfmRainbow oldWidget) {
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
          return ColorFiltered(
              colorFilter: ColorFilter.matrix(ColorFilterGenerator(
                name: "base",
                filters: [
                  ColorFilterAddons.hue(_controller.value * 2 - 1),
                  ColorFilterAddons.contrast(0.5),
                  ColorFilterAddons.saturation(1.5)
                ],
              ).matrix),
              child: widget.child);
        });
  }
}
