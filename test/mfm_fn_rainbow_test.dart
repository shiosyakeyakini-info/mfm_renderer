import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfm/src/functions/mfm_fn_color_matrix.dart';
import 'package:mfm/src/functions/mfm_fn_rainbow.dart';

/// rainbowのwidgetツリーから、実際に適用されているカラーマトリクスを取り出す。
List<double> findRainbowMatrix(WidgetTester tester) {
  final colorFiltered = tester.widget<ColorFiltered>(
    find.descendant(
      of: find.byType(MfmRainbow),
      matching: find.byType(ColorFiltered),
    ),
  );

  // ColorFilter.matrixはtoString()でしか行列を取り出せない。
  final text = colorFiltered.colorFilter.toString();
  final values = RegExp(r'-?[0-9]+\.?[0-9]*(e-?[0-9]+)?')
      .allMatches(text)
      .map((e) => double.parse(e.group(0)!))
      .toList();
  return values.sublist(values.length - 20);
}

/// [matrix] を [color] に適用した結果を、0...255にクランプして返す。
List<double> applyMatrix(List<double> matrix, List<double> color) {
  return [
    for (var row = 0; row < 3; row++)
      (matrix[row * 5] * color[0] +
              matrix[row * 5 + 1] * color[1] +
              matrix[row * 5 + 2] * color[2] +
              matrix[row * 5 + 4])
          .clamp(0, 255)
  ];
}

