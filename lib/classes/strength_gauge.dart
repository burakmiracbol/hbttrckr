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

class StrengthGauge extends StatelessWidget {
  final String seenStrength;
  final double strength; // 0-100 arası
  final double size;

  const StrengthGauge({super.key, required this.strength,required this.seenStrength, this.size = 200});

  // 0-100 arası değerden kırmızı → sarı → yeşil gradyan renk hesapla
  Color get _progressColor {
    final double ratio = strength / 100.0;

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
    final double percentage = strength / 100.0;

    return SizedBox(
      width: size,
      height: size * 0.7,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Arka plan (gri yarım daire)
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: 1.0,
              color: Colors.grey.withValues(alpha: 0.4),
              strokeWidth: size * 0.08,
            ),
          ),

          // Dinamik renkli dolgu
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: percentage,
              color: _progressColor, // <-- BURADA GRADYAN RENK GELİYOR
              strokeWidth: size * 0.08,
            ),
          ),

          // Orta yazı
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Strength", style: TextStyle(fontSize: size * 0.07)),
              const SizedBox(height: 4),
              Text(
                "$seenStrength",
                style: TextStyle(
                  fontSize: size * 0.18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _GaugePainter({
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

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      math.pi, // 180 derece
      math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
