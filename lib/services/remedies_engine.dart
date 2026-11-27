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

  /// Detailed remedy for one planet, from the reviewed
  /// traditional dataset below. [reason] is the computed
  /// rule that selected this planet, so the card is
  /// traceable to the chart, never generated.
  static PlanetRemedyDetail detailedForPlanet({
    required String planet,
    required String reason,
  }) {
    final PlanetRemedyDetail detail = kPlanetRemedyDetails[planet] ??
        PlanetRemedyDetail(
          planet: planet,
          mantra: 'Om Namah Shivaya',
          mantraCount: 11,
          gemstone: '',
          rudraksha: '',
          donation: '',
          donationDay: '',
          fastingDay: '',
          fastingRule: '',
          ritual: kPlanetRemedy[planet] ?? '',
        );
    return PlanetRemedyDetail(
      planet: detail.planet,
      mantra: detail.mantra,
      mantraCount: detail.mantraCount,
      gemstone: detail.gemstone,
      rudraksha: detail.rudraksha,
      donation: detail.donation,
      donationDay: detail.donationDay,
      fastingDay: detail.fastingDay,
      fastingRule: detail.fastingRule,
      ritual: detail.ritual,
      reason: reason,
    );
  }

  /// Detailed remedies for this kundli: one per weak
  /// planet, then the current Mahadasha lord when it is
  /// not already listed. Same selection as [derive], so
  /// the Mahadasha link from release 10 is kept.
  static List<PlanetRemedyDetail> detailedRemedies({
    required KundliResult kundli,
    required DateTime birthLocal,
    required DateTime asOf,
  }) {
    final List<PlanetRemedyDetail> details = <PlanetRemedyDetail>[];
    final List<WeakPlanet> weak = weakPlanets(kundli);
    for (final WeakPlanet planet in weak) {
      details.add(detailedForPlanet(
        planet: planet.name,
        reason: '${planet.name} is weak: ${planet.reason}.',
      ));
    }
    final DashaInfo dasha = vimshottariDasha(
      birthLocal: birthLocal,
      asOf: asOf,
    );
    if (!weak.any((WeakPlanet w) => w.name == dasha.lord)) {
      details.add(detailedForPlanet(
        planet: dasha.lord,
        reason: 'Current Mahadasha lord, running from '
            '${_formatDay(dasha.start)} to ${_formatDay(dasha.end)}.',
      ));
    }
    return details;
  }
}

/// One planet remedy, every field from the traditional
/// dataset in [kPlanetRemedyDetails]. Gemstones are
/// listed for reference only: the detail carries the
/// note to confirm with an astrologer before wearing
/// any stone, and no stone is ever prescribed by the
/// app on its own.
class PlanetRemedyDetail {
  const PlanetRemedyDetail({
    required this.planet,
    required this.mantra,
    required this.mantraCount,
    required this.gemstone,
    required this.rudraksha,
    required this.donation,
    required this.donationDay,
    required this.fastingDay,
    required this.fastingRule,
    required this.ritual,
    this.reason = '',
  });

  final String planet;
  final String mantra;
  final int mantraCount;
  final String gemstone;
  final String rudraksha;
  final String donation;
  final String donationDay;
  final String fastingDay;
  final String fastingRule;
  final String ritual;

  /// Computed rule that selected this planet.
  final String reason;

  static const String gemstoneNote =
      'Confirm with an astrologer before wearing any gemstone.';
}

