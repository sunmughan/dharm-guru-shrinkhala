import '../models/kundli.dart';
import 'astro.dart';
import 'library_content.dart';

/// Phase 6 strengths: Shadbala (simplified), Ashtakavarga
/// and Bhava Bala, all computed from the real chart.
///
/// Shadbala here is a simplified three part strength, and
/// it is labelled as such everywhere it is shown: the full
/// classical Shadbala has six balas with sub parts (Sthana
/// Bala alone has five), and this module does not claim to
/// be that. What it does compute, from the real positions:
/// Sthana (own, exalted, friendly, neutral, enemy,
/// debilitated), Dig Bala (directional house), and Kaala
/// Bala (day or night birth). Each part is 0 to 100, the
/// total is 0 to 300.
///
/// Ashtakavarga is the full classical system: the bindu
/// tables of Brihat Jataka IX.1-7, with the lagna as the
/// eighth contributor. The per planet totals are fixed
/// (Sun 48, Moon 49, Mars 39, Mercury 54, Jupiter 56,
/// Venus 52, Saturn 39) and the sarvashtakavarga always
/// totals 337; the test asserts all eight numbers, so a
/// wrong table cannot pass silently.
///
/// Bhava Bala scores each house from its lord strength and
/// the planets sitting in it. It is a simplified reading
/// aid, labelled as such.

/// English rashi names to the names the engine uses.
const Map<String, String> kEnglishRashis = <String, String>{
  'Aries': 'Mesha',
  'Taurus': 'Vrishabha',
  'Gemini': 'Mithuna',
  'Cancer': 'Karka',
  'Leo': 'Simha',
  'Virgo': 'Kanya',
  'Libra': 'Tula',
  'Scorpio': 'Vrishchika',
  'Sagittarius': 'Dhanu',
  'Capricorn': 'Makara',
  'Aquarius': 'Kumbha',
  'Pisces': 'Meena',
};

/// Natural friends of each planet.
const Map<String, Set<String>> kPlanetFriends = <String, Set<String>>{
  'Sun': <String>{'Moon', 'Mars', 'Jupiter'},
  'Moon': <String>{'Sun', 'Mercury'},
  'Mars': <String>{'Sun', 'Moon', 'Jupiter'},
  'Mercury': <String>{'Sun', 'Venus'},
  'Jupiter': <String>{'Sun', 'Moon', 'Mars'},
  'Venus': <String>{'Mercury', 'Saturn'},
  'Saturn': <String>{'Mercury', 'Venus'},
};

/// Natural enemies of each planet.
const Map<String, Set<String>> kPlanetEnemies = <String, Set<String>>{
  'Sun': <String>{'Venus', 'Saturn'},
  'Moon': <String>{},
  'Mars': <String>{'Mercury'},
  'Mercury': <String>{'Moon'},
  'Jupiter': <String>{'Mercury', 'Venus'},
  'Venus': <String>{'Sun', 'Moon'},
  'Saturn': <String>{'Sun', 'Moon', 'Mars'},
};

/// Houses of Dig Bala strength, counted from lagna.
const Map<String, int> kDigBalaHouses = <String, int>{
  'Sun': 10,
  'Mars': 10,
  'Moon': 4,
  'Venus': 4,
  'Mercury': 1,
  'Jupiter': 1,
  'Saturn': 7,
};

/// Planets strong by day and by night, for Kaala Bala.
const Set<String> kDayStrong = <String>{'Sun', 'Mars', 'Saturn'};
const Set<String> kNightStrong = <String>{'Moon', 'Venus', 'Jupiter'};

/// Reference data for one planet, from the library table.
({String exalted, String debilitated, String rules}) _planetRef(
  String name,
) {
  for (final PlanetReference ref in kPlanetReference) {
    if (ref.name == name) {
      return (
        exalted: kEnglishRashis[ref.exalted] ?? ref.exalted,
        debilitated: kEnglishRashis[ref.debilitated] ?? ref.debilitated,
        rules: ref.rules,
      );
    }
  }
  return (exalted: '', debilitated: '', rules: '');
}

