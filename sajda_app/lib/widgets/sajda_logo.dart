import 'package:flutter/material.dart';
import '../theme/design_system.dart';

class SajdaLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const SajdaLogo({
    super.key,
    this.size = 120,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strokeColor = color ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return CustomPaint(
      size: Size(size, size),
      painter: _MihrabPainter(color: strokeColor),
    );
  }
}

class _MihrabPainter extends CustomPainter {
  final Color color;

  _MihrabPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Arch left pillar
    path.moveTo(size.width * 0.25, size.height * 0.75);
    path.lineTo(size.width * 0.25, size.height * 0.45);
    
    // The Arch curve
    path.arcToPoint(
      Offset(size.width * 0.75, size.height * 0.45),
      radius: Radius.circular(size.width * 0.25),
      clockwise: true,
    );
    
    // Arch right pillar
    path.lineTo(size.width * 0.75, size.height * 0.75);

    canvas.drawPath(path, paint);

    // Baseline
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.75),
      Offset(size.width * 0.9, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