/// Reviewed traditional remedy dataset, one entry per
/// planet. Mantras, stones, rudraksha, donations and
/// fast days are the standard published upay for each
/// planet. Nothing here is generated per user.
const Map<String, PlanetRemedyDetail> kPlanetRemedyDetails =
    <String, PlanetRemedyDetail>{
  'Sun': PlanetRemedyDetail(
    planet: 'Sun',
    mantra: 'Om Suryaya Namah',
    mantraCount: 11,
    gemstone: 'Ruby',
    rudraksha: '1 Mukhi Rudraksha',
    donation: 'Wheat and jaggery',
    donationDay: 'Sunday',
    fastingDay: 'Sunday',
    fastingRule: 'Fast on Sunday till sunset, then eat simple food.',
    ritual: 'Offer water to the rising Sun each morning.',
  ),
  'Moon': PlanetRemedyDetail(
    planet: 'Moon',
    mantra: 'Om Chandraya Namah',
    mantraCount: 11,
    gemstone: 'Pearl',
    rudraksha: '2 Mukhi Rudraksha',
    donation: 'Rice and milk',
    donationDay: 'Monday',
    fastingDay: 'Monday',
    fastingRule: 'Fast on Monday till evening, then eat simple food.',
    ritual: 'Offer water to the Moon on Monday evenings.',
  ),
  'Mars': PlanetRemedyDetail(
    planet: 'Mars',
    mantra: 'Om Angarakaya Namah',
    mantraCount: 11,
    gemstone: 'Red Coral',
    rudraksha: '3 Mukhi Rudraksha',
    donation: 'Red lentils and jaggery',
    donationDay: 'Tuesday',
    fastingDay: 'Tuesday',
    fastingRule: 'Fast on Tuesday till sunset, then eat simple food.',
    ritual: 'Offer red flowers to Hanuman on Tuesday.',
  ),
  'Mercury': PlanetRemedyDetail(
    planet: 'Mercury',
    mantra: 'Om Budhaya Namah',
    mantraCount: 11,
    gemstone: 'Emerald',
    rudraksha: '4 Mukhi Rudraksha',
    donation: 'Green moong dal',
    donationDay: 'Wednesday',
    fastingDay: 'Wednesday',
    fastingRule: 'Fast on Wednesday till sunset, then eat simple food.',
    ritual: 'Feed green fodder to a cow on Wednesday.',
  ),
  'Jupiter': PlanetRemedyDetail(
    planet: 'Jupiter',
    mantra: 'Om Gurave Namah',
    mantraCount: 11,
    gemstone: 'Yellow Sapphire',
    rudraksha: '5 Mukhi Rudraksha',
    donation: 'Chana dal and turmeric',
    donationDay: 'Thursday',
    fastingDay: 'Thursday',
    fastingRule: 'Fast on Thursday till sunset, then eat simple food.',
    ritual: 'Offer yellow flowers at a temple on Thursday.',
  ),
  'Venus': PlanetRemedyDetail(
    planet: 'Venus',
    mantra: 'Om Shukraya Namah',
    mantraCount: 11,
    gemstone: 'Diamond or Opal',
    rudraksha: '6 Mukhi Rudraksha',
    donation: 'Rice and sugar',
    donationDay: 'Friday',
    fastingDay: 'Friday',
    fastingRule: 'Fast on Friday till sunset, then eat simple food.',
    ritual: 'Offer white flowers on Friday.',
  ),
  'Saturn': PlanetRemedyDetail(
    planet: 'Saturn',
    mantra: 'Om Shanicharaya Namah',
    mantraCount: 11,
    gemstone: 'Blue Sapphire',
    rudraksha: '7 Mukhi Rudraksha',
    donation: 'Black urad dal and sesame',
    donationDay: 'Saturday',
    fastingDay: 'Saturday',
    fastingRule: 'Fast on Saturday till sunset, then eat simple food.',
    ritual: 'Light a mustard oil diya under a peepal tree on Saturday evening.',
  ),
  'Rahu': PlanetRemedyDetail(
    planet: 'Rahu',
    mantra: 'Om Rahave Namah',
    mantraCount: 11,
    gemstone: 'Hessonite',
    rudraksha: '8 Mukhi Rudraksha',
    donation: 'Black sesame and blankets',
    donationDay: 'Saturday',
    fastingDay: 'Saturday',
    fastingRule: 'Fast on Saturday till sunset, then eat simple food.',
    ritual: 'Chant the Rahu mantra and avoid sudden money decisions.',
  ),
  'Ketu': PlanetRemedyDetail(
    planet: 'Ketu',
    mantra: 'Om Ketave Namah',
    mantraCount: 11,
    gemstone: 'Cats Eye',
    rudraksha: '9 Mukhi Rudraksha',
    donation: 'Sesame and blankets',
    donationDay: 'Tuesday',
    fastingDay: 'Tuesday',
    fastingRule: 'Fast on Tuesday till sunset, then eat simple food.',
    ritual: 'Spend quiet time in prayer each morning.',
  ),
};