/// Sthana Bala score, 0 to 100, for a planet in a sign.
int sthanaBala(String planet, String sign) {
  final ({String exalted, String debilitated, String rules}) ref =
      _planetRef(planet);
  if (sign == ref.exalted) return 100;
  if (sign == ref.debilitated) return 10;
  final List<String> ruled = ref.rules
      .replaceAll(' and ', ', ')
      .split(', ')
      .map((String s) => kEnglishRashis[s.trim()] ?? s.trim())
      .toList();
  if (ruled.contains(sign)) return 80;
  final String lord = kRashiLords[kRashis.indexOf(sign)];
  if (kPlanetFriends[planet]!.contains(lord)) return 60;
  if (kPlanetEnemies[planet]!.contains(lord)) return 30;
  return 50;
}

/// Simplified Shadbala for one planet, 0 to 300.
class ShadbalaResult {
  const ShadbalaResult({
    required this.planet,
    required this.sthana,
    required this.dig,
    required this.kaala,
    required this.total,
    required this.band,
    required this.explanation,
  });

  final String planet;
  final int sthana;
  final int dig;
  final int kaala;
  final int total;

  /// Strong, Moderate or Weak.
  final String band;
  final String explanation;
}

/// Simplified Shadbala for the seven visible planets of a
/// chart. [isDayBirth] is true when the birth fell between
/// 06:00 and 18:00 local time. Rahu and Ketu have no
/// Shadbala and are left out.
List<ShadbalaResult> shadbala(
  KundliResult kundli, {
  required bool isDayBirth,
}) {
  final List<ShadbalaResult> out = <ShadbalaResult>[];
  for (final PlanetDetail planet in kundli.planets) {
    if (planet.name == 'Rahu' || planet.name == 'Ketu') continue;
    final int sthana = sthanaBala(planet.name, planet.rashi);
    final int house =
        int.parse(planet.bhava.replaceAll('Bhava ', ''));
    final int dig =
        house == kDigBalaHouses[planet.name] ? 100 : 50;
    int kaala;
    if (planet.name == 'Mercury') {
      kaala = 80;
    } else if (isDayBirth) {
      kaala = kDayStrong.contains(planet.name) ? 100 : 60;
    } else {
      kaala = kNightStrong.contains(planet.name) ? 100 : 60;
    }
    final int total = sthana + dig + kaala;
    final String band =
        total >= 210 ? 'Strong' : total >= 150 ? 'Moderate' : 'Weak';
    out.add(
      ShadbalaResult(
        planet: planet.name,
        sthana: sthana,
        dig: dig,
        kaala: kaala,
        total: total,
        band: band,
        explanation:
            '${planet.name} in ${planet.rashi}, Bhava $house: Sthana $sthana, '
            'Dig $dig, Kaala $kaala, total $total, $band. '
            'Simplified Shadbala: three parts only, not the full classical six.',
      ),
    );
  }
  return out;
}

