import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/mfm_renderer.dart';
import 'package:mfm_renderer/src/mfm_element_widget.dart';

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
    if (nodes == null) {
      actualNode = const MfmParser().parse(Mfm.of(context).mfmText);
    } else {
      actualNode = nodes!;
    }

    final style = Theme.of(context)
        .textTheme
        .bodyMedium!
        .merge(Mfm.of(context).style ?? const TextStyle())
        .merge(const TextStyle(height: 0));

    return Text.rich(
      TextSpan(children: [
        ...Mfm.of(context).prefixSpan,
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MfmElementWidget(
            nodes: actualNode,
            style: style,
          ),
        ),
        ...Mfm.of(context).suffixSpan,
      ]),
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      strutStyle: StrutStyle(height: Mfm.of(context).lineHeight),
    );
  }
}
