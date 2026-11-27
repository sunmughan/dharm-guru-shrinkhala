import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';
import '../models/panchang.dart';
import '../models/remedies.dart';
import '../widgets/kundli_chart.dart';
import '../widgets/planet_details.dart';

/// Splash screen. Wordmark only, no button, no link, no
/// version text. Auto advances after two seconds, per
/// design/screens/01-splash.md. The sun mark uses the closest
/// line icon, Icons.wb_sunny, because Flutter has no drawn
/// sun mark.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted || _advanced) {
        return;
      }
      _advanced = true;
      widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.wb_sunny,
                      size: 64,
                      color: AppColors.saffron,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Dharm Guru',
                      style: AppTextStyles.themed(context, AppTextStyles.display),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your kundli. Your guidance. Every single day.',
                      style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                        color: AppColors.ink2,
                      )),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _SplashDot(active: false),
                        SizedBox(width: AppSpacing.sm),
                        _SplashDot(active: true),
                        SizedBox(width: AppSpacing.sm),
                        _SplashDot(active: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SplashDot extends StatelessWidget {
  const _SplashDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.saffron : AppColors.line2,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Onboarding screen. Three short steps, then the home shell.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your kundli, horoscope and panchang in one place.',
              style: AppTextStyles.themed(context, AppTextStyles.display),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _OnboardingStep(
              number: '1',
              title: 'Enter birth details',
              body: 'Name, date, time and place of birth.',
            ),
            const _OnboardingStep(
              number: '2',
              title: 'See your kundli',
              body: 'North Indian chart with planet details.',
            ),
            const _OnboardingStep(
              number: '3',
              title: 'Read daily guidance',
              body: 'Horoscope, panchang and remedies.',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: AppColors.saffron,
            child: Text(number, style: AppTextStyles.themed(context, AppTextStyles.button)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
                Text(body, style: AppTextStyles.themed(context, AppTextStyles.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Home screen. Cards lead to kundli, horoscope, panchang,
/// matching, remedies and live consult.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final void Function(int tabIndex) onOpenTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Shrinkhala')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text('Namaste, Aarav Sharma', style: AppTextStyles.themed(context, AppTextStyles.display)),
          Text(
            'Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan. Lagna Meena, Rashi Kanya.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
          const SizedBox(height: AppSpacing.md),
          _HomeCard(
            title: 'Your Kundli',
            body: 'North Indian chart. Surya in Meena lagna at 01° 24′.',
            icon: Icons.grid_on,
            onTap: () => onOpenTab(1),
          ),
          _HomeCard(
            title: 'Daily Horoscope',
            body: 'Horoscope content will be published from the admin panel.',
            icon: Icons.wb_sunny,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HoroscopeScreen(),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Panchang',
            body: 'Tithi, vaar, nakshatra and shubh muhurat.',
            icon: Icons.calendar_month,
            onTap: () => onOpenTab(2),
          ),
          _HomeCard(
            title: 'Kundli Matching',
            body: 'Guna milan score with dosha check.',
            icon: Icons.favorite,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MatchingScreen(),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Remedies',
            body: 'Simple upay chosen from your kundli.',
            icon: Icons.spa,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RemediesScreen(),
                ),
              );
            },
          ),
          _HomeCard(
            title: 'Live Consult',
            body: 'Chat and call with an astrologer. Pricing to be decided.',
            icon: Icons.call,
            onTap: () => onOpenTab(3),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.deepSaffron, size: 32),
        title: Text(title, style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
        subtitle: Text(body, style: AppTextStyles.themed(context, AppTextStyles.bodySmall)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Kundli input form: name, date, time and place of birth.
class KundliInputScreen extends StatefulWidget {
  const KundliInputScreen({super.key});

  @override
  State<KundliInputScreen> createState() => _KundliInputScreenState();
}

class _KundliInputScreenState extends State<KundliInputScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Aarav Sharma');
  final TextEditingController _dateController =
      TextEditingController(text: '14 March 1998');
  final TextEditingController _timeController =
      TextEditingController(text: '06:25 AM');
  final TextEditingController _placeController =
      TextEditingController(text: 'Jaipur, Rajasthan');

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Date of birth'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(labelText: 'Time of birth'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _placeController,
            decoration: const InputDecoration(labelText: 'Place of birth'),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              final String name = _nameController.text.trim();
              final String date = _dateController.text.trim();
              final String time = _timeController.text.trim();
              final String place = _placeController.text.trim();
              if (name.isEmpty ||
                  date.isEmpty ||
                  time.isEmpty ||
                  place.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter name, date, time and place of birth.',
                    ),
                  ),
                );
                return;
              }
              final BirthDetails entered = BirthDetails(
                name: name,
                dateOfBirth: date,
                timeOfBirth: time,
                placeOfBirth: place,
                rashi: '',
                nakshatra: '',
                tithiAtBirth: '',
              );
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => KundliChartScreen(birth: entered),
                ),
              );
            },
            child: const Text('Show Kundli'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Only the sample kundli is ready in this version. Other birth details show a not ready state instead of a made up chart.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Kundli chart screen with the North Indian chart, the
/// Lagna and Moon chart switcher, the summary chips and the
/// planet summary list, per design/screens/05-kundli-chart.md.
/// Moon Chart has no engine data in Phase 1, so it shows the
/// not ready state and invents no values. The chart shown is
/// the sample kundli when the entered birth details match the
/// sample; any other birth details show the not ready state
/// with the entered details, never a made up chart.
class KundliChartScreen extends StatefulWidget {
  const KundliChartScreen({
    super.key,
    this.birth = SampleKundli.birth,
  });

  final BirthDetails birth;

  @override
  State<KundliChartScreen> createState() => _KundliChartScreenState();
}

class _KundliChartScreenState extends State<KundliChartScreen> {
  bool _showMoonChart = false;
  bool _viewingSample = false;

  bool get _isSample =>
      widget.birth.dateOfBirth == SampleKundli.birth.dateOfBirth &&
      widget.birth.timeOfBirth == SampleKundli.birth.timeOfBirth &&
      widget.birth.placeOfBirth == SampleKundli.birth.placeOfBirth;

  @override
  Widget build(BuildContext context) {
    final bool showChart = _isSample || _viewingSample;
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Kundli')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          if (!showChart) ...<Widget>[
            _BirthNotReady(birth: widget.birth),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _viewingSample = true;
                  });
                },
                child: const Text('View sample kundli'),
              ),
            ),
          ] else ...<Widget>[
            _ChartSwitcher(
              showMoon: _showMoonChart,
              onChanged: (bool showMoon) {
                setState(() {
                  _showMoonChart = showMoon;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (_showMoonChart)
              const _MoonChartNotReady()
            else ...<Widget>[
              const KundliChart(),
              const SizedBox(height: AppSpacing.space3),
              const _ChartLegend(),
              const SizedBox(height: AppSpacing.md),
              const _PlanetSummaryList(),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PlanetDetailsScreen(),
                    ),
                  );
                },
                child: const Text('See Planet Details'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Honest not ready state for birth details with no chart
/// engine data. Shows the entered details back so the user
/// sees the form did something, and invents no chart.
class _BirthNotReady extends StatelessWidget {
  const _BirthNotReady({required this.birth});

  final BirthDetails birth;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              birth.name,
              style: AppTextStyles.themed(context, AppTextStyles.title),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${birth.dateOfBirth}, ${birth.timeOfBirth}, ${birth.placeOfBirth}',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Kundli calculation for these birth details is not ready yet. No chart is shown for them.',
              style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented control for Lagna Chart and Moon Chart, per the
/// design system section 10.3. Pill container in surface2,
/// selected segment in surface with a line2 border and saffron
/// text, unselected segment in ink2 text. Height 40.
class _ChartSwitcher extends StatelessWidget {
  const _ChartSwitcher({
    required this.showMoon,
    required this.onChanged,
  });

  final bool showMoon;
  final void Function(bool showMoon) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.resolve(
          context,
          AppColors.surface2,
          AppColorsDark.surface2,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _switcherSegment(
              context,
              label: 'Lagna Chart',
              selected: !showMoon,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _switcherSegment(
              context,
              label: 'Moon Chart',
              selected: showMoon,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switcherSegment(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.resolve(
                  context,
                  AppColors.surface,
                  AppColorsDark.surface,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          border: selected
              ? Border.all(
                  color: AppColors.resolve(
                    context,
                    AppColors.line2,
                    AppColorsDark.line2,
                  ),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.themed(context, AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.saffron : AppColors.ink2,
          )),
        ),
      ),
    );
  }
}

class _MoonChartNotReady extends StatelessWidget {
  const _MoonChartNotReady();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        alignment: Alignment.center,
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
        child: Text(
          'Moon chart is not ready yet.',
          style: AppTextStyles.themed(context, AppTextStyles.body),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Three summary chips below the chart: Lagna, Rashi,
/// Nakshatra. Each is a small card with the label in Caption
/// 12 ink3 above the value in Title 17 ink. Tapping a chip
/// does nothing. They are a summary, not buttons.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(child: _LegendChip(label: 'Lagna', value: 'Meena')),
        SizedBox(width: AppSpacing.space3),
        Expanded(child: _LegendChip(label: 'Rashi', value: 'Kanya')),
        SizedBox(width: AppSpacing.space3),
        Expanded(
          child: _LegendChip(label: 'Nakshatra', value: 'Hasta'),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: AppTextStyles.themed(context, AppTextStyles.caption)),
            Text(value, style: AppTextStyles.themed(context, AppTextStyles.listTitle)),
          ],
        ),
      ),
    );
  }
}

/// Planet summary list below the chart. One row per planet in
/// the chart, in the same order as the planet details table.
/// This list is the text equivalent of the chart figure.
class _PlanetSummaryList extends StatelessWidget {
  const _PlanetSummaryList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: SampleKundli.planets.map((PlanetDetail planet) {
        final String abbr =
            SampleKundli.abbreviations[planet.name] ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(
                    AppSpacing.pillRadius,
                  ),
                  border: Border.all(color: AppColors.line2, width: 1),
                ),
                child: Text(
                  abbr,
                  style: AppTextStyles.themed(context, AppTextStyles.chartPlanet),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  planet.name,
                  style: AppTextStyles.themed(context, AppTextStyles.listTitle),
                ),
              ),
              Text(
                '${planet.rashi}, ${planet.bhava}',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Planet details screen: full table with exact degrees,
/// swami notes and the premium note, per
/// design/screens/06-planet-details.md.
class PlanetDetailsScreen extends StatelessWidget {
  const PlanetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planet Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          SampleDataBanner(),
          SizedBox(height: AppSpacing.md),
          Text(
            'Position, rashi, bhava and exact degree of every graha.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          SizedBox(height: AppSpacing.md),
          PlanetDetails(),
        ],
      ),
    );
  }
}

/// Daily horoscope screen. No prediction text in Phase 1.
class HoroscopeScreen extends StatelessWidget {
  const HoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const HoroscopeEntry entry = HoroscopeEntry.sample;
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Horoscope')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text('Rashi: ${entry.rashi}', style: AppTextStyles.themed(context, AppTextStyles.title)),
          Text(entry.date, style: AppTextStyles.themed(context, AppTextStyles.bodySmall)),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(entry.summary, style: AppTextStyles.themed(context, AppTextStyles.body)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No horoscope prediction is shown in Phase 1. Content is published from the admin panel in a later phase.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

/// Panchang screen: tithi, vaar, nakshatra, yoga, karana,
/// sunrise, sunset, shubh muhurat and rahu kaal, per
/// design/screens/08-panchang.md. Sample date is Saturday
/// 14 March 1998, Jaipur. Values are marked sample.
class PanchangScreen extends StatelessWidget {
  const PanchangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Panchang panchang = Panchang.sample;
    final List<String> muhuratWindows =
        panchang.shubhMuhurat.split(' and ');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todays Panchang'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('City choice is a later phase.'),
                ),
              );
            },
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            label: Text(
              panchang.city,
              style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
                color: AppColors.saffron2,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text(
            panchang.dateLine,
            style: AppTextStyles.themed(context, AppTextStyles.body.copyWith(
              color: AppColors.ink2,
            )),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.7,
            children: <Widget>[
              _PanchangCard(label: 'Tithi', value: panchang.tithi),
              _PanchangCard(label: 'Vaar', value: panchang.vaar),
              _PanchangCard(
                label: 'Nakshatra',
                value: panchang.nakshatra,
              ),
              _PanchangCard(label: 'Yoga', value: panchang.yoga),
              _PanchangCard(label: 'Karana', value: panchang.karana),
              _PanchangCard(label: 'Sunrise', value: panchang.sunrise),
              _PanchangCard(label: 'Sunset', value: panchang.sunset),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: AppColors.resolve(
              context,
              AppColors.surface2,
              AppColorsDark.surface2,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Shubh Muhurat',
                    style: AppTextStyles.themed(context, AppTextStyles.caption.copyWith(
                      color: AppColors.saffron2,
                    )),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...muhuratWindows.map(
                    (String window) => Text(
                      window,
                      style: AppTextStyles.themed(context, AppTextStyles.subtitle),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Best for new beginnings.',
                    style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.space3),
            decoration: BoxDecoration(
              color: AppColors.resolve(
                context,
                AppColors.surface2,
                AppColorsDark.surface2,
              ),
              borderRadius: BorderRadius.circular(
                AppSpacing.smallRadius,
              ),
              border: Border(
                left: BorderSide(
                  color: AppColors.resolve(
                    context,
                    AppColors.maroon,
                    AppColorsDark.maroon,
                  ),
                  width: 3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Rahu Kaal',
                  style: AppTextStyles.themed(context, AppTextStyles.caption.copyWith(
                    color: AppColors.maroon,
                  )),
                ),
                Text(
                  panchang.rahuKaal,
                  style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Panchang values are sample values in Phase 1. Real panchang calculation is a later phase.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _PanchangCard extends StatelessWidget {
  const _PanchangCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: AppTextStyles.themed(context, AppTextStyles.caption)),
            Text(value, style: AppTextStyles.themed(context, AppTextStyles.listTitle)),
          ],
        ),
      ),
    );
  }
}

/// Kundli matching screen, per design/screens/09-kundli-matching.md.
/// Sample persons Aarav and Priya with the sample score 28 / 36,
/// three guna rows and the dosha value from the presentation.
/// New match clears the second person; the empty card opens the
/// birth details form. The full report is premium, so its button
/// says so honestly instead of opening a fake report.
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  bool _secondPersonChosen = true;

  void _showPremiumNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Full milan report is premium. Pricing to be decided.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundli Matching'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _secondPersonChosen = false;
              });
            },
            child: Text(
              'New match',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Milan for marriage and partnership.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _PersonCard(
                  initial: 'A',
                  name: 'Aarav',
                  detail: 'Meena Lagna',
                  onTap: null,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(Icons.diamond, size: 12),
              ),
              Expanded(
                child: _secondPersonChosen
                    ? _PersonCard(
                        initial: 'P',
                        name: 'Priya',
                        detail: 'Karka Lagna',
                        onTap: null,
                      )
                    : _PersonCard(
                        initial: '+',
                        name: 'Add second kundli',
                        detail: '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const KundliInputScreen(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          if (_secondPersonChosen) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Card(
              color: AppColors.resolve(
                context,
                AppColors.surface2,
                AppColorsDark.surface2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space5),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Guna Milan Score',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.caption.copyWith(
                          color: AppColors.saffron2,
                        ),
                      ),
                    ),
                    Text(
                      '28 / 36',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.title,
                      ),
                    ),
                    Text(
                      'Very Good Match',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.listTitle.copyWith(
                          color: AppColors.good,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Column(
                children: <Widget>[
                  _GunaRow(label: 'Varna', score: '1 / 1'),
                  _GunaRow(label: 'Bhakoot', score: '7 / 7'),
                  _GunaRow(label: 'Nadi', score: '8 / 8'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Mangal Dosha',
                        style: AppTextStyles.themed(
                          context,
                          AppTextStyles.listTitle,
                        ),
                      ),
                    ),
                    Text(
                      'Balanced',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.good,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showPremiumNote,
                child: const Text('View Full Milan Report'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'One free matching each day. The next matching is free tomorrow.',
              style: AppTextStyles.themed(context, AppTextStyles.caption),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.initial,
    required this.name,
    required this.detail,
    required this.onTap,
  });

  final String initial;
  final String name;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.saffron,
                child: Text(
                  initial,
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.button,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                name,
                style: AppTextStyles.themed(
                  context,
                  AppTextStyles.listTitle,
                ),
                textAlign: TextAlign.center,
              ),
              if (detail.isNotEmpty)
                Text(
                  detail,
                  style: AppTextStyles.themed(
                    context,
                    AppTextStyles.bodySmall,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GunaRow extends StatelessWidget {
  const _GunaRow({required this.label, required this.score});

  final String label;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.themed(
                context,
                AppTextStyles.listTitle,
              ),
            ),
          ),
          Text(
            score,
            style: AppTextStyles.themed(
              context,
              AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Remedies screen, per design/screens/10-remedies.md. The four
/// cards are the presentation sample set for the sample kundli.
/// Mark as done is a real daily habit check: it flips to Done
/// today and resets the next morning. The gemstone question and
/// the Ask About a Remedy button lead to live consult, which is
/// premium, so they say so honestly instead of opening a fake
/// chat.
class RemediesScreen extends StatefulWidget {
  const RemediesScreen({super.key});

  @override
  State<RemediesScreen> createState() => _RemediesScreenState();
}

class _RemediesScreenState extends State<RemediesScreen> {
  // shortcut: done state is in memory only and does not survive
  // an app restart; persist it in Firestore when the remedies
  // engine lands.
  final Set<int> _done = <int>{};
  DateTime? _doneDay;

  bool _isDoneToday(int index) {
    if (_doneDay == null || !_done.contains(index)) {
      return false;
    }
    final DateTime now = DateTime.now();
    return _doneDay!.year == now.year &&
        _doneDay!.month == now.month &&
        _doneDay!.day == now.day;
  }

  void _markDone(int index) {
    final DateTime now = DateTime.now();
    setState(() {
      if (_doneDay == null ||
          _doneDay!.year != now.year ||
          _doneDay!.month != now.month ||
          _doneDay!.day != now.day) {
        _done.clear();
        _doneDay = now;
      }
      _done.add(index);
    });
  }

  void _showPremiumNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Live consult is premium. Pricing to be decided.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Remedies')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Simple upay chosen from your own kundli.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'This is a general set. A personal plan from your own kundli is premium.',
                      style: AppTextStyles.themed(
                        context,
                        AppTextStyles.bodySmall,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Premium pricing to be decided.',
                          ),
                        ),
                      );
                    },
                    child: const Text('View premium'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...SampleRemedies.list.asMap().entries.map(
            (MapEntry<int, Remedy> entry) {
              final int index = entry.key;
              final Remedy remedy = entry.value;
              final bool done = _isDoneToday(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          remedy.title,
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.cardTitle,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          remedy.body,
                          style: AppTextStyles.themed(
                            context,
                            AppTextStyles.body,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        if (done)
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.check_circle,
                                color: AppColors.resolve(
                                  context,
                                  AppColors.good,
                                  AppColorsDark.good,
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Done today',
                                style: AppTextStyles.themed(
                                  context,
                                  AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.good,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (remedy.action == 'done')
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _markDone(index),
                              child: const Text('Mark as done'),
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPremiumNote,
                              child: const Text('Ask about this gemstone'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showPremiumNote,
              child: const Text('Ask About a Remedy'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live consult screen. Chat and call with an astrologer.
/// Layout only in Phase 1. No astrologer names. Pricing to be decided.
class ConsultScreen extends StatelessWidget {
  const ConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Consult')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chat and call with an astrologer.',
            style: AppTextStyles.themed(context, AppTextStyles.body),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: AppColors.deepSaffron),
              title: Text('Chat', style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
              subtitle: Text(
                'Live chat is a later phase.',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Live chat is not ready yet.'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.call, color: AppColors.deepSaffron),
              title: Text('Call', style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
              subtitle: Text(
                'Live call is a later phase. Pricing to be decided.',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Live call is not ready yet. Pricing to be decided.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile screen. Free and premium plan. Pricing to be decided.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.saffron,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aarav Sharma',
            style: AppTextStyles.themed(context, AppTextStyles.title),
            textAlign: TextAlign.center,
          ),
          Text(
            'Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            textAlign: TextAlign.center,
          ),
          Text(
            'Lagna Meena, Rashi Kanya, Nakshatra Hasta, Tithi at Birth Krishna Dwitiya',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Card(
            child: ListTile(
              title: Text('Plan', style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
              subtitle: Text(
                'Free plan. Premium pricing to be decided.',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Notifications', style: AppTextStyles.themed(context, AppTextStyles.subtitle)),
              subtitle: Text(
                'Daily horoscope alert at 06:00 AM.',
                style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign in is a later phase.')),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
