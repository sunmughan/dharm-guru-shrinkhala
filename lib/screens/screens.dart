import 'package:flutter/material.dart';

import '../core/theme/design_tokens.dart';
import '../models/kundli.dart';
import '../models/panchang.dart';
import '../widgets/kundli_chart.dart';
import '../widgets/planet_details.dart';

/// Splash screen. Shows the app name, then moves to onboarding.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepInk,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.auto_awesome, size: 72, color: AppColors.saffron),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Dharm Guru Shrinkhala',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Astrology and horoscope',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: onDone,
              child: const Text('Begin'),
            ),
          ],
        ),
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
            const Text(
              'Your kundli, horoscope and panchang in one place.',
              style: AppTextStyles.display,
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
            child: Text(number, style: AppTextStyles.button),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.subtitle),
                Text(body, style: AppTextStyles.bodySmall),
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
          const Text('Namaste, Aarav Sharma', style: AppTextStyles.display),
          const Text(
            'Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan. Lagna Meena, Rashi Kanya.',
            style: AppTextStyles.bodySmall,
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
            body: 'Matching layout. Matching calculation is a later phase.',
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
            body: 'Remedies list. Remedy content is published from the admin panel.',
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
        title: Text(title, style: AppTextStyles.subtitle),
        subtitle: Text(body, style: AppTextStyles.bodySmall),
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
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const KundliChartScreen(),
                ),
              );
            },
            child: const Text('Show Kundli'),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Phase 1 shows the sample kundli. Real kundli calculation is a later phase.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Kundli chart screen with the North Indian chart and planet details.
class KundliChartScreen extends StatelessWidget {
  const KundliChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Kundli')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: const <Widget>[
          SampleDataBanner(),
          SizedBox(height: AppSpacing.md),
          Text('Lagna: Meena', style: AppTextStyles.title),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan. Surya in Meena lagna at 01° 24′.',
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: AppSpacing.md),
          KundliChart(),
          SizedBox(height: AppSpacing.lg),
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
    final HoroscopeEntry entry = HoroscopeEntry.sample;
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Horoscope')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text('Rashi: ${entry.rashi}', style: AppTextStyles.title),
          Text(entry.date, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(entry.summary, style: AppTextStyles.body),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No horoscope prediction is shown in Phase 1. Content is published from the admin panel in a later phase.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Panchang screen: tithi, vaar, nakshatra, shubh muhurat.
/// Sample date 14 March 1998. Values are marked sample.
class PanchangScreen extends StatelessWidget {
  const PanchangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Panchang panchang = Panchang.sample;
    return Scaffold(
      appBar: AppBar(title: const Text('Panchang')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
          Text(panchang.date, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          _PanchangRow(label: 'Tithi', value: panchang.tithi),
          _PanchangRow(label: 'Vaar', value: panchang.vaar),
          _PanchangRow(label: 'Nakshatra', value: panchang.nakshatra),
          _PanchangRow(label: 'Shubh Muhurat', value: panchang.shubhMuhurat),
          _PanchangRow(label: 'Sunrise', value: panchang.sunrise),
          _PanchangRow(label: 'Sunset', value: panchang.sunset),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Panchang values are sample labels in Phase 1. Real panchang calculation is a later phase.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PanchangRow extends StatelessWidget {
  const _PanchangRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: AppTextStyles.subtitle),
        trailing: Text(value, style: AppTextStyles.body),
      ),
    );
  }
}

/// Kundli matching screen. Layout only in Phase 1.
class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kundli Matching')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: const <Widget>[
          SampleDataBanner(),
          SizedBox(height: AppSpacing.md),
          Text(
            'Enter birth details for both people to see matching.',
            style: AppTextStyles.body,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Matching calculation is a later phase. No score is shown in Phase 1.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Remedies screen. Content is published from the admin panel later.
class RemediesScreen extends StatelessWidget {
  const RemediesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remedies')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: const <Widget>[
          SampleDataBanner(),
          SizedBox(height: AppSpacing.md),
          Text(
            'Remedy content will be published from the admin panel.',
            style: AppTextStyles.body,
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
          const Text(
            'Chat and call with an astrologer.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat, color: AppColors.deepSaffron),
              title: const Text('Chat', style: AppTextStyles.subtitle),
              subtitle: const Text(
                'Live chat is a later phase.',
                style: AppTextStyles.bodySmall,
              ),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.call, color: AppColors.deepSaffron),
              title: const Text('Call', style: AppTextStyles.subtitle),
              subtitle: const Text(
                'Live call is a later phase. Pricing to be decided.',
                style: AppTextStyles.bodySmall,
              ),
              onTap: () {},
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
          const Text(
            'Aarav Sharma',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const Text(
            'Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Text(
            'Lagna Meena, Rashi Kanya, Nakshatra Hasta, Tithi at Birth Krishna Dwitiya',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Card(
            child: ListTile(
              title: Text('Plan', style: AppTextStyles.subtitle),
              subtitle: Text(
                'Free plan. Premium pricing to be decided.',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Notifications', style: AppTextStyles.subtitle),
              subtitle: Text(
                'Daily horoscope alert at 06:00 AM.',
                style: AppTextStyles.bodySmall,
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
