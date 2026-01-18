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

import 'package:flutter/material.dart';
import 'dart:math' as math;

class RateOfDoing extends StatelessWidget {
  final double doneCount;
  final double missedCount;
  final double skippedCount;
  final double totalCount;
  final double size;

  const RateOfDoing({
    super.key,
    required this.doneCount,
    required this.missedCount,
    required this.skippedCount,
    required this.totalCount,
    required this.size,
  });

  // Yapılan oranını hesapla (0-100)
  double get _donePercentage =>
      totalCount > 0 ? (doneCount / totalCount) * 100 : 0;

  // Yapılan oranına göre renk: yeşil → sarı → kırmızı
  Color get _progressColor {
    final double ratio = _donePercentage / 100.0;

    if (ratio <= 0.5) {
      // 0% → 50%: Kırmızıdan sarıya
      return Color.lerp(Colors.red, Colors.orange, ratio * 2)!;
    } else {
      // 50% → 100%: Sarıdan yeşile
      return Color.lerp(Colors.orange, Colors.green, (ratio - 0.5) * 2)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = totalCount > 0 ? doneCount / totalCount : 0;

    return SizedBox(
      width: size,
      height: size ,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan (gri yarım daire)
          CustomPaint(
            size: Size(size, size),
            painter: _RateOfDoingPainter(
              progress: 1.0,
              color: Colors.grey.withValues(alpha: 0.4),
              strokeWidth: size * 0.08,
            ),
          ),

          // Dinamik renkli dolgu (yapılan oran)
          CustomPaint(
            size: Size(size, size),
            painter: _RateOfDoingPainter(
              progress: percentage,
              color: _progressColor,
              strokeWidth: size * 0.08,
            ),
          ),

          // Orta yazı
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Rate Of Doing",
                style: TextStyle(fontSize: size * 0.07, color: _progressColor),
              ),
              Text(
                "${_donePercentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.bold,
                  color: _progressColor,
                ),
              ),
              // Ayrıntılı istatistikler
              Column(
                children: [
                  Text(
                    "✓ Yapılan: ${doneCount.toInt()}",
                    style: TextStyle(fontSize: size * 0.05, color: Colors.green),
                  ),
                  Text(
                    "⊗ Kaçırılan: ${missedCount.toInt()}",
                    style: TextStyle(fontSize: size * 0.05, color: Colors.red),
                  ),
                  Text(
                    "⊘ Atlanan: ${skippedCount.toInt()}",
                    style: TextStyle(fontSize: size * 0.05, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _RateOfDoingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RateOfDoingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // Yarım daire (180°) çiz: math.pi rad = 180°
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      2* math.pi, // 180 derece başla
      2*math.pi * progress, // progress kadar ilerle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
