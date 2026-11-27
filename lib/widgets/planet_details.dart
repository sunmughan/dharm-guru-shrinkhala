// material.dart is deprecated in Flutter 3.50; migrate to package:material_ui as a separate task.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';

/// Planet details table with degrees, rashi, bhava and swami.
/// Exact sample values from design/screens/06-planet-details.md.
/// Sample data only.
class PlanetDetails extends StatelessWidget {
  const PlanetDetails({super.key});

  @override
  Widget build(BuildContext context) {
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
            border: const TableBorder(
              horizontalInside: BorderSide(
                color: AppColors.line,
                width: 1,
              ),
            ),
            children: <TableRow>[
              _headerRow(),
              ...SampleKundli.planets.map(_planetRow),
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
                const Text(
                  'Swami notes',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppSpacing.space3),
                _swamiRow(
                  'Lagna swami',
                  'Lagna swami is Jupiter.',
                ),
                const SizedBox(height: AppSpacing.space3),
                _swamiRow(
                  'Rashi swami',
                  'Rashi swami is Mercury.',
                ),
                const SizedBox(height: AppSpacing.space3),
                _swamiRow(
                  'Nakshatra swami',
                  'Nakshatra swami is Moon.',
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
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(AppSpacing.smallRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Full planet detail is a premium feature. '
                'Your basic chart stays free.',
                style: AppTextStyles.bodySmall,
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

  TableRow _headerRow() {
    return TableRow(
      children: <Widget>[
        _headerCell('Planet', TextAlign.left),
        _headerCell('Rashi', TextAlign.left),
        _headerCell('Bhava', TextAlign.center),
        _headerCell('Degree', TextAlign.right),
      ],
    );
  }

  Widget _headerCell(String label, TextAlign align) {
    return Container(
      color: AppColors.surface2,
      height: 40,
      alignment: align == TextAlign.center
          ? Alignment.center
          : align == TextAlign.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }

  TableRow _planetRow(PlanetDetail planet) {
    return TableRow(
      children: <Widget>[
        _bodyCell(
          Text(planet.name, style: AppTextStyles.listTitle),
          Alignment.centerLeft,
        ),
        _bodyCell(
          Text(planet.rashi, style: AppTextStyles.body),
          Alignment.centerLeft,
        ),
        _bodyCell(
          Text(
            planet.bhava,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          Alignment.center,
        ),
        _bodyCell(
          Semantics(
            label: _spokenDegree(planet.degree),
            child: Text(
              planet.degree,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
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

  Widget _swamiRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTextStyles.caption),
        Text(value, style: AppTextStyles.body),
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
      child: const Text(
        'Sample data only. No real prediction.',
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
