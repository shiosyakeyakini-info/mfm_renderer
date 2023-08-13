import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:mfm_renderer/src/mfm_blur_state_scope.dart';

class MfmFnBlur extends StatelessWidget {
  final Widget child;

  const MfmFnBlur({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => MfmFnBlurBaseState.of(context)
            .setValue(!MfmFnBlurBaseState.of(context).isBlur),
        child: MfmBlurScope(
          child: !MfmFnBlurBaseState.of(context).isBlur
              ? child
              : ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 6.0,
                    sigmaY: 6.0,
                    tileMode: TileMode.decal,
                  ),
                  child: child,
                ),
        ));
  }
}

class MfmBlurScope extends InheritedWidget {
  final bool inBlurScope = true;

  /// このコンテキストの親に$[blurがある場合、trueを返す
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MfmBlurScope>()?.inBlurScope ??
      false;

  const MfmBlurScope({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
