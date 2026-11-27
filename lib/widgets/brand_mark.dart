import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';

/// The Dharm Guru Shrinkhala brand mark, drawn once in
/// assets/brand/dharm-guru-logo.svg and rendered to PNG for the
/// launcher icons and for this widget. Om on a saffron sun disc,
/// twelve rays, a gold rashi ring with twelve ticks. No generic
/// letterform, no emoji, no icon font.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/dharm-guru-logo.png',
      width: size,
      height: size,
      semanticLabel: 'Dharm Guru logo',
    );
  }
}

/// Twelve short gold rays in a ring, drawn by hand. Used on the
/// splash screen behind the logo, turning slowly while the app
/// opens. The rays only, never the Om, so the mark itself stays
/// still and readable.
class RaysRingPainter extends CustomPainter {
  const RaysRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final double outer = size.width / 2;
    final double inner = outer - 18;
    for (int i = 0; i < 12; i++) {
      final double angle = i * math.pi / 6;
      final Offset from = centre +
          Offset(inner * math.cos(angle), inner * math.sin(angle));
      final Offset to = centre +
          Offset(outer * math.cos(angle), outer * math.sin(angle));
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(RaysRingPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// The splash rays ring. Turns a small part of a full circle
/// while the splash timer runs, then stops with the screen.
class SplashRaysRing extends StatelessWidget {
  const SplashRaysRing({
    super.key,
    required this.turns,
    required this.size,
  });

  final Animation<double> turns;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool dark =
        Theme.of(context).brightness == Brightness.dark;
    return RotationTransition(
      turns: turns,
      child: CustomPaint(
        size: Size(size, size),
        painter: RaysRingPainter(
          color: (dark ? AppColorsDark.gold : AppColors.gold)
              .withOpacity(0.55),
        ),
      ),
    );
  }
}
