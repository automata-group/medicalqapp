import 'dart:math';
import 'package:flutter/material.dart';

class RadialAccuracyGauge extends StatelessWidget {
  final double accuracy; // 0 to 100
  final double size;
  final Color? baseColor;
  final Color progressColor;

  const RadialAccuracyGauge({
    super.key,
    required this.accuracy,
    this.size = 120,
    this.baseColor,
    this.progressColor = const Color(0xFF6366F1),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBaseColor = baseColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9));

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadialPainter(
              progress: accuracy / 100,
              baseColor: effectiveBaseColor,
              progressColor: progressColor,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${accuracy.toInt()}%',
              style: TextStyle(
                fontSize: size * 0.22,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Accuracy', // Can be localized later if needed or passed as param
              style: TextStyle(
                fontSize: size * 0.08,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color progressColor;

  _RadialPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.12;

    // Draw base track
    final paintBase = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, paintBase);

    // Draw progress arc
    final paintProgress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      2 * pi * progress,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
