import 'package:flutter/cupertino.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/mfm_renderer.dart';

/// simplify mfm
class SimpleMfm extends StatefulWidget {
  final String mfmText;
  final EmojiBuilder? emojiBuilder;
  final UnicodeEmojiBuilder? unicodeEmojiBuilder;

  const SimpleMfm(
    this.mfmText, {
    super.key,
    required this.emojiBuilder,
    required this.unicodeEmojiBuilder,
  });

  @override
  State<StatefulWidget> createState() => SimpleMfmScope();
}

class SimpleMfmScope extends State<SimpleMfm> {
  late List<MfmNode> parsed;

  @override
  void initState() {
    super.initState();
    parsed = const MfmParser().parseSimple(widget.mfmText);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        for (final element in parsed)
          if (element is MfmUnicodeEmoji)
            WidgetSpan(
                child:
                    widget.unicodeEmojiBuilder?.call(context, element.emoji) ??
                        Text(element.emoji))
          else if (element is MfmEmojiCode)
            WidgetSpan(
                child: widget.emojiBuilder?.call(context, element.name) ??
                    Text(":${element.name}:"))
          else if (element is MfmText)
            TextSpan(text: element.text)
      ]),
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    );
  }
}
