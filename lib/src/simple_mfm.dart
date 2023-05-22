import 'package:flutter/cupertino.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm_renderer/mfm_renderer.dart';

/// simplify mfm
class SimpleMfm extends StatefulWidget {
  final String mfmText;
  final EmojiBuilder? emojiBuilder;
  final UnicodeEmojiBuilder? unicodeEmojiBuilder;
  final TextStyle? style;
  final List<InlineSpan> suffixSpan;
  final List<InlineSpan> prefixSpan;

  const SimpleMfm(
    this.mfmText, {
    super.key,
    this.style,
    this.emojiBuilder,
    this.unicodeEmojiBuilder,
    this.suffixSpan = const [],
    this.prefixSpan = const [],
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
  void didUpdateWidget(covariant SimpleMfm oldWidget) {
    super.didUpdateWidget(oldWidget);

    parsed = const MfmParser().parseSimple(widget.mfmText);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: widget.style,
      child: Text.rich(
        TextSpan(children: [
          ...widget.prefixSpan,
          for (final element in parsed)
            if (element is MfmUnicodeEmoji)
              widget.unicodeEmojiBuilder
                      ?.call(context, element.emoji, widget.style) ??
                  TextSpan(text: element.emoji)
            else if (element is MfmEmojiCode)
              WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: widget.emojiBuilder?.call(context, element.name) ??
                      Text(
                        "element.name",
                        style: DefaultTextStyle.of(context).style,
                      ))
            else if (element is MfmText)
              TextSpan(text: element.text),
          ...widget.suffixSpan,
        ]),
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        style: widget.style,
      ),
    );
  }
}
