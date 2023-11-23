import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:mfm/src/mfm_blur_state_scope.dart';

/// `$[blur ]` Widget
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

/// `$[blur ] scoped widget.
class MfmBlurScope extends InheritedWidget {
  final bool inBlurScope = true;

  /// return true if context's parent has `$[blur ]`.
  /// It will be used to detect `$[blur` outside emojis when tapped emojis (such as `$[blur :emoji:]`)
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MfmBlurScope>()?.inBlurScope ??
      false;

  const MfmBlurScope({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
