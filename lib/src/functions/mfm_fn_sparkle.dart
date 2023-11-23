import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';

class MfmFnSparkle extends StatefulWidget {
  final Widget child;
  final double speed;

  const MfmFnSparkle({super.key, required this.child, required this.speed});

  @override
  State<StatefulWidget> createState() => MfmFnSparkleState();
}

class MfmFnSparkleState extends State<MfmFnSparkle>
    with TickerProviderStateMixin {
  final List<OverlayEntry> _overlayEntries = [];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final overlayState = Overlay.of(context);
      final targetOffset = renderBox.localToGlobal(Offset.zero);
      if (targetOffset.dx.isNaN ||
          targetOffset.dy.isNaN ||
          renderBox.size.width.isNaN) return;

      final entry = OverlayEntry(builder: (context) {
        return Positioned(
          left: targetOffset.dx,
          top: targetOffset.dy,
          child: SparkleParticle(
            areaSize: renderBox.size,
            speed: widget.speed,
          ),
        );
      });
      overlayState.insert(entry);
      _overlayEntries.add(entry);

      if (_overlayEntries.length >= 5) {
        _overlayEntries[0].remove();
        _overlayEntries.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (final entry in _overlayEntries) {
      entry.remove();
    }
    _overlayEntries.clear();
    timer?.cancel();
    timer = null;
  }

  @override
  void didUpdateWidget(covariant MfmFnSparkle oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final entry in _overlayEntries) {
      entry.remove();
    }
    _overlayEntries.clear();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class SparkleParticle extends StatefulWidget {
  final Size areaSize;
  final double speed;

  const SparkleParticle(
      {super.key, required this.areaSize, required this.speed});

  @override
  State<StatefulWidget> createState() => SparkleParticleState();
}

class SparkleParticleState extends State<SparkleParticle>
    with TickerProviderStateMixin {
  static final random = Random();

  static const colors = [
    Color.fromRGBO(0xFF, 0x14, 0x93, 1),
    Color.fromRGBO(0x00, 0xFF, 0xFF, 1),
    Color.fromRGBO(0xFF, 0xE2, 0x02, 1),
    Color.fromRGBO(0xFF, 0xE2, 0x02, 1),
    Color.fromRGBO(0xFF, 0xE2, 0x02, 1),
  ];
  final color = colors[random.nextInt(colors.length)];
  final sizeFactor = random.nextDouble();
  late final offset = Offset(widget.areaSize.width * random.nextDouble(),
      widget.areaSize.height * random.nextDouble());

  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  final _rotationSequence = TweenSequence([
    TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 360.0), weight: 1), // 0% -> 100%
  ]);
  late Animation<double> _scaleAnimation;
  late double maxSize =
      MediaQuery.of(context).textScaler.scale(16 * random.nextDouble()) +
          0.2 * (sizeFactor / 10 * 3);
  late final _scaleSequence = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
  ]);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (widget.speed * 1000).toInt().if0(999)))
      ..repeat();

    _rotationAnimation = _controller.drive(_rotationSequence);
    _scaleAnimation = _controller.drive(_scaleSequence);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: _rotationAnimation.value / 180 * pi,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  Icons.star,
                  size: maxSize,
                  color: color,
                ),
              ),
            ),
          );
        });
  }
}