void main() {
  group("CssColorMatrix", () {
    test("hue-rotate(0deg)は単位行列", () {
      final matrix = CssColorMatrix.hueRotate(0);
      for (var i = 0; i < 20; i++) {
        expect(matrix[i], closeTo(CssColorMatrix.identity[i], 0.0001));
      }
    });

    test("hue-rotate(360deg)は単位行列", () {
      final matrix = CssColorMatrix.hueRotate(2 * pi);
      for (var i = 0; i < 20; i++) {
        expect(matrix[i], closeTo(CssColorMatrix.identity[i], 0.0001));
      }
    });

    test("saturate(1)は単位行列", () {
      final matrix = CssColorMatrix.saturate(1);
      for (var i = 0; i < 20; i++) {
        expect(matrix[i], closeTo(CssColorMatrix.identity[i], 0.0001));
      }
    });

    test("saturate(0)はグレースケール", () {
      final matrix = CssColorMatrix.saturate(0);
      expect(applyMatrix(matrix, [255, 0, 0]),
          everyElement(closeTo(0.213 * 255, 0.01)));
    });

    test("contrast(1)は単位行列", () {
      final matrix = CssColorMatrix.contrast(1);
      for (var i = 0; i < 20; i++) {
        expect(matrix[i], closeTo(CssColorMatrix.identity[i], 0.0001));
      }
    });

    test("contrast(1.5)は0.5を中心に1.5倍する", () {
      final matrix = CssColorMatrix.contrast(1.5);
      // 127.5 (=0.5) は動かない。
      expect(applyMatrix(matrix, [127.5, 127.5, 127.5]),
          everyElement(closeTo(127.5, 0.01)));
      // 170 (=2/3) は 1.5 * (2/3 - 0.5) + 0.5 = 0.75 になる。
      expect(applyMatrix(matrix, [170, 170, 170]),
          everyElement(closeTo(0.75 * 255, 0.01)));
    });

    test("composeは先頭に書いたフィルタから順に適用される", () {
      // contrast -> saturate の順。saturateはグレーを変えないので、
      // グレーに対する結果はcontrastのみのときと一致する。
      final composed = CssColorMatrix.compose([
        CssColorMatrix.contrast(1.5),
        CssColorMatrix.saturate(0),
      ]);
      expect(applyMatrix(composed, [170, 170, 170]),
          everyElement(closeTo(0.75 * 255, 0.01)));

      // 逆順にすると、先にグレースケール化されてから
      // contrastが掛かるので、赤は 0.213 を中心に伸びる。
      final reversed = CssColorMatrix.compose([
        CssColorMatrix.saturate(0),
        CssColorMatrix.contrast(1.5),
      ]);
      expect(applyMatrix(reversed, [255, 0, 0]),
          everyElement(closeTo((1.5 * (0.213 - 0.5) + 0.5) * 255, 0.01)));
    });
  });

  group("MfmRainbow", () {
    test("progress=0では色相が回転していない", () {
      final matrix = MfmRainbowState.colorMatrix(0);
      // 本家は 0% の時点で hue-rotate(0deg) なので、赤は赤のまま。
      // (contrast(150%) saturate(150%) によって彩度は上がる)
      final red = applyMatrix(matrix, [255, 0, 0]);
      expect(red[0], greaterThan(red[1]));
      expect(red[0], greaterThan(red[2]));
      expect(red[1], closeTo(0, 0.01));
      expect(red[2], closeTo(0, 0.01));
    });

    test("progress=1はprogress=0と一致する(360deg回転)", () {
      final start = MfmRainbowState.colorMatrix(0);
      final end = MfmRainbowState.colorMatrix(1);
      for (var i = 0; i < 20; i++) {
        expect(end[i], closeTo(start[i], 0.0001));
      }
    });

    test("progress=0.5では色相が180deg回転している", () {
      final matrix = MfmRainbowState.colorMatrix(0.5);
      // 赤は補色寄り(シアン方向)に回る。
      final red = applyMatrix(matrix, [255, 0, 0]);
      expect(red[0], closeTo(0, 0.01));
      expect(red[1], greaterThan(0));
      expect(red[2], greaterThan(0));
    });

    test("グレーは色相回転の影響を受けず、contrast(150%)のみが掛かる", () {
      for (final progress in [0.0, 0.25, 0.5, 0.75]) {
        final matrix = MfmRainbowState.colorMatrix(progress);
        // 170 -> 1.5 * (170 - 127.5) + 127.5 = 191.25
        expect(applyMatrix(matrix, [170, 170, 170]),
            everyElement(closeTo(191.25, 0.01)),
            reason: "progress=$progress");
      }
    });

    test("白と黒は変化しない", () {
      for (final progress in [0.0, 0.25, 0.5, 0.75]) {
        final matrix = MfmRainbowState.colorMatrix(progress);
        expect(applyMatrix(matrix, [255, 255, 255]),
            everyElement(closeTo(255, 0.01)),
            reason: "progress=$progress");
        expect(applyMatrix(matrix, [0, 0, 0]), everyElement(closeTo(0, 0.01)),
            reason: "progress=$progress");
      }
    });

    testWidgets("アニメーションの進行に合わせてカラーマトリクスが更新される", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MfmRainbow(
                speed: 1,
                delay: 0,
                child: Text("これはテストです"),
              ),
            ),
          ),
        ),
      );
      // delayのFutureが解決してAnimationControllerが回り始めるまでpumpする。
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      // 開始時点は hue-rotate(0deg) 相当。
      final start = findRainbowMatrix(tester);
      expect(start[0], closeTo(MfmRainbowState.colorMatrix(0)[0], 0.01));

      // speed=1sの半分まで進めると hue-rotate(180deg) 相当になる。
      await tester.pump(const Duration(milliseconds: 500));
      final half = findRainbowMatrix(tester);
      expect(half[0], isNot(closeTo(start[0], 0.01)));
      expect(half[0], closeTo(MfmRainbowState.colorMatrix(0.5)[0], 0.02));

      // 1周すると元に戻る。
      await tester.pump(const Duration(milliseconds: 500));
      expect(findRainbowMatrix(tester)[0], closeTo(start[0], 0.02));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets("speedが0以下のときはカラーフィルタを適用しない", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MfmRainbow(
                speed: 0,
                delay: 0,
                child: Text("これはテストです"),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(
          find.descendant(
            of: find.byType(MfmRainbow),
            matching: find.byType(ColorFiltered),
          ),
          findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
