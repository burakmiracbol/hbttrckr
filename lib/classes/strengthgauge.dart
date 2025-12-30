import 'package:flutter/material.dart';

class StrengthGauge extends StatelessWidget {
  final double strength; // 0-100 arası
  final double size;

  const StrengthGauge({super.key, required this.strength, this.size = 200});

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
              color: Colors.grey.withOpacity(0.4),
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
                "$strength%",
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
      3.14159, // 180 derece
      3.14159 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
