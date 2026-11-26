import 'package:flutter/material.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';

/// Planet details list with degrees, rashi, bhava and swami.
/// Sample data only. Only Surya carries a full sample degree.
class PlanetDetails extends StatelessWidget {
  const PlanetDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Planet details', style: AppTextStyles.subtitle),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Sample data. Birth 14 March 1998, Jaipur.',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        ...SampleKundli.planets.map((PlanetDetail planet) {
          return Card(
            child: ListTile(
              title: Text(
                planet.name,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Rashi: ${planet.rashi}\n'
                'Bhava: ${planet.bhava}\n'
                'Swami: ${planet.swami}\n'
                '${planet.note}',
                style: AppTextStyles.bodySmall,
              ),
              trailing: Text(
                planet.degree,
                style: AppTextStyles.chartPlanet.copyWith(
                  color: AppColors.deepSaffron,
                ),
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
    );
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
