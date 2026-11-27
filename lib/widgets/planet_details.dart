import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';
import '../services/astro.dart';

/// Planet details table with degrees, rashi, bhava and swami.
/// Renders any kundli it is given. The defaults are the old
/// sample values, used only before the profile is complete.
class PlanetDetails extends StatelessWidget {
  /// Defaults are the sample values: Kanya rashi, Hasta
  /// nakshatra, matching BirthDetails.sample.
  const PlanetDetails({
    super.key,
    this.planets = SampleKundli.planets,
    this.lagna = SampleKundli.lagna,
    this.rashi = 'Kanya',
    this.nakshatra = 'Hasta',
  });

  final List<PlanetDetail> planets;
  final String lagna;
  final String rashi;
  final String nakshatra;

  @override
  Widget build(BuildContext context) {
    final int lagnaIndex = kRashis.indexOf(lagna);
    final int rashiIndex = kRashis.indexOf(rashi);
    final int nakshatraIndex = kNakshatras.indexOf(nakshatra);
    final String lagnaLord = lagnaIndex < 0
        ? 'Jupiter'
        : kRashiLords[lagnaIndex];
    final String rashiLord = rashiIndex < 0
        ? 'Mercury'
        : kRashiLords[rashiIndex];
    final String nakshatraLord = nakshatraIndex < 0
        ? 'Moon'
        : kNakshatraLords[nakshatraIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Card(
          clipBehavior: Clip.antiAlias,
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(3),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: AppColors.resolve(
                  context,
                  AppColors.line,
                  AppColorsDark.line,
                ),
                width: 1,
              ),
            ),
            children: <TableRow>[
              _headerRow(context),
              ...planets.map(
                (PlanetDetail planet) => _planetRow(context, planet),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Swami notes',
                  style: AppTextStyles.themed(context, AppTextStyles.cardTitle),
                ),
                const SizedBox(height: AppSpacing.space3),
                _swamiRow(
                  context,
                  'Lagna swami',
                  'Lagna swami is $lagnaLord.',
                ),
                const SizedBox(height: AppSpacing.space3),
                _swamiRow(
                  context,
                  'Rashi swami',
                  'Rashi swami is $rashiLord.',
                ),
                const SizedBox(height: AppSpacing.space3),
                _swamiRow(
                  context,
                  'Nakshatra swami',
                  'Nakshatra swami is $nakshatraLord.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space3),
          decoration: BoxDecoration(
            color: AppColors.resolve(
              context,
              AppColors.surface2,
              AppColorsDark.surface2,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Full planet detail is a premium feature. '
                'Your basic chart stays free.',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Premium upgrade is a later phase.',
                        ),
                      ),
                    );
                  },
                  child: const Text('View premium'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _headerRow(BuildContext context) {
    return TableRow(
      children: <Widget>[
        _headerCell(context, 'Planet', TextAlign.left),
        _headerCell(context, 'Rashi', TextAlign.left),
        _headerCell(context, 'Bhava', TextAlign.center),
        _headerCell(context, 'Degree', TextAlign.right),
      ],
    );
  }

  Widget _headerCell(BuildContext context, String label, TextAlign align) {
    return Container(
      color: AppColors.resolve(
        context,
        AppColors.surface2,
        AppColorsDark.surface2,
      ),
      height: 40,
      alignment: align == TextAlign.center
          ? Alignment.center
          : align == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
      ),
      child: Text(label, style: AppTextStyles.themed(context, AppTextStyles.caption)),
    );
  }

  TableRow _planetRow(BuildContext context, PlanetDetail planet) {
    return TableRow(
      children: <Widget>[
        _bodyCell(
          Text(planet.name, style: AppTextStyles.themed(context, AppTextStyles.listTitle)),
          Alignment.centerLeft,
        ),
        _bodyCell(
          Text(planet.rashi, style: AppTextStyles.themed(context, AppTextStyles.body)),
          Alignment.centerLeft,
        ),
        _bodyCell(
          Text(
            planet.bhava,
            style: AppTextStyles.themed(context, AppTextStyles.body),
            textAlign: TextAlign.center,
          ),
          Alignment.center,
        ),
        _bodyCell(
          Semantics(
            label: _spokenDegree(planet.degree),
            child: Text(
              planet.degree,
              style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              )),
              textAlign: TextAlign.right,
            ),
          ),
          Alignment.centerRight,
        ),
      ],
    );
  }

  Widget _bodyCell(Widget child, Alignment alignment) {
    return Container(
      height: 52,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
      ),
      child: child,
    );
  }

  Widget _swamiRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.themed(context, AppTextStyles.caption)),
        Text(value, style: AppTextStyles.themed(context, AppTextStyles.body)),
      ],
    );
  }

  String _spokenDegree(String degree) {
    return degree
        .replaceAll('°', ' degrees')
        .replaceAll('′', ' minutes');
  }
}

/// Small banner used on every screen that shows sample data.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.saffron.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.saffron),
      ),
      child: Text(
        'Sample data only. No real prediction.',
        style: AppTextStyles.themed(context, AppTextStyles.caption),
        textAlign: TextAlign.center,
      ),
    );
  }
}
