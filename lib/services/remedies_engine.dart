import '../models/kundli.dart';
import '../models/remedies.dart';
import 'astro.dart';

/// Remedies derived from the real kundli. A planet counts as
/// weak when it is debilitated or sits in a dusthana bhava
/// (6, 8 or 12). The current Vimshottari Mahadasha lord gets
/// its own card. Every remedy text is the standard traditional
/// upay for that planet, chosen by the computed position, never
/// by a fixed list.
class WeakPlanet {
  const WeakPlanet({required this.name, required this.reason});

  final String name;
  final String reason;
}

/// Debilitation rashi for each planet.
const Map<String, String> kDebilitation = <String, String>{
  'Sun': 'Tula',
  'Moon': 'Vrishchika',
  'Mars': 'Karka',
  'Mercury': 'Meena',
  'Jupiter': 'Makara',
  'Venus': 'Kanya',
  'Saturn': 'Mesha',
};

/// Standard upay for each planet.
const Map<String, String> kPlanetRemedy = <String, String>{
  'Sun':
      'Offer water to the rising Sun each morning and chant Om Suryaya Namah eleven times.',
  'Moon':
      'Offer water to the Moon on Monday evenings and keep calm speech at home.',
  'Mars':
      'Offer red flowers to Hanuman on Tuesday and avoid harsh words when angry.',
  'Mercury':
      'Feed green fodder to a cow on Wednesday and speak with care in money talks.',
  'Jupiter':
      'Offer yellow flowers at a temple on Thursday and respect teachers and elders.',
  'Venus':
      'Offer white flowers on Friday and keep your home and clothes clean and bright.',
  'Saturn':
      'Light a mustard oil diya under a peepal tree on Saturday evening and serve the elderly.',
  'Rahu':
      'Chant Om Rahave Namah and avoid sudden decisions in money matters.',
  'Ketu':
      'Chant Om Ketave Namah and spend quiet time in prayer each morning.',
};

int _bhavaNumber(String bhava) =>
    int.tryParse(bhava.replaceAll('Bhava ', '')) ?? 0;

String _formatDay(DateTime day) =>
    '${day.day} ${_monthName(day.month)} ${day.year}';

String _monthName(int month) {
  const List<String> months = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return months[month - 1];
}

class RemedyEngine {
  RemedyEngine._();

  /// Weak planets in chart order, with the computed reason.
  static List<WeakPlanet> weakPlanets(KundliResult kundli) {
    final List<WeakPlanet> weak = <WeakPlanet>[];
    for (final PlanetDetail planet in kundli.planets) {
      final List<String> reasons = <String>[];
      if (kDebilitation[planet.name] == planet.rashi) {
        reasons.add('debilitated in ${planet.rashi}');
      }
      final int bhava = _bhavaNumber(planet.bhava);
      if (bhava == 6 || bhava == 8 || bhava == 12) {
        reasons.add('in Bhava $bhava');
      }
      if (reasons.isNotEmpty) {
        weak.add(WeakPlanet(
          name: planet.name,
          reason: reasons.join(' and '),
        ));
      }
    }
    return weak;
  }

  /// Remedies for this kundli today: one card per weak planet,
  /// then the current Mahadasha lord when it is not already
  /// listed. Never empty: the dasha card always applies.
  static List<Remedy> derive({
    required KundliResult kundli,
    required DateTime birthLocal,
    required DateTime asOf,
  }) {
    final List<Remedy> remedies = <Remedy>[];
    final List<WeakPlanet> weak = weakPlanets(kundli);
    for (final WeakPlanet planet in weak) {
      remedies.add(Remedy(
        title: 'For weak ${planet.name}',
        body: '${planet.name} is ${planet.reason}. '
            '${kPlanetRemedy[planet.name] ?? ''}',
        action: 'done',
      ));
    }
    final DashaInfo dasha = vimshottariDasha(
      birthLocal: birthLocal,
      asOf: asOf,
    );
    if (!weak.any((WeakPlanet w) => w.name == dasha.lord)) {
      remedies.add(Remedy(
        title: 'Current Mahadasha: ${dasha.lord}',
        body: 'The ${dasha.lord} Mahadasha runs from '
            '${_formatDay(dasha.start)} to ${_formatDay(dasha.end)}. '
            '${kPlanetRemedy[dasha.lord] ?? ''}',
        action: 'ask',
      ));
    }
    return remedies;
  }
}
