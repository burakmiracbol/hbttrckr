// hbttrckr: just a habit tracker
// Copyright (C) 2026  Burak Miraç Bol
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 2D düzlemde bir nokta (HSL çemberinde kartezyen koordinatlar)
class Point2D {
  double x, y;
  Point2D({required this.x, required this.y});

  Point2D operator +(Point2D other) =>
      Point2D(x: x + other.x, y: y + other.y);
  Point2D operator -(Point2D other) =>
      Point2D(x: x - other.x, y: y - other.y);
  Point2D operator /(double scalar) =>
      Point2D(x: x / scalar, y: y / scalar);
  double distance(Point2D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  double magnitude() => math.sqrt(x * x + y * y);
  Point2D normalized() {
    final mag = magnitude();
    return mag > 1e-6 ? this / mag : Point2D(x: 1, y: 0);
  }
}

/// HSL renk uzayında rengi temsil eden sınıf
class HslPoint {
  double h; // Hue (0-360 derece)
  double s; // Saturation (0-1)
  double l; // Lightness (0-1)

  HslPoint({required this.h, required this.s, required this.l});

  /// Rengi kartezyen koordinatlara dönüştür (çember üzerinde)
  Point2D toCartesian() {
    final rad = h * math.pi / 180.0;
    return Point2D(x: math.cos(rad), y: math.sin(rad));
  }

  /// Kartezyen koordinatlardan HSL'ye geri dönüştür
  static HslPoint fromCartesian(Point2D p, double s, double l) {
    final h = math.atan2(p.y, p.x) * 180.0 / math.pi;
    final hNormalized = h < 0 ? h + 360 : h;
    return HslPoint(h: hNormalized, s: s, l: l);
  }

  /// Flutter Color'a dönüştür (HSL → RGB)
  Color toFlutterColor() {
    final hslColor = HSLColor.fromAHSL(1.0, h, s, l);
    return hslColor.toColor();
  }
}

/// ColorMixer: Renk çemberi üzerinde geometrik işlemlerle renkleri karıştıran algoritma.
///
/// Algoritma: Eklenen renkler çember üzerinde nokta olarak temsil edilir.
/// Noktaların eklenme sırası ile oluşan geometrik şekiller (üçgen, dörtgen, beşgen...)
/// aracılığıyla merkez bulunur ve bu merkez çember üzerinde yansıtılarak son renk seçilir.
class ColorMixer {
  final List<HslPoint> _colors = [];
  Point2D? _previousCentroid;

  /// Yeni renk ekle ve karışık rengi hesapla
  Color addColor(Color color) {
    // Flutter Color'ı HSL'ye dönüştür
    final hslColor = HSLColor.fromColor(color);
    final hslPoint = HslPoint(
      h: hslColor.hue,
      s: hslColor.saturation,
      l: hslColor.lightness,
    );

    _colors.add(hslPoint);

    // Karışık rengi hesapla
    final mixed = _computeMixedColor();
    return mixed;
  }

  /// Tüm renkler için karışık rengi hesapla
  Color _computeMixedColor() {
    if (_colors.isEmpty) return Colors.grey;
    if (_colors.length == 1) return _colors[0].toFlutterColor();
    if (_colors.length == 2) return _mix2();
    if (_colors.length == 3) return _mix3();
    if (_colors.length == 4) return _mix4();
    return _mix5plus();
  }

  /// 2 renk karışımı: Tam ortası
  Color _mix2() {
    final p1 = _colors[0].toCartesian();
    final p2 = _colors[1].toCartesian();
    final midpoint = Point2D(
      x: (p1.x + p2.x) / 2.0,
      y: (p1.y + p2.y) / 2.0,
    );

    // Saturation ve Lightness: basit ortalama
    final s = (_colors[0].s + _colors[1].s) / 2.0;
    final l = (_colors[0].l + _colors[1].l) / 2.0;

    final result = HslPoint.fromCartesian(midpoint, s, l);
    _previousCentroid = midpoint;
    return result.toFlutterColor();
  }

