import 'dart:ui';

import 'package:flutter/widgets.dart';

class MfmFnBlur extends StatefulWidget {
  final Widget child;

  const MfmFnBlur({super.key, required this.child});
  @override
  State<StatefulWidget> createState() => MfmFnBlurState();
}

class MfmFnBlurState extends State<MfmFnBlur> {
  bool isBlur = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => isBlur = !isBlur);
      },
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: isBlur ? 10.0 : 0,
          sigmaY: isBlur ? 10.0 : 0,
        ),
        child: widget.child,
      ),
    );
  }
}
