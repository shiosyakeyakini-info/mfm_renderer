import 'package:flutter/cupertino.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm/src/extension/string_extension.dart';

/// simplify mfm
class SimpleMfm extends StatefulWidget {
  final String mfmText;
  final EmojiBuilder? emojiBuilder;
  final UnicodeEmojiBuilder? unicodeEmojiBuilder;
  final TextStyle? style;
  final List<InlineSpan> suffixSpan;
  final List<InlineSpan> prefixSpan;
  final bool isNyaize;

  const SimpleMfm(
    this.mfmText, {
    super.key,
    this.style,
    this.emojiBuilder,
    this.unicodeEmojiBuilder,
    this.isNyaize = false,
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
    if (oldWidget.mfmText != widget.mfmText ||
        oldWidget.style != widget.style ||
        oldWidget.suffixSpan != widget.suffixSpan ||
        oldWidget.prefixSpan != widget.prefixSpan ||
        oldWidget.unicodeEmojiBuilder != widget.unicodeEmojiBuilder ||
        oldWidget.emojiBuilder != widget.emojiBuilder) {
      parsed = const MfmParser().parseSimple(widget.mfmText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: const MediaQueryData(textScaleFactor: 1.0),
      child: DefaultTextStyle.merge(
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
                    child: widget.emojiBuilder
                            ?.call(context, element.name, widget.style) ??
                        Text(
                          ":${element.name}:",
                          style: DefaultTextStyle.of(context).style,
                        ))
              else if (element is MfmText)
                TextSpan(
                    text: widget.isNyaize ? element.text.nyaize : element.text),
            ...widget.suffixSpan,
          ]),
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
          style: widget.style,
        ),
      ),
    );
  }
}
