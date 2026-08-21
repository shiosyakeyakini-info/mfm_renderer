import 'dart:math';

/// CSS の `filter` 関数と等価な 4x5 カラーマトリクスを組み立てるためのユーティリティ。
///
/// Misskey (本家) の MFM は CSS の `filter` プロパティでエフェクトを表現しているため、
/// 見た目を揃えるには Filter Effects Module Level 1 で定義されている行列と
/// 同じものを使う必要がある。
/// https://drafts.fxtf.org/filter-effects/#FilterPrimitivesOverviewIntro
///
/// 行列は Flutter の [ColorFilter.matrix] と同じ row-major な 4x5 (20要素) 形式で、
/// 5列目 (平行移動成分) だけが 0...255 のスケールになっている。
class CssColorMatrix {
  const CssColorMatrix._();

  /// 単位行列。
  static const List<double> identity = [
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  /// CSS の `hue-rotate(<radians>)` 相当の行列。
  ///
  /// https://drafts.fxtf.org/filter-effects/#feColorMatrixElement
  static List<double> hueRotate(double radians) {
    final c = cos(radians);
    final s = sin(radians);

    return [
      0.213 + c * 0.787 - s * 0.213,
      0.715 - c * 0.715 - s * 0.715,
      0.072 - c * 0.072 + s * 0.928,
      0,
      0,
      0.213 - c * 0.213 + s * 0.143,
      0.715 + c * 0.285 + s * 0.140,
      0.072 - c * 0.072 - s * 0.283,
      0,
      0,
      0.213 - c * 0.213 - s * 0.787,
      0.715 - c * 0.715 + s * 0.715,
      0.072 + c * 0.928 + s * 0.072,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// CSS の `saturate(<amount>)` 相当の行列。
  ///
  /// [amount] は倍率で、`saturate(150%)` なら 1.5 を渡す。
  static List<double> saturate(double amount) {
    return [
      0.213 + 0.787 * amount,
      0.715 - 0.715 * amount,
      0.072 - 0.072 * amount,
      0,
      0,
      0.213 - 0.213 * amount,
      0.715 + 0.285 * amount,
      0.072 - 0.072 * amount,
      0,
      0,
      0.213 - 0.213 * amount,
      0.715 - 0.715 * amount,
      0.072 + 0.928 * amount,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// CSS の `contrast(<amount>)` 相当の行列。
  ///
  /// [amount] は倍率で、`contrast(150%)` なら 1.5 を渡す。
  /// CSS では 0.5 を中心に傾き [amount] の一次関数を掛けるため、
  /// 平行移動成分は 0...255 スケールで `127.5 * (1 - amount)` になる。
  static List<double> contrast(double amount) {
    final intercept = 127.5 * (1 - amount);

    return [
      amount, 0, 0, 0, intercept, //
      0, amount, 0, 0, intercept, //
      0, 0, amount, 0, intercept, //
      0, 0, 0, 1, 0, //
    ];
  }

  /// [a] のあとに [b] を適用した結果と等価な行列を返す。
  ///
  /// CSS の `filter` は左に書かれたものから順に適用されるため、
  /// `filter: f1 f2` は `multiply(f1, f2)` で表現できる。
  static List<double> multiply(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0);

    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 4; column++) {
        var value = 0.0;
        for (var k = 0; k < 4; k++) {
          value += b[row * 5 + k] * a[k * 5 + column];
        }
        result[row * 5 + column] = value;
      }

      // 平行移動成分。b の平行移動成分に、a の平行移動成分を b で変換したものを足す。
      var offset = b[row * 5 + 4];
      for (var k = 0; k < 4; k++) {
        offset += b[row * 5 + k] * a[k * 5 + 4];
      }
      result[row * 5 + 4] = offset;
    }

    return result;
  }

  /// [filters] を先頭から順に適用した結果と等価な行列を返す。
  static List<double> compose(List<List<double>> filters) {
    var result = identity;
    for (final filter in filters) {
      result = multiply(result, filter);
    }
    return result;
  }
}
