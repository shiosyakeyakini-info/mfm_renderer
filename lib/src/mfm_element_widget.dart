import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm/src/mfm_align_scope.dart';
import 'package:mfm/src/mfm_inline_span.dart';

class MfmElementWidget extends StatefulWidget {
  final List<MfmNode>? nodes;
  final TextStyle? style;
  final int depth;

  const MfmElementWidget({
    super.key,
    required this.nodes,
    required this.style,
    required this.depth,
  });

  @override
  State<StatefulWidget> createState() => MfmElementWidgetState();
}

class MfmElementWidgetState extends State<MfmElementWidget> {
  MfmInlineSpan? inlineSpan;

  @override
  void didUpdateWidget(covariant MfmElementWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    inlineSpan = null;
  }

  @override
  Widget build(BuildContext context) {
    inlineSpan ??= MfmInlineSpan(
        nodes: widget.nodes ?? [],
        style: widget.style,
        context: context,
        depth: widget.depth);

    return Text.rich(
      inlineSpan!,
      textAlign: MfmAlignScope.of(context),
      textScaler: const TextScaler.linear(1),
    );
  }
}