  /// 3 renk karışımı: Üçgenin centroidi
  Color _mix3() {
    final p1 = _colors[0].toCartesian();
    final p2 = _colors[1].toCartesian();
    final p3 = _colors[2].toCartesian();

    // Üçgenin centroidi: (p1 + p2 + p3) / 3
    final centroid = Point2D(
      x: (p1.x + p2.x + p3.x) / 3.0,
      y: (p1.y + p2.y + p3.y) / 3.0,
    );

    // Saturation ve Lightness: ortalama
    final s = (_colors[0].s + _colors[1].s + _colors[2].s) / 3.0;
    final l = (_colors[0].l + _colors[1].l + _colors[2].l) / 3.0;

    final result = HslPoint.fromCartesian(centroid, s, l);
    _previousCentroid = centroid;
    return result.toFlutterColor();
  }

  /// 4 renk karışımı: Dörtgen ve köşegenler
  Color _mix4() {
    final p1 = _colors[0].toCartesian();
    final p2 = _colors[1].toCartesian();
    final p3 = _colors[2].toCartesian();
    final p4 = _colors[3].toCartesian();

    // İki üçgene böl: (p1, p2, p3) ve (p2, p3, p4)
    final centroid123 = Point2D(
      x: (p1.x + p2.x + p3.x) / 3.0,
      y: (p1.y + p2.y + p3.y) / 3.0,
    );
    final centroid234 = Point2D(
      x: (p2.x + p3.x + p4.x) / 3.0,
      y: (p2.y + p3.y + p4.y) / 3.0,
    );

    // İki centroid arasında çap oluştur, ortası merkez
    final center = Point2D(
      x: (centroid123.x + centroid234.x) / 2.0,
      y: (centroid123.y + centroid234.y) / 2.0,
    );

    // Saturation ve Lightness: ortalama
    final s = (_colors[0].s + _colors[1].s + _colors[2].s + _colors[3].s) / 4.0;
    final l = (_colors[0].l + _colors[1].l + _colors[2].l + _colors[3].l) / 4.0;

    final result = HslPoint.fromCartesian(center, s, l);
    _previousCentroid = center;
    return result.toFlutterColor();
  }

  /// 5+ renk karışımı: Eski merkez korunur, yeni nokta ile genişletilir
  Color _mix5plus() {
    // İlk 4 renkten merkez bulunmuş (previousCentroid'de)
    if (_previousCentroid == null) {
      // Fallback: 4 renge kadar hesapla
      return _mix4();
    }

    final newPoint = _colors.last.toCartesian();
    final oldCenter = _previousCentroid!;

    // Yeni nokta ile eski merkez arasında çap oluştur
    final newCenter = Point2D(
      x: (oldCenter.x + newPoint.x) / 2.0,
      y: (oldCenter.y + newPoint.y) / 2.0,
    );

    // Saturation ve Lightness: tüm renklerin ortalaması
    var satSum = 0.0;
    var lightSum = 0.0;
    for (final c in _colors) {
      satSum += c.s;
      lightSum += c.l;
    }
    final s = satSum / _colors.length;
    final l = lightSum / _colors.length;

    // Yeni merkezi çember üzerinde proje et
    final normalizedCenter = newCenter.normalized();

    final result = HslPoint.fromCartesian(normalizedCenter, s, l);
    _previousCentroid = normalizedCenter;

    return result.toFlutterColor();
  }

  /// Tüm renkler sıfırla
  void reset() {
    _colors.clear();
    _previousCentroid = null;
  }

  /// Kaç renk eklenmiş
  int get colorCount => _colors.length;

  /// Debug: Mevcut renkler
  List<Color> get currentColors =>
      _colors.map((c) => c.toFlutterColor()).toList();
}
