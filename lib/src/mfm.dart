library mfm_renderer;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfm_parser/mfm_parser.dart';
import 'package:mfm/src/mfm_parent_widget.dart';

/// Build Emojis which is presented shortcode.
typedef EmojiBuilder = Widget Function(
    BuildContext context, String emojiName, TextStyle? style);

/// Build Unicode Emojis.
typedef UnicodeEmojiBuilder = InlineSpan Function(
    BuildContext context, String emoji, TextStyle? style);

/// Build small style.
typedef SmallStyleBuilder = TextStyle Function(
    BuildContext context, double? fontSize);

/// Build code block.
typedef CodeBlockBuilder = Widget Function(
    BuildContext context, String code, String? language);

/// Build inline code block.
typedef InlineCodeBuilder = Widget Function(
    BuildContext context, String code, TextStyle? style);

/// Build quote code block.
typedef QuoteBuilder = Widget Function(BuildContext context, Widget child);

/// Build search block.
typedef SearchBuilder = Widget Function(BuildContext context, String query,
    FutureOr<void> Function(String)? onPressed);

/// Build unixtime block.
typedef UnixTimeBuilder = InlineSpan Function(
    BuildContext context, DateTime? unixtime, TextStyle? style);

/// Callback when tap mention.
typedef MentionTapCallBack = FutureOr<void> Function(
    String userName, String? host, String acct);

/// Callback when tap hashtag.
typedef HashtagCallback = FutureOr<void> Function(String hashtag);

/// Callback when tap link.
typedef LinkTapCallback = FutureOr<void> Function(String url);

/// Callback when tap default search buttons.
typedef SearchTapCallback = FutureOr<void> Function(String);

class Mfm extends InheritedWidget {
  /// mfm text. must be non-null mfmText or mfmNode.
  final String? mfmText;

  /// parsed mfm text.
  final List<MfmNode>? mfmNode;

  /// code block builder
  final CodeBlockBuilder? codeBlockBuilder;

  /// inline code builder.
  final InlineCodeBuilder? inlineCodeBuilder;

  /// `<small>...</small>` style builder.
  /// arguments [style.fontSize] will be provide currently font size.
  /// font size will be changed relativity, such as `$[x2 <small>...</small>]` syntax.
  final SmallStyleBuilder? smallStyleBuilder;

  /// builder for emoji.
  final EmojiBuilder? emojiBuilder;

  /// builder for unicode emoji.
  final UnicodeEmojiBuilder? unicodeEmojiBuilder;

  /// quote block builder
  final QuoteBuilder? quoteBuilder;

  /// search block builder
  final SearchBuilder? searchBuilder;

  /// $[unixtime builder
  final UnixTimeBuilder? unixTimeBuilder;

  /// line height.
  final double lineHeight;

  /// base text style.
  final TextStyle? style;

  /// bold (such as `<b>` `**`) element style
  final TextStyle boldStyle;

  /// link element style
  final TextStyle? linkStyle;

  /// hashtag element style
  final TextStyle? hashtagStyle;

  /// mention element style
  final TextStyle? mentionStyle;

  /// `$[font.serif ]` element style
  final TextStyle? serifStyle;

  /// `$[font.monospace ]` element style
  final TextStyle? monospaceStyle;

  /// `$[font.cursive ]` element style
  final TextStyle? cursiveStyle;

  /// `$[font.fantasy ]` elemen style
  final TextStyle? fantasyStyle;

  /// callback when tap mention.
  final MentionTapCallBack? mentionTap;

  /// callback when tap hashtag.
  final HashtagCallback? hashtagTap;

  /// callback when tap link, url.
  final LinkTapCallback? linkTap;

  /// callback when tap [Seach]
  final SearchTapCallback? searchTap;

  /// apply text nyaize
  final bool isNyaize;

  /// add prefix span
  final List<InlineSpan> prefixSpan;

  /// add suffix span
  final List<InlineSpan> suffixSpan;

  // use animation statement.
  final bool isUseAnimation;

  // default `$[border]` color
  final Color defaultBorderColor;

  /// See [Text.overflow]
  final TextOverflow? overflow;

  /// See [Text.maxLines]
  final int? maxLines;

  /// Markup Language for Misskey Sample.
  const Mfm({
    super.key,
    this.mfmText,
    this.mfmNode,
    this.emojiBuilder,
    this.unicodeEmojiBuilder,
    this.codeBlockBuilder,
    this.inlineCodeBuilder,
    this.smallStyleBuilder,
    this.quoteBuilder,
    this.searchBuilder,
    this.unixTimeBuilder,
    this.lineHeight = 1.35,
    this.style,
    this.boldStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.linkStyle,
    this.mentionStyle,
    this.hashtagStyle,
    this.serifStyle,
    this.monospaceStyle,
    this.cursiveStyle,
    this.fantasyStyle,
    this.mentionTap,
    this.hashtagTap,
    this.linkTap,
    this.searchTap,
    this.isNyaize = false,
    this.prefixSpan = const [],
    this.suffixSpan = const [],
    this.isUseAnimation = true,
    this.defaultBorderColor = Colors.purpleAccent,
    this.overflow,
    this.maxLines,
  })  : assert(
          (mfmText != null && mfmNode == null) ||
              (mfmText == null || mfmNode != null),
        ),
        super(child: const MfmParentWidget());

  @override
  bool updateShouldNotify(covariant Mfm oldWidget) {
    return oldWidget.mfmText != mfmText ||
        oldWidget.mfmNode != mfmNode ||
        oldWidget.emojiBuilder != emojiBuilder ||
        oldWidget.unicodeEmojiBuilder != unicodeEmojiBuilder ||
        oldWidget.codeBlockBuilder != codeBlockBuilder ||
        oldWidget.inlineCodeBuilder != inlineCodeBuilder ||
        oldWidget.smallStyleBuilder != smallStyleBuilder ||
        oldWidget.quoteBuilder != quoteBuilder ||
        oldWidget.unixTimeBuilder != unixTimeBuilder ||
        oldWidget.lineHeight != lineHeight ||
        oldWidget.style != style ||
        oldWidget.boldStyle != boldStyle ||
        oldWidget.linkStyle != linkStyle ||
        oldWidget.serifStyle != serifStyle ||
        oldWidget.monospaceStyle != monospaceStyle ||
        oldWidget.cursiveStyle != cursiveStyle ||
        oldWidget.fantasyStyle != fantasyStyle ||
        oldWidget.mentionTap != mentionTap ||
        oldWidget.hashtagTap != hashtagTap ||
        oldWidget.linkTap != linkTap ||
        oldWidget.defaultBorderColor != defaultBorderColor ||
        oldWidget.isUseAnimation != isUseAnimation;
  }

  /// provides root MFM Widget
  static Mfm of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Mfm>()!;
}
