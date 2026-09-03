import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mfm/src/extension/int_extension.dart';
import 'package:vector_math/vector_math_64.dart' show Vector4;

enum MfmFnSpinDirection { normal, reverse, alternate }

enum MfmFnSpinType { x, y, both }

/// 本家がspin.x / spin.yに適用しているperspectiveの距離(px)。
/// https://github.com/misskey-dev/misskey packages/frontend/src/style.scss
/// `transform: perspective(128px) rotateX(360deg);`
const double _perspective = 128.0;

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
    _controller = null;

    Future(() async {
      final controller = AnimationController(
          vsync: this,
          duration: Duration(
              milliseconds: (widget.speed * 1000).toInt().if0(999) *
                  (widget.direction == MfmFnSpinDirection.alternate ? 2 : 1)));
      await Future.delayed(
          Duration(milliseconds: (widget.delay * 1000).toInt()));

      if (widget.direction == MfmFnSpinDirection.reverse) {
        _rotationAnimation = controller.drive(_rotationReverseSequence);
        controller.repeat();
      } else if (widget.direction == MfmFnSpinDirection.alternate) {
        _rotationAnimation = controller.drive(_rotationAlternativeSequence);
        controller.repeat();
      } else if (widget.direction == MfmFnSpinDirection.normal) {
        _rotationAnimation = controller.drive(_rotationSequence);
        controller.repeat();
      }
      setState(() {
        _controller = controller;
      });
    });
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
          final rotation = widget.type == MfmFnSpinType.x
              ? Matrix4.rotationX(degree)
              : widget.type == MfmFnSpinType.y
                  ? Matrix4.rotationY(degree)
                  : Matrix4.rotationZ(degree);

          // 本家と同じく、X軸・Y軸回転のときのみ透視投影をかける。
          // Z軸回転(spin)は平面内の回転なので透視投影は適用しない。
          // CSSの `perspective(d)` は行列の m34 に -1/d を設定するもので、
          // `perspective(128px) rotateX(deg)` は 透視投影行列 * 回転行列 となる。
          final matrix4 = widget.type == MfmFnSpinType.both
              ? rotation
              : (Matrix4.identity()..setEntry(3, 2, -1 / _perspective))
                  .multiplied(rotation);

          // CSSの`transform-style`は既定が`flat`で、入れ子になった要素は
          // 内側の投影結果がいったん平面に潰されてから外側のtransformを受ける。
          // Flutterの[Transform]は4x4をそのまま掛け合わせるので、何もしないと
          // `preserve-3d`相当になり、`$[spin.y $[spin.y,left ]]`のような
          // 入れ子で内と外の回転が3D空間で打ち消し合ってしまう。
          // z成分を平面に落としておくと、掛け合わせても本家と同じ
          // 「内側の見た目に外側がかかる」合成になる。
          matrix4.setRow(2, Vector4(0, 0, 1, 0));

          return Transform(
            transform: matrix4,
            alignment: Alignment.center,
            child: widget.child,
          );
        });
  }
}