/// Ashtakavarga bindu tables, Brihat Jataka IX.1-7. For a
/// subject planet, each contributor gives a bindu in the
/// listed houses counted from the contributor own sign.
/// The lagna is the eighth contributor. The totals are
/// fixed: Sun 48, Moon 49, Mars 39, Mercury 54, Jupiter
/// 56, Venus 52, Saturn 39, 337 in all.
const Map<String, Map<String, List<int>>> kAshtakavargaTables =
    <String, Map<String, List<int>>>{
  'Sun': <String, List<int>>{
    'Sun': <int>[1, 2, 4, 7, 8, 9, 10, 11],
    'Moon': <int>[3, 6, 10, 11],
    'Mars': <int>[1, 2, 4, 7, 8, 9, 10, 11],
    'Mercury': <int>[3, 5, 6, 9, 10, 11, 12],
    'Jupiter': <int>[5, 6, 9, 11],
    'Venus': <int>[6, 7, 12],
    'Saturn': <int>[1, 2, 4, 7, 8, 9, 10, 11],
    'Lagna': <int>[3, 4, 6, 10, 11, 12],
  },
  'Moon': <String, List<int>>{
    'Sun': <int>[3, 6, 7, 8, 10, 11],
    'Moon': <int>[1, 3, 6, 7, 10, 11],
    'Mars': <int>[2, 3, 5, 6, 9, 10, 11],
    'Mercury': <int>[1, 3, 4, 5, 7, 8, 10, 11],
    'Jupiter': <int>[1, 4, 7, 8, 10, 11, 12],
    'Venus': <int>[3, 4, 5, 7, 9, 10, 11],
    'Saturn': <int>[3, 5, 6, 11],
    'Lagna': <int>[3, 6, 10, 11],
  },
  'Mars': <String, List<int>>{
    'Sun': <int>[3, 5, 6, 10, 11],
    'Moon': <int>[3, 6, 11],
    'Mars': <int>[1, 2, 4, 7, 8, 10, 11],
    'Mercury': <int>[3, 5, 6, 11],
    'Jupiter': <int>[6, 10, 11, 12],
    'Venus': <int>[6, 8, 11, 12],
    'Saturn': <int>[1, 4, 7, 8, 9, 10, 11],
    'Lagna': <int>[1, 3, 6, 10, 11],
  },
  'Mercury': <String, List<int>>{
    'Sun': <int>[5, 6, 9, 11, 12],
    'Moon': <int>[2, 4, 6, 8, 10, 11],
    'Mars': <int>[1, 2, 4, 7, 8, 9, 10, 11],
    'Mercury': <int>[1, 3, 5, 6, 9, 10, 11, 12],
    'Jupiter': <int>[6, 8, 11, 12],
    'Venus': <int>[1, 2, 3, 4, 5, 8, 9, 11],
    'Saturn': <int>[1, 2, 4, 7, 8, 9, 10, 11],
    'Lagna': <int>[1, 2, 4, 6, 8, 10, 11],
  },
  'Jupiter': <String, List<int>>{
    'Sun': <int>[1, 2, 3, 4, 7, 8, 9, 10, 11],
    'Moon': <int>[2, 5, 7, 9, 11],
    'Mars': <int>[1, 2, 4, 7, 8, 10, 11],
    'Mercury': <int>[1, 2, 4, 5, 6, 9, 10, 11],
    'Jupiter': <int>[1, 2, 3, 4, 7, 8, 10, 11],
    'Venus': <int>[2, 5, 6, 9, 10, 11],
    'Saturn': <int>[3, 5, 6, 12],
    'Lagna': <int>[1, 2, 4, 5, 6, 7, 9, 10, 11],
  },
  'Venus': <String, List<int>>{
    'Sun': <int>[8, 11, 12],
    'Moon': <int>[1, 2, 3, 4, 5, 8, 9, 11, 12],
    'Mars': <int>[3, 5, 6, 9, 11, 12],
    'Mercury': <int>[3, 5, 6, 9, 11],
    'Jupiter': <int>[5, 8, 9, 10, 11],
    'Venus': <int>[1, 2, 3, 4, 5, 8, 9, 10, 11],
    'Saturn': <int>[3, 4, 5, 8, 9, 10, 11],
    'Lagna': <int>[1, 2, 3, 4, 5, 8, 9, 11],
  },
  'Saturn': <String, List<int>>{
    'Sun': <int>[1, 2, 4, 7, 8, 10, 11],
    'Moon': <int>[3, 6, 11],
    'Mars': <int>[3, 5, 6, 10, 11, 12],
    'Mercury': <int>[6, 8, 9, 10, 11, 12],
    'Jupiter': <int>[5, 6, 11, 12],
    'Venus': <int>[6, 11, 12],
    'Saturn': <int>[3, 5, 6, 11],
    'Lagna': <int>[1, 3, 4, 6, 10, 11],
  },
};

