library mfm_renderer;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfm_renderer/src/mfm_parent_widget.dart';

typedef EmojiBuilder = Widget Function(
    BuildContext context, String emojiName, TextStyle? style);
typedef UnicodeEmojiBuilder = InlineSpan Function(
    BuildContext context, String emoji, TextStyle? style);
typedef SmallStyleBuilder = TextStyle Function(
    BuildContext context, double? fontSize);
typedef CodeBlockBuilder = Widget Function(
    BuildContext context, String code, String? language);
typedef InlineCodeBuilder = Widget Function(
    BuildContext context, String code, TextStyle? style);
typedef QuoteBuilder = Widget Function(BuildContext context, Widget child);
typedef SearchBuilder = Widget Function(BuildContext context, String query,
    FutureOr<void> Function(String)? onPressed);
typedef MentionTapCallBack = FutureOr<void> Function(
    String userName, String? host, String acct);
typedef HashtagCallback = FutureOr<void> Function(String hashtag);
typedef LinkTapCallback = FutureOr<void> Function(String url);
typedef SearchTapCallback = FutureOr<void> Function(String);

class Mfm extends InheritedWidget {
  /// mfm text.
  final String mfmText;

  /// code block builder
  final CodeBlockBuilder? codeBlockBuilder;

  /// inline code builder.
  final InlineCodeBuilder? inlineCodeBuilder;

  /// `<small>...</small>` style builder.
  /// arguments [fontSize] will be provide currently font size.
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

  /// callback when tap mention.
  final MentionTapCallBack? mentionTap;

  /// callback when tap hashtag.
  final HashtagCallback? hashtagTap;

  /// callback when tap link, url.
  final LinkTapCallback? linkTap;

  final SearchTapCallback? searchTap;

  /// apply text nyaize
  final bool isNyaize;

  /// add prefix span
  final List<InlineSpan> prefixSpan;

  /// add suffix span
  final List<InlineSpan> suffixSpan;

  /// Markup Language for Misskey Sample.
  const Mfm(
    this.mfmText, {
    super.key,
    this.emojiBuilder,
    this.unicodeEmojiBuilder,
    this.codeBlockBuilder,
    this.inlineCodeBuilder,
    this.smallStyleBuilder,
    this.quoteBuilder,
    this.searchBuilder,
    this.lineHeight = 1.35,
    this.style,
    this.boldStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.linkStyle,
    this.mentionStyle,
    this.hashtagStyle,
    this.serifStyle,
    this.monospaceStyle,
    this.mentionTap,
    this.hashtagTap,
    this.linkTap,
    this.searchTap,
    this.isNyaize = false,
    this.prefixSpan = const [],
    this.suffixSpan = const [],
  }) : super(child: const MfmParentWidget());

  @override
  bool updateShouldNotify(covariant Mfm oldWidget) {
    return oldWidget.mfmText != mfmText ||
        oldWidget.emojiBuilder != emojiBuilder ||
        oldWidget.unicodeEmojiBuilder != unicodeEmojiBuilder ||
        oldWidget.codeBlockBuilder != codeBlockBuilder ||
        oldWidget.inlineCodeBuilder != inlineCodeBuilder ||
        oldWidget.smallStyleBuilder != smallStyleBuilder ||
        oldWidget.quoteBuilder != quoteBuilder ||
        oldWidget.lineHeight != lineHeight ||
        oldWidget.style != style ||
        oldWidget.boldStyle != boldStyle ||
        oldWidget.linkStyle != linkStyle ||
        oldWidget.serifStyle != serifStyle ||
        oldWidget.monospaceStyle != monospaceStyle ||
        oldWidget.mentionTap != mentionTap ||
        oldWidget.hashtagTap != hashtagTap ||
        oldWidget.linkTap != linkTap;
  }

  static Mfm of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Mfm>()!;
}
