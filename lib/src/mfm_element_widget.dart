import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/src/mfm_align_scope.dart';
import 'package:mfm_renderer/src/mfm_inline_span.dart';

class MfmElementWidget extends StatefulWidget {
  final List<MfmNode>? nodes;
  final TextStyle? style;

  const MfmElementWidget({super.key, required this.nodes, required this.style});

  @override
  State<StatefulWidget> createState() => MfmElementWidgetState();
}

class MfmElementWidgetState extends State<MfmElementWidget> {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          MfmInlineSpan(
              nodes: widget.nodes ?? [], style: widget.style, context: context)
        ],
      ),
      textAlign: MfmAlignScope.of(context),
      textScaleFactor: 1,
    );
  }
}
