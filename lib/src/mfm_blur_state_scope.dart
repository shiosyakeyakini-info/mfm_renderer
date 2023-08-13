import 'package:flutter/material.dart';

class MfmFnBlurStateScope extends StatefulWidget {
  final Widget child;

  const MfmFnBlurStateScope({
    super.key,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => MfmFnBlurStateScopeState();
}

class MfmFnBlurStateScopeState extends State<MfmFnBlurStateScope> {
  bool isBlur = true;

  @override
  Widget build(BuildContext context) {
    return MfmFnBlurBaseState(
      isBlur: isBlur,
      setValue: (value) => setState(() => isBlur = !isBlur),
      child: widget.child,
    );
  }
}

class MfmFnBlurBaseState extends InheritedWidget {
  final bool isBlur;

  final void Function(bool value) setValue;

  const MfmFnBlurBaseState({
    super.key,
    required this.isBlur,
    required this.setValue,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant MfmFnBlurBaseState oldWidget) =>
      oldWidget.isBlur != isBlur;

  static MfmFnBlurBaseState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MfmFnBlurBaseState>()!;
}
