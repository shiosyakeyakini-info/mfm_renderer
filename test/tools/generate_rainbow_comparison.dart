// 修正前/修正後の $[rainbow] の見た目を比較するPNGを生成するスクリプト。
// ファイル名が *_test.dart ではないので `flutter test` では実行されない。
// doc/assets/rainbow_comparison.png を更新したいときだけ、
// リポジトリのルートで以下を実行する。
//
//   flutter test test/tools/generate_rainbow_comparison.dart

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfm/src/functions/mfm_fn_color_matrix.dart';

/// 修正前の実装(colorfilter_generatorのaddonsをそのまま使っていたもの)を再現する。
List<double> legacyMatrix(double progress) {
  List<double> hue(double value) {
    final radians = value * pi;
    final c = cos(radians);
    final s = sin(radians);
    const lumR = 0.213, lumG = 0.715, lumB = 0.072;
    return [
      (lumR + (c * (1 - lumR))) + (s * (-lumR)),
      (lumG + (c * (-lumG))) + (s * (-lumG)),
      (lumB + (c * (-lumB))) + (s * (1 - lumB)),
      0,
      0,
      (lumR + (c * (-lumR))) + (s * 0.143),
      (lumG + (c * (1 - lumG))) + (s * 0.14),
      (lumB + (c * (-lumB))) + (s * (-0.283)),
      0,
      0,
      (lumR + (c * (-lumR))) + (s * (-(1 - lumR))),
      (lumG + (c * (-lumG))) + (s * lumG),
      (lumB + (c * (1 - lumB))) + (s * lumB),
      0,
      0,
      0, 0, 0, 1, 0, //
    ];
  }

  List<double> contrast(double value) {
    final adj = value * 255;
    final factor = (259 * (adj + 255)) / (255 * (259 - adj));
    final offset = 128 * (1 - factor);
    return [
      factor, 0, 0, 0, offset, //
      0, factor, 0, 0, offset, //
      0, 0, factor, 0, offset, //
      0, 0, 0, 1, 0, //
    ];
  }

  List<double> saturation(double value) {
    final v = value * 100;
    final x = 1 + ((v > 0) ? ((3 * v) / 100) : (v / 100));
    const lumR = 0.3086, lumG = 0.6094, lumB = 0.082;
    return [
      (lumR * (1 - x)) + x, lumG * (1 - x), lumB * (1 - x), 0, 0, //
      lumR * (1 - x), (lumG * (1 - x)) + x, lumB * (1 - x), 0, 0, //
      lumR * (1 - x), lumG * (1 - x), (lumB * (1 - x)) + x, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }

  // ColorFilterGeneratorは filters[0] . filters[1] . filters[2] を計算するので、
  // 実際にはリストの後ろに書いたものから順に適用されていた。
  return CssColorMatrix.compose([
    saturation(1.5),
    contrast(0.5),
    hue(progress * 2 - 1),
  ]);
}

const _samples = <String, Color>{
  "white": Color(0xffffffff),
  "text": Color(0xff2e3440),
  "red": Color(0xffff0000),
  "green": Color(0xff00b300),
  "blue": Color(0xff0066ff),
  "pink": Color(0xffff88bb),
  "gray": Color(0xffaaaaaa),
};

const _steps = [0.0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875];

Widget _row(
    String? fontFamily, String label, List<double> Function(double) matrixOf) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
            width: 190,
            child: Text(label,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    color: Colors.black))),
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: Colors.black38)),
          child: Row(
            children: [
              for (final progress in _steps)
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(matrixOf(progress)),
                  child: Column(
                    children: [
                      for (final sample in _samples.values)
                        Container(width: 46, height: 18, color: sample),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// flutter_testの既定フォントは全ての文字を□で描画してしまうので、
/// 実在するフォントを読み込んでおく。
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
  testWidgets("generate doc/assets/rainbow_comparison.png", (tester) async {
    final fontFamily = await _loadFont();

    tester.view.physicalSize = const Size(1420, 970);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: Container(
            color: const Color(0xfff2f2f4),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r"$[rainbow] color filter, progress 0% -> 87.5%",
                  style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  "each block: ${_samples.keys.join(' / ')} (top to bottom)",
                  style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 11,
                      color: Colors.black54),
                ),
                const SizedBox(height: 8),
                _row(fontFamily, "before (1.0.11)", legacyMatrix),
                _row(fontFamily, "after (= Misskey CSS)", (p) {
                  return CssColorMatrix.compose([
                    CssColorMatrix.hueRotate(p * 2 * pi),
                    CssColorMatrix.contrast(1.5),
                    CssColorMatrix.saturate(1.5),
                  ]);
                }),
                _row(fontFamily, "source (no filter)",
                    (_) => CssColorMatrix.identity),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File("doc/assets/rainbow_comparison.png")
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
