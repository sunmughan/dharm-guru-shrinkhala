import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';

/// North Indian square kundli chart.
///
/// Rashi order runs anticlockwise from lagna, per
/// design/screens/05-kundli-chart.md. Lagna sits in the top
/// centre cell. Bhava 2 is top left of lagna, bhava 3 is the
/// top left corner, and the order continues down the left
/// side, along the bottom, and up the right side back to
/// bhava 12 at the top right.
///
/// The chart renders any kundli it is given: lagna and
/// planets come from the real calculation. The defaults are
/// the old sample chart, used only before the profile is
/// complete, and the chart is then marked as sample.
class KundliChart extends StatelessWidget {
  const KundliChart({
    super.key,
    this.birth = SampleKundli.birth,
    this.planets = SampleKundli.planets,
    this.lagna = 'Meena',
    this.isSample = true,
  });

  final BirthDetails birth;
  final List<PlanetDetail> planets;

  /// Lagna rashi name, the rashi in bhava 1.
  final String lagna;

  /// True when the chart is the sample shown before the
  /// profile is complete. The centre cell then says so.
  final bool isSample;

  /// Bhava number for each cell, row by row, left to right.
  /// Top row: 3, 2, 1, 12. Middle rows: 4 and 11, then 5 and 10.
  /// Bottom row: 6, 7, 8, 9. This is the anticlockwise order.
  static const List<List<int>> _bhavaGrid = <List<int>>[
    <int>[3, 2, 1, 12],
    <int>[4, 11],
    <int>[5, 10],
    <int>[6, 7, 8, 9],
  ];

  /// Rashi order, anticlockwise from Mesha.
  static const List<String> _rashiOrder = <String>[
    'Mesha',
    'Vrishabha',
    'Mithuna',
    'Karka',
    'Simha',
    'Kanya',
    'Tula',
    'Vrishchika',
    'Dhanu',
    'Makara',
    'Kumbha',
    'Meena',
  ];

  /// Rashi in a bhava, counted anticlockwise from lagna.
  String _rashiForBhava(int bhava) {
    final int lagnaIndex = _rashiOrder.indexOf(lagna);
    final int start = lagnaIndex < 0 ? 11 : lagnaIndex;
    return _rashiOrder[(start + bhava - 1) % 12];
  }

  List<String> _planetsInBhava(int bhava) {
    final List<String> found = <String>[];
    if (bhava == 1) {
      found.add('As');
    }
    for (final PlanetDetail planet in planets) {
      if (planet.bhava == 'Bhava $bhava') {
        final String? abbr = SampleKundli.abbreviations[planet.name];
        if (abbr != null) {
          found.add(abbr);
        }
      }
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.resolve(
            context,
            AppColors.cardWhite,
            AppColorsDark.surface,
          ),
          border: Border.all(
            color: AppColors.resolve(
              context,
              AppColors.deepInk,
              AppColorsDark.ink,
            ),
            width: 1,
          ),
          borderRadius:
              BorderRadius.circular(AppSpacing.chartRadius),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _ChartLines()),
            Column(
              children: <Widget>[
                Expanded(
                  child: _chartRow(_bhavaGrid[0]),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _cellForBhava(_bhavaGrid[1][0]),
                      ),
                      Expanded(
                        flex: 2,
                        child: _CenterCell(birth: birth, lagna: lagna),
                      ),
                      Expanded(
                        child: _cellForBhava(_bhavaGrid[1][1]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _cellForBhava(_bhavaGrid[2][0]),
                      ),
                      Expanded(
                        flex: 2,
                        child: _NameCell(birth: birth, isSample: isSample),
                      ),
                      Expanded(
                        child: _cellForBhava(_bhavaGrid[2][1]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _chartRow(_bhavaGrid[3]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartRow(List<int> bhavas) {
    return Row(
      children: bhavas.map((int bhava) {
        return Expanded(child: _cellForBhava(bhava));
      }).toList(),
    );
  }

  Widget _cellForBhava(int bhava) {
    return _RashiCell(
      label: _rashiForBhava(bhava),
      planets: _planetsInBhava(bhava),
      isLagna: bhava == 1,
    );
  }
}

class _RashiCell extends StatelessWidget {
  const _RashiCell({
    required this.label,
    required this.planets,
    required this.isLagna,
  });

  final String label;
  final List<String> planets;
  final bool isLagna;

  @override
  Widget build(BuildContext context) {
    final List<String> shown =
        planets.length > 3 ? planets.sublist(0, 3) : planets;
    final int overflow = planets.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            label,
            style: AppTextStyles.themed(context, AppTextStyles.chartRashi),
            textAlign: TextAlign.center,
          ),
        ),
        if (isLagna)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    color: AppColors.saffron,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Lagna',
                  style: AppTextStyles.themed(context, AppTextStyles.caption.copyWith(
                    color: AppColors.saffron2,
                  )),
                ),
              ],
            ),
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                children: shown.map((String abbr) {
                  return Text(abbr, style: AppTextStyles.themed(context, AppTextStyles.chartPlanet));
                }).toList(),
              ),
              if (overflow > 0)
                Text(
                  '+$overflow',
                  style: AppTextStyles.themed(context, AppTextStyles.caption),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterCell extends StatelessWidget {
  const _CenterCell({required this.birth, required this.lagna});

  final BirthDetails birth;
  final String lagna;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Lagna $lagna',
            style: AppTextStyles.themed(context, AppTextStyles.chartPlanet.copyWith(
              color: AppColors.deepSaffron,
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              birth.dateOfBirth,
              style: AppTextStyles.themed(context, AppTextStyles.chartDegree),
            ),
          ),
          Text(birth.placeOfBirth, style: AppTextStyles.themed(context, AppTextStyles.chartDegree)),
        ],
      ),
    );
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell({required this.birth, required this.isSample});

  final BirthDetails birth;
  final bool isSample;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            birth.name,
            style: AppTextStyles.themed(context, AppTextStyles.chartPlanet),
            textAlign: TextAlign.center,
          ),
          if (isSample)
            Text(
              'Sample data',
              style: AppTextStyles.themed(context, AppTextStyles.caption),
            ),
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
    return CustomPaint(
      painter: _DiamondPainter(
        AppColors.resolve(
          context,
          AppColors.deepInk,
          AppColorsDark.ink,
        ),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  _DiamondPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
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
