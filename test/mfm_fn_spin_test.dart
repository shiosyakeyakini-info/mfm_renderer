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

  testWidgets('spin.x / spin.y の行列は z を平面に落とす', (tester) async {
    // CSSの transform-style は既定が flat なので、入れ子の内側は
    // いったん平面に潰されてから外側の transform を受ける。
    // 行列を素直に掛け合わせるFlutterでそれに合わせるには、
    // z成分を平面に落としておく必要がある。
    for (final type in [MfmFnSpinType.x, MfmFnSpinType.y]) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: MfmFnSpin(
              direction: MfmFnSpinDirection.normal,
              type: type,
              speed: 2,
              delay: 0,
              child: const Text("★"),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      // 1周2秒のうち1/8、つまり45度あたりまで進める。
      await tester.pump(const Duration(milliseconds: 250));

      final matrix = findSpinMatrix(tester);
      // spin.x なら縦、spin.y なら横が縮んでいるはず。
      // 潰れていない = 回っていないので、以下の検査に意味がなくなる。
      final scale =
          type == MfmFnSpinType.x ? matrix.entry(1, 1) : matrix.entry(0, 0);
      expect(scale.abs(), lessThan(0.9), reason: "$type がそもそも回っていない");
      expect(matrix.entry(2, 0), 0.0, reason: "$type");
      expect(matrix.entry(2, 1), 0.0, reason: "$type");
      expect(matrix.entry(2, 2), 1.0, reason: "$type");
      expect(matrix.entry(2, 3), 0.0, reason: "$type");
    }
  });

  testWidgets('入れ子のspinは、内と外の縮みが掛け算になる', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: MfmFnSpin(
            direction: MfmFnSpinDirection.normal,
            type: MfmFnSpinType.y,
            speed: 2,
            delay: 0,
            child: MfmFnSpin(
              direction: MfmFnSpinDirection.reverse,
              type: MfmFnSpinType.y,
              speed: 2,
              delay: 0,
              child: Text("★"),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // 外側がAnimationControllerを用意してsetStateすると内側が作り直され、
    // 内側のAnimationControllerはさらに1フレームあとに立ち上がる。
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    // 1周2秒のうち1/8、つまり45度あたりまで進める。
    await tester.pump(const Duration(milliseconds: 250));

    final matrices = tester
        .widgetList<Transform>(find.byType(Transform))
        .map((e) => e.transform)
        .toList();
    expect(matrices.length, 2);

    final composed = matrices[0].multiplied(matrices[1]);
    // 本家(transform-style: flat)では内側の投影結果に外側がかかるので、
    // 横方向の縮みは内と外の積になる。行列を素直に掛けるだけだと
    // 逆回しの入れ子が3D空間で打ち消し合い、m00が1に戻ってしまう。
    expect(composed.entry(0, 0),
        closeTo(matrices[0].entry(0, 0) * matrices[1].entry(0, 0), 1e-9));
    expect(composed.entry(0, 0).abs(), lessThan(0.9),
        reason: "45度あたりでは cos^2 まで潰れているはず");
    // 潰した結果もまた平面に載っていること。
    expect(composed.entry(2, 2), 1.0);
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