/// Fixed totals of each Ashtakavarga table.
const Map<String, int> kAshtakavargaTotals = <String, int>{
  'Sun': 48,
  'Moon': 49,
  'Mars': 39,
  'Mercury': 54,
  'Jupiter': 56,
  'Venus': 52,
  'Saturn': 39,
};

/// Ashtakavarga result for a chart: bindus per sign for
/// each subject planet, the sarvashtakavarga per sign, and
/// the per planet totals.
class AshtakavargaResult {
  const AshtakavargaResult({
    required this.bindus,
    required this.sarva,
    required this.totals,
  });

  /// Subject planet to 12 bindu counts, Mesha first.
  final Map<String, List<int>> bindus;

  /// Sarvashtakavarga: the 12 sign totals, Mesha first.
  final List<int> sarva;

  /// Subject planet to its fixed total.
  final Map<String, int> totals;
}

/// Ashtakavarga for a chart.
AshtakavargaResult ashtakavarga(KundliResult kundli) {
  final Map<String, int> signs = <String, int>{
    for (final PlanetDetail p in kundli.planets)
      p.name: kRashis.indexOf(p.rashi),
    'Lagna': kRashis.indexOf(kundli.lagna),
  };
  final Map<String, List<int>> bindus = <String, List<int>>{};
  final Map<String, int> totals = <String, int>{};
  final List<int> sarva = List<int>.filled(12, 0);
  for (final MapEntry<String, Map<String, List<int>>> subject
      in kAshtakavargaTables.entries) {
    final List<int> counts = List<int>.filled(12, 0);
    for (int sign = 0; sign < 12; sign++) {
      for (final MapEntry<String, List<int>> contributor
          in subject.value.entries) {
        final int from = signs[contributor.key]!;
        final int house = ((sign - from) % 12 + 12) % 12 + 1;
        if (contributor.value.contains(house)) counts[sign] += 1;
      }
    }
    bindus[subject.key] = counts;
    totals[subject.key] =
        counts.fold(0, (int a, int b) => a + b);
    for (int sign = 0; sign < 12; sign++) {
      sarva[sign] += counts[sign];
    }
  }
  return AshtakavargaResult(
    bindus: bindus,
    sarva: sarva,
    totals: totals,
  );
}

/// Bhava Bala for one house: lord strength plus occupancy.
class BhavaBalaResult {
  const BhavaBalaResult({
    required this.house,
    required this.sign,
    required this.lord,
    required this.score,
    required this.band,
    required this.explanation,
  });

  final int house;
  final String sign;
  final String lord;
  final int score;
  final String band;
  final String explanation;
}

/// Bhava Bala for all 12 houses of a chart. Simplified:
/// the lord Sthana Bala plus 10 points per planet sitting
/// in the house. Labelled as a simplified reading aid.
List<BhavaBalaResult> bhavaBala(KundliResult kundli) {
  final int lagnaIndex = kRashis.indexOf(kundli.lagna);
  final List<BhavaBalaResult> out = <BhavaBalaResult>[];
  for (int house = 1; house <= 12; house++) {
    final int signIndex = (lagnaIndex + house - 1) % 12;
    final String sign = kRashis[signIndex];
    final String lord = kRashiLords[signIndex];
    final int lordStrength = sthanaBala(lord, sign);
    final int occupants = kundli.planets
        .where((PlanetDetail p) => p.rashi == sign)
        .length;
    final int score = lordStrength + occupants * 10;
    final String band =
        score >= 90 ? 'Strong' : score >= 60 ? 'Moderate' : 'Weak';
    out.add(
      BhavaBalaResult(
        house: house,
        sign: sign,
        lord: lord,
        score: score,
        band: band,
        explanation:
            'Bhava $house ($sign), lord $lord: lord Sthana $lordStrength plus '
            '$occupants planet(s) in the house, total $score, $band. '
            'Simplified Bhava Bala.',
      ),
    );
  }
  return out;
}
