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

    return DefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .merge(Mfm.of(context).style ?? const TextStyle())
          .merge(TextStyle(height: Mfm.of(context).lineHeight)),
      child: Text.rich(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MfmElementWidget(nodes: actualNode),
        ),
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        strutStyle: StrutStyle(height: Mfm.of(context).lineHeight),
      ),
    );
  }
}
