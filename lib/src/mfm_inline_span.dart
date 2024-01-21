import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm/mfm.dart';
import 'package:mfm/src/extension/string_extension.dart';
import 'package:mfm/src/mfm_align_scope.dart';
import 'package:mfm/src/mfm_default_search_widget.dart';
import 'package:mfm/src/mfm_element_widget.dart';
import 'package:mfm/src/mfm_fn_span.dart';

Widget _defaultEmojiBuilder(
        BuildContext context, String emojiName, TextStyle? style) =>
    Text.rich(
      TextSpan(text: ":$emojiName:"),
      textAlign: MfmAlignScope.of(context),
      textScaleFactor: 1,
    );

InlineSpan _defaultUnicodeEmojiBuilder(
        BuildContext context, String emoji, TextStyle? style) =>
    TextSpan(text: emoji, style: style);

TextStyle _defaultSmallStyleBuilder(BuildContext context, double? fontSize) =>
    TextStyle(
      fontSize: (fontSize ?? 22) * 0.8,
      color: Theme.of(context).disabledColor,
    );

Widget _defaultCodeBlockBuilder(
        BuildContext context, String code, String? language) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: const BoxDecoration(color: Colors.black87),
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Text(
          code,
          style: (Mfm.of(context).monospaceStyle ?? const TextStyle()).copyWith(
            color: Colors.white70,
          ),
          textScaleFactor: 1.0,
        ),
      ),
    );

Widget _defaultInlineCodeBuilder(
        BuildContext context, String code, TextStyle? style) =>
    Container(
      decoration: const BoxDecoration(color: Colors.black87),
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Text.rich(
        textScaleFactor: 1.0,
        textAlign: MfmAlignScope.of(context),
        TextSpan(
            style: (style ?? const TextStyle())
                .merge(Mfm.of(context).monospaceStyle ?? const TextStyle())
                .copyWith(color: Colors.white70),
            text: code),
      ),
    );

Widget _defaultQuoteBuilder(BuildContext context, Widget child) => Padding(
      padding: const EdgeInsets.only(left: 5, top: 5),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
              left:
                  BorderSide(color: Theme.of(context).dividerColor, width: 3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: DefaultTextStyle.merge(
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            child: child,
          ),
        ),
      ),
    );

Widget _defaultSearchBuilder(
        BuildContext context, String query, SearchTapCallback? onPressed) =>
    MfmDefaultSearch(query: query, callback: onPressed);

class MfmInlineSpan extends TextSpan {
  final List<MfmNode>? nodes;
  final BuildContext context;
  final int depth;

  late final List<InlineSpan> _children;

  MfmInlineSpan({
    required this.nodes,
    required super.style,
    required this.context,
    required this.depth,
    super.recognizer,
  }) {
    _children = buildChildren();
  }

  List<InlineSpan> buildChildren() {
    return [
      if (depth == 0) ...Mfm.of(context).prefixSpan,
      for (final node in nodes ?? [])
        if (node is MfmText)
          TextSpan(
            text: Mfm.of(context).isNyaize
                ? node.text.nyaize
                : node.text, /*style: style*/
          )
        else if (node is MfmCenter)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(
              width: double.infinity,
              child: MfmAlignScope(
                  align: TextAlign.center,
                  child: MfmElementWidget(
                    nodes: node.children,
                    style: style,
                    depth: depth + 1,
                  )),
            ),
          )
        else if (node is MfmCodeBlock)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child:
                (Mfm.of(context).codeBlockBuilder ?? _defaultCodeBlockBuilder)
                    .call(context, node.code, node.lang),
          )
        else if (node is MfmSearch)
          WidgetSpan(
              child: (Mfm.of(context).searchBuilder ?? _defaultSearchBuilder)
                  .call(context, node.query, Mfm.of(context).searchTap))
        else if (node is MfmEmojiCode)
          WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: DefaultTextStyle(
                  style: style ?? const TextStyle(),
                  child: (Mfm.of(context).emojiBuilder ?? _defaultEmojiBuilder)
                      .call(context, node.name, style)))
        else if (node is MfmUnicodeEmoji)
          (Mfm.of(context).unicodeEmojiBuilder ?? _defaultUnicodeEmojiBuilder)
              .call(context, node.emoji, style)
        else if (node is MfmBold)
          MfmInlineSpan(
              context: context,
              style: style?.merge(Mfm.of(context).boldStyle),
              nodes: node.children,
              depth: depth + 1)
        else if (node is MfmSmall)
          MfmInlineSpan(
              context: context,
              style: style?.merge(
                  (Mfm.of(context).smallStyleBuilder ?? _defaultSmallStyleBuilder)
                      .call(context, style?.fontSize)),
              nodes: node.children,
              depth: depth + 1)
        else if (node is MfmItalic)
          MfmInlineSpan(
              context: context,
              style: style?.merge(const TextStyle(fontStyle: FontStyle.italic)),
              nodes: node.children,
              depth: depth + 1)
        else if (node is MfmStrike)
          MfmInlineSpan(
              context: context,
              style:
                  style?.merge(const TextStyle(decoration: TextDecoration.lineThrough)),
              nodes: node.children,
              depth: depth + 1)
        else if (node is MfmPlain)
          TextSpan(text: node.text, style: style)
        else if (node is MfmInlineCode)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child:
                (Mfm.of(context).inlineCodeBuilder ?? _defaultInlineCodeBuilder)
                    .call(context, node.code, style),
          )
        else if (node is MfmQuote)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: (Mfm.of(context).quoteBuilder ?? _defaultQuoteBuilder).call(
              context,
              MfmElementWidget(
                nodes: node.children,
                style: style,
                depth: depth + 1,
              ),
            ),
          )
        else if (node is MfmMention)
          TextSpan(
            style: style?.merge(
              Mfm.of(context).mentionStyle ??
                  TextStyle(color: Theme.of(context).primaryColor),
            ),
            text: node.acct.tight,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Mfm.of(context)
                  .mentionTap
                  ?.call(node.username, node.host, node.acct),
          )
        else if (node is MfmHashTag)
          TextSpan(
              style: style?.merge(
                Mfm.of(context).hashtagStyle ??
                    TextStyle(color: Theme.of(context).primaryColor),
              ),
              text: "#${node.hashTag.tight}",
              recognizer: TapGestureRecognizer()..onTap = () => Mfm.of(context).hashtagTap?.call(node.hashTag))
        else if (node is MfmLink)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => Mfm.of(context).linkTap?.call(node.url),
              child: AbsorbPointer(
                child: MfmElementWidget(
                  style: style?.merge(
                    Mfm.of(context).linkStyle ??
                        TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  nodes: node.children,
                  depth: depth + 1,
                ),
              ),
            ),
          )
        else if (node is MfmURL)
          TextSpan(style: style?.merge(Mfm.of(context).linkStyle ?? TextStyle(color: Theme.of(context).primaryColor)), text: node.value.decodeUri.tight, recognizer: TapGestureRecognizer()..onTap = () => Mfm.of(context).linkTap?.call(node.value))
        else if (node is MfmFn)
          MfmFnSpan(context: context, style: style, function: node, depth: depth + 1)
        else if (node is MfmMathBlock)
          TextSpan(style: style, text: node.formula)
        else if (node is MfmMathInline)
          TextSpan(style: style, text: node.formula)
        else
          WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: MfmElementWidget(
                nodes: node.children,
                style: style,
                depth: depth + 1,
              )),
      if (depth == 0) ...Mfm.of(context).suffixSpan
    ];
  }

  @override
  List<InlineSpan> get children => _children;
}
