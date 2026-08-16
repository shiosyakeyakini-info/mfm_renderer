import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfm/src/functions/mfm_fn_spin.dart';

/// spinのwidgetツリーから、実際に適用されているTransformの行列を取り出す。
Matrix4 findSpinMatrix(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byType(MfmFnSpin),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform;
}

Future<void> pumpSpin(WidgetTester tester, MfmFnSpinType type) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: MfmFnSpin(
            direction: MfmFnSpinDirection.normal,
            type: type,
            speed: 1.5,
            delay: 0,
            child: const Text("これはテストです"),
          ),
        ),
      ),
    ),
  );
  // startAnimationがFutureの中でAnimationControllerを構築するので、
  // 反映されるまでpumpする。
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  // CSSの perspective(128px) は行列の m34 に -1/128 を設定する。
  const expectedPerspective = -1 / 128.0;

  testWidgets('spin.x は透視投影が適用される', (tester) async {
    await pumpSpin(tester, MfmFnSpinType.x);

    final matrix = findSpinMatrix(tester);
    expect(matrix.entry(3, 2), isNot(0.0),
        reason: "透視投影の項が0のままだと、単なる正射影(縦に潰れるだけ)になる");

    // perspective(128px) * rotateX(deg) と一致すること。
    final degree = matrix.entry(2, 1) == 0 ? 0.0 : asin(matrix.entry(2, 1));
    final expected = Matrix4.identity()
      ..setEntry(3, 2, expectedPerspective)
      ..multiply(Matrix4.rotationX(degree));
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        expect(matrix.entry(row, col), closeTo(expected.entry(row, col), 1e-9),
            reason: "entry($row, $col) が perspective(128px) rotateX と一致しない");
      }
    }
  });

  testWidgets('spin.y は透視投影が適用される', (tester) async {
    await pumpSpin(tester, MfmFnSpinType.y);

    final matrix = findSpinMatrix(tester);
    expect(matrix.entry(3, 2), isNot(0.0));

    final degree = matrix.entry(0, 2) == 0 ? 0.0 : asin(matrix.entry(0, 2));
    final expected = Matrix4.identity()
      ..setEntry(3, 2, expectedPerspective)
      ..multiply(Matrix4.rotationY(degree));
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        expect(matrix.entry(row, col), closeTo(expected.entry(row, col), 1e-9),
            reason: "entry($row, $col) が perspective(128px) rotateY と一致しない");
      }
    }
  });

  testWidgets('spin(Z軸)は透視投影を適用しない', (tester) async {
    await pumpSpin(tester, MfmFnSpinType.both);

    final matrix = findSpinMatrix(tester);
    // 本家の @keyframes mfm-spin は perspective を含まないため、
    // Z軸回転には透視投影をかけない。
    expect(matrix.entry(3, 2), 0.0);
    expect(matrix.entry(3, 3), 1.0);
  });
}
