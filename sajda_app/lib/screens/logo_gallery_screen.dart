import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

class LogoGalleryScreen extends StatelessWidget {
  const LogoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryLight,
      appBar: AppBar(
        title: Text(
          'Brand Concepts',
          style: AppTextStyles.heading2(AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingScreenHorizontal),
        children: const [
          LogoCard(
            title: '1. The Abstract Sujud',
            description: 'Geometric posture representing the physical act of prostration. Grounding and pausing forward momentum.',
            logoPainter: SujudPainter(),
          ),
          SizedBox(height: 32),
          LogoCard(
            title: '2. The Empty Mihrab',
            description: 'A continuous monoline arch utilizing negative space. Represents carving out a quiet void in a noisy environment.',
            logoPainter: MihrabPainter(),
          ),
          SizedBox(height: 32),
          LogoCard(
            title: '3. The Eclipse',
            description: 'A solid mass eclipsing the digital world, sliced by the horizon. Signifies a hard stop and immovable time.',
            logoPainter: EclipsePainter(),
          ),
          SizedBox(height: 32),
          LogoCard(
            title: '4. The Threshold',
            description: 'Two pillars representing restriction walls, with the user centered between them. Uncompromising and firm.',
            logoPainter: ThresholdPainter(),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
  }
}

class LogoCard extends StatelessWidget {
  final String title;
  final String description;
  final CustomPainter logoPainter;

  const LogoCard({
    super.key,
    required this.title,
    required this.description,
    required this.logoPainter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2(textColor),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyles.bodyMedium(secondaryColor),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgPrimaryDark : AppColors.bgPrimaryLight,
              borderRadius: BorderRadius.circular(AppRadius.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: textColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(160, 160),
              painter: logoPainter,
            ),
          ),
        ),
      ],
    );
  }
}

class SujudPainter extends CustomPainter {
  const SujudPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B2D2F)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = const Color(0xFF2B2D2F)..style = PaintingStyle.fill;
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.75), Offset(size.width * 0.85, size.height * 0.75), paint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.4), size.width * 0.12, fillPaint);
    canvas.drawLine(Offset(size.width * 0.43, size.height * 0.48), Offset(size.width * 0.7, size.height * 0.75), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MihrabPainter extends CustomPainter {
  const MihrabPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B2D2F)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.75);
    path.lineTo(size.width * 0.25, size.height * 0.45);
    path.arcToPoint(Offset(size.width * 0.75, size.height * 0.45), radius: Radius.circular(size.width * 0.25), clockwise: true);
    path.lineTo(size.width * 0.75, size.height * 0.75);
    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.75), Offset(size.width * 0.9, size.height * 0.75), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EclipsePainter extends CustomPainter {
  const EclipsePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = const Color(0xFF232B2F)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = const Color(0xFF232B2F)..strokeWidth = 4.0..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height * 0.65));
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.45), size.width * 0.35, fillPaint);
    canvas.restore();
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.65), Offset(size.width * 0.9, size.height * 0.65), strokePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ThresholdPainter extends CustomPainter {
  const ThresholdPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = const Color(0xFF2B2D2F)..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = const Color(0xFF2B2D2F)..strokeWidth = 4.0..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTRB(size.width * 0.25, size.height * 0.25, size.width * 0.38, size.height * 0.75), fillPaint);
    canvas.drawRect(Rect.fromLTRB(size.width * 0.62, size.height * 0.25, size.width * 0.75, size.height * 0.75), fillPaint);
    canvas.drawRect(Rect.fromLTRB(size.width * 0.45, size.height * 0.65, size.width * 0.55, size.height * 0.75), fillPaint);
    canvas.drawLine(Offset(size.width * 0.15, size.height * 0.75), Offset(size.width * 0.85, size.height * 0.75), strokePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
