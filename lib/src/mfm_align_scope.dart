import 'package:flutter/material.dart';

class MfmAlignScope extends InheritedWidget {
  final TextAlign align;

  const MfmAlignScope({
    super.key,
    required super.child,
    required this.align,
  });

  static TextAlign of(BuildContext context) {
    final mfmWidgetScope =
        context.dependOnInheritedWidgetOfExactType<MfmAlignScope>();
    if (mfmWidgetScope == null) {
      return TextAlign.start;
    }

    return mfmWidgetScope.align;
  }

  @override
  bool updateShouldNotify(covariant MfmAlignScope oldWidget) =>
      oldWidget.align != align;
}
