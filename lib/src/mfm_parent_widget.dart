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

    final scaledStyle = style.copyWith(
        fontSize: style.fontSize! * MediaQuery.of(context).textScaleFactor);

    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
      child: DefaultTextStyle.merge(
        style: scaledStyle,
        child: Text.rich(
          TextSpan(style: style, children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
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
