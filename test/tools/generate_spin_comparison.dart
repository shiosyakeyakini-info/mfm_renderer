// 入れ子の $[spin] が、ブラウザ(Misskey本家のCSS)とmfm_rendererで
// どう違って見えるかを比べるためのコマ画像を吐くスクリプト。
// ファイル名が *_test.dart ではないので `flutter test` では実行されない。
//
//   flutter test test/tools/generate_spin_comparison.dart
//
// 出したPNGは1コマずつ。並べて1枚にするのは tools 側の仕事。

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfm/mfm.dart';

/// 出力先。環境変数で差し替えられる。
final _outDir = Platform.environment['SPIN_FRAME_DIR'] ?? 'build/spin_frames';

/// 1周2秒、1/8周ずつ8コマ。
const _period = Duration(seconds: 2);
const _frames = 8;
const _step = Duration(milliseconds: 5);

const _variants = <String>[
  r"$[spin.y,speed=2s ★]",
  r"$[spin.y,left,speed=2s ★]",
  r"$[spin.y,speed=2s $[spin.y,left,speed=2s ★]]",
  r"$[spin.y,speed=2s $[spin.y,speed=2s ★]]",
];

Future<String?> _loadFont() async {
  for (final path in const [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
  ]) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final loader = FontLoader("DocFont")
      ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
    await loader.load();
    return "DocFont";
  }
  return null;
}

void main() {
  testWidgets("dump spin frames", (tester) async {
    final fontFamily = await _loadFont();
    Directory(_outDir).createSync(recursive: true);

    tester.view.physicalSize = const Size(1440, 240);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                for (final text in _variants)
                  SizedBox(
                    width: 180,
                    height: 120,
                    child: Center(
                      child: Mfm(
                        mfmText: text,
                        style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 34,
                            color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    for (var k = 0; k < _frames; k++) {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File("$_outDir/frame_$k.png")
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      final until = _period ~/ _frames;
      for (var e = Duration.zero; e < until; e += _step) {
        await tester.pump(_step);
      }
    }

    // 残ったタイマーを消化する。
    for (var i = 0; i < 400; i++) {
      await tester.pump(_step);
    }
  });
}
