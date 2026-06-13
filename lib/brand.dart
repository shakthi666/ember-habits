import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Ember flame mark, drawn in code so it always matches the launcher
/// icon exactly. Used in the app bar.
class EmberLogo extends StatelessWidget {
  final double size;
  const EmberLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF7C5CFC),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: CustomPaint(painter: _FlamePainter()),
    );
  }
}

class _FlamePainter extends CustomPainter {
  Path _flame(double cx, double cy, double r, double h) {
    final p = Path();
    p.moveTo(cx - r, cy);
    p.arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi, -math.pi, false);
    p.quadraticBezierTo(cx + r * 0.95, cy - h * 0.55, cx, cy - h);
    p.quadraticBezierTo(cx - r * 0.95, cy - h * 0.55, cx - r, cy);
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      _flame(w / 2, h * 0.66, w * 0.24, h * 0.50),
      Paint()..color = Colors.white,
    );
    canvas.drawPath(
      _flame(w / 2, h * 0.70, w * 0.125, h * 0.24),
      Paint()..color = const Color(0xFFFFB37E),
    );
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) => false;
}
