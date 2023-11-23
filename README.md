This package is [MFM](https://misskey-hub.net/en/docs/features/mfm.html) renderer for Flutter.

<img src="https://github.com/shiosyakeyakini-info/mfm_renderer/raw/master/doc/assets/example.png" width="256">
<video width="256" controls>
  <source src="https://github.com/shiosyakeyakini-info/mfm_renderer/raw/master/doc/assets/animation_example.mp4" type="video/mp4" />
</video>

## Overview

MFM is markup language like markdown which is used [Misskey](https://misskey-hub.net/). This package is not rely to webview.

## Features

This package supports these MFM syntaxes.

- Quote Block (`>`)
- Code Block (Inline, Block)
  - mfm_renderer will not highlight these code block. you can use [any highlight libraries](https://pub.dev/packages?q=highlight) from pub.dev.
- Center Block
- Text Decoration (bold, big, italic, small, change fonts, strike, background color, foreground color)
- Emoji Code, Unicode Emoji Code
  - mfm_render will not build Image widget. you can pass builder arguments to MFM Widget.
- Plain inline Block
- Math Block, Math Inline Block
  - Misskey is not supported these syntax but did not nyaize.
- Mention, Hashtags, URL Link
- Search syntax
- Translate Items(`$[scale` `$[position` `$[flip` )
- Blur Items
- Ruby (`$[ruby]`)
- Show absolute time(`$[unixtime]`)
- MFM Animations
  - `$[rainbow]` `$[shake]` `$[jelly]` `$[twitch]` `$[bounce]` `$[jump]` `$[spin]` and `$[spakle]`
- Nyaize these items (such as `なんなん` to `にゃんにゃん`) if you want.

## Getting started

```
flutter pub add mfm_renderer
```



## Usage

See `example/lib/main.dart`.
