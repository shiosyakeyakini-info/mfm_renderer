import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm/src/mfm_blur_state_scope.dart';
import 'package:mfm/src/mfm_element_widget.dart';

class MfmParentWidget extends StatefulWidget {
  const MfmParentWidget({super.key});

  @override
  State<StatefulWidget> createState() => MfmParentWidgetState();
}

class MfmParentWidgetState extends State<MfmParentWidget> {
  List<MfmNode>? nodes;

  @override
  Widget build(BuildContext context) {
    final List<MfmNode> actualNode;
    final parentMfmNode = Mfm.of(context).mfmNode;
    if (nodes == null && parentMfmNode == null) {
      actualNode = const MfmParser().parse(Mfm.of(context).mfmText!);
    } else if (parentMfmNode != null) {
      actualNode = parentMfmNode;
    } else {
      actualNode = nodes!;
    }

    final style = Theme.of(context)
        .textTheme
        .bodyMedium!
        .merge(Mfm.of(context).style ?? const TextStyle())
        .merge(const TextStyle(height: 0));

    final scaledStyle = style.copyWith(
        fontSize: style.fontSize! * MediaQuery.of(context).textScaleFactor);

    return MfmFnBlurStateScope(
      child: DefaultTextStyle.merge(
        style: scaledStyle,
        overflow: Mfm.of(context).overflow,
        maxLines: Mfm.of(context).maxLines,
        child: Text.rich(
          TextSpan(style: style, children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.aboveBaseline,
              baseline: TextBaseline.alphabetic,
              child: MfmElementWidget(
                nodes: actualNode,
                style: style,
                depth: 0,
              ),
            ),
          ]),
          strutStyle: StrutStyle(height: Mfm.of(context).lineHeight),
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
        ),
      ),
    );
  }
}
