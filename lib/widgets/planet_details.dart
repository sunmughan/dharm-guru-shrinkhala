import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';
import '../services/astro.dart';
import '../services/premium_service.dart';

/// Planet details table with degrees, rashi, bhava and swami.
/// Renders the kundli it is given, calculated by the engine.
class PlanetDetails extends StatelessWidget {
  const PlanetDetails({
    super.key,
    required this.planets,
    required this.lagna,
    required this.rashi,
    required this.nakshatra,
    this.premiumService,
  });

  final List<PlanetDetail> planets;
  final String lagna;
  final String rashi;
  final String nakshatra;

  /// Premium gate. Tests pass their own flag reader.
  final PremiumService? premiumService;

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
                    final bool enabled = (premiumService ?? PremiumService())
                        .isPremiumEnabled;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? 'Premium is on. Full planet detail opens here.'
                              : 'Premium is not available yet. Pricing to be decided.',
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
