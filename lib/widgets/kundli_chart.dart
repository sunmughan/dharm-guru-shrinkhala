import 'package:flutter/material.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';

/// North Indian square kundli chart.
/// Fixed rashi positions around the square. Lagna is Meena in the
/// sample data, so Surya is placed in the Meena cell.
/// Sample data only.
class KundliChart extends StatelessWidget {
  const KundliChart({super.key, this.birth = SampleKundli.birth});

  final BirthDetails birth;

  static const List<String> _topRow = <String>[
    'Kumbh',
    'Meena',
    'Mesh',
    'Vrishabh',
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          border: Border.all(color: AppColors.deepInk, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _ChartLines()),
            Column(
              children: <Widget>[
                Expanded(child: _chartRow(_topRow, showSurya: true)),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      const Expanded(child: _RashiCell(label: 'Makar')),
                      Expanded(
                        flex: 2,
                        child: _CenterCell(birth: birth),
                      ),
                      const Expanded(child: _RashiCell(label: 'Mithun')),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      const Expanded(child: _RashiCell(label: 'Dhanu')),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Sample chart',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ),
                      const Expanded(child: _RashiCell(label: 'Kark')),
                    ],
                  ),
                ),
                Expanded(
                  child: _chartRow(
                    const <String>['Vrishchik', 'Tula', 'Kanya', 'Simha'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartRow(List<String> labels, {bool showSurya = false}) {
    return Row(
      children: labels.map((String label) {
        return Expanded(
          child: _RashiCell(
            label: label,
            planet: showSurya && label == 'Meena' ? 'Su' : null,
            degree: showSurya && label == 'Meena' ? '01° 24′' : null,
          ),
        );
      }).toList(),
    );
  }
}

class _RashiCell extends StatelessWidget {
  const _RashiCell({required this.label, this.planet, this.degree});

  final String label;
  final String? planet;
  final String? degree;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(label, style: AppTextStyles.chartRashi),
          if (planet != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(planet!, style: AppTextStyles.chartPlanet),
            ),
          if (degree != null)
            Text(degree!, style: AppTextStyles.chartDegree),
        ],
      ),
    );
  }
}

class _CenterCell extends StatelessWidget {
  const _CenterCell({required this.birth});

  final BirthDetails birth;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            '◆ Lagna',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.saffron2,
              height: 1.3,
            ),
          ),
          Text(
            SampleKundli.lagna,
            style: AppTextStyles.chartPlanet.copyWith(
              color: AppColors.deepSaffron,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              birth.dateOfBirth,
              style: AppTextStyles.chartDegree,
            ),
          ),
          Text(birth.placeOfBirth, style: AppTextStyles.chartDegree),
        ],
      ),
    );
  }
}

/// Diamond lines of the North Indian chart.
class _ChartLines extends StatelessWidget {
  const _ChartLines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DiamondPainter());
  }
}

class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.deepInk
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final double w = size.width;
    final double h = size.height;
    final double quarterW = w / 4;
    final double quarterH = h / 4;
    canvas.drawLine(
      const Offset(0, 0),
      Offset(quarterW * 2, quarterH * 2),
      paint,
    );
    canvas.drawLine(
      Offset(w, 0),
      Offset(quarterW * 2, quarterH * 2),
      paint,
    );
    canvas.drawLine(
      Offset(0, h),
      Offset(quarterW * 2, quarterH * 2),
      paint,
    );
    canvas.drawLine(
      Offset(w, h),
      Offset(quarterW * 2, quarterH * 2),
      paint,
    );
    canvas.drawLine(
      Offset(quarterW, 0),
      Offset(quarterW * 3, 0),
      paint,
    );
    canvas.drawLine(
      Offset(quarterW, h),
      Offset(quarterW * 3, h),
      paint,
    );
    canvas.drawLine(
      Offset(0, quarterH),
      Offset(0, quarterH * 3),
      paint,
    );
    canvas.drawLine(
      Offset(w, quarterH),
      Offset(w, quarterH * 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
