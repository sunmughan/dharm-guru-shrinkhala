import '../models/kundli.dart';
import 'astro.dart';

/// Ashtakoot guna milan, computed from the two real charts.
/// Every guna reads the Moon rashi and Moon nakshatra the
/// engine calculated for each person. No score is fixed.
/// Total is out of 36: Varna 1, Vashya 2, Tara 3, Yoni 4,
/// Graha Maitri 5, Gana 6, Bhakoot 7, Nadi 8.
///
/// Rules are the published North Indian tables, checked
/// against Muhurta Chintamani and the standard summaries:
/// Tara is counted both ways, 1.5 points per direction
/// that avoids Tara 3, 5 and 7. Bhakoot scores 0 only on
/// 2/12, 5/9 and 6/8, and 7 on every other spacing. Yoni
/// uses the five tier animal table, same 4, friend 3,
/// neutral 2, mild enemy 1, bitter enemy 0. Gana gives
/// Deva with Rakshasa 1 and Manushya with Rakshasa 0.
/// Graha Maitri gives same lord 5, friend with enemy 1
/// and neutral with enemy 0.5. Vashya uses the five
/// group matrix, girl group as row and boy group as
/// column. A dosha exception clears the dosha flag in
/// the note, it never adds points back, so every score
/// stays reproducible from the rule named in its row.
///
/// Release 10 had Tara and Bhakoot backwards and Yoni
/// simplified to same 4 else 2, so totals from release 10
/// change here. The proof pair is reprinted by the proof
/// test, not locked to the old wrong total.
///
/// shortcut: Dhanu and Makara are split Vashya groups at
/// 15 degrees of Moon longitude inside the rashi. The
/// Moon degree is read from the Moon planet detail, and
/// when a hand built chart has no Moon planet the first
/// half is used. Pada is not stored on KundliResult, so
/// the same nakshatra different pada Nadi exception is
/// not applied, it is named in the Nadi note instead.
class GunaScore {
  const GunaScore({
    required this.label,
    required this.score,
    required this.max,
    required this.note,
    this.rule = '',
    this.isDosha = false,
    this.exception = '',
  });

  final String label;
  final double score;
  final double max;
  final String note;

  /// The rule that produced this score, so the score can
  /// be checked on paper from the two charts.
  final String rule;

  /// True when this row is a dosha in the tradition, after
  /// any exception in [exception] is applied.
  final bool isDosha;

  /// The cancellation rule that cleared a dosha, or empty.
  final String exception;
}

/// Tradition settings for matching. The default is the
/// North Indian reading used by the app. Strict turns
/// every dosha exception off. South Indian practice
/// counts the 2nd bhava for Mangal Dosha, so the default
/// keeps it, matching release 10.
class MatchingTradition {
  const MatchingTradition({
    this.applyNadiException = true,
    this.applyBhakootException = true,
    this.applyGanaException = true,
    this.includeSecondHouseManglik = true,
  });

  const MatchingTradition.northIndian()
      : applyNadiException = true,
        applyBhakootException = true,
        applyGanaException = true,
        includeSecondHouseManglik = true;

  const MatchingTradition.strict()
      : applyNadiException = false,
        applyBhakootException = false,
        applyGanaException = false,
        includeSecondHouseManglik = true;

  final bool applyNadiException;
  final bool applyBhakootException;
  final bool applyGanaException;
  final bool includeSecondHouseManglik;
}

/// Manglik compatibility for the pair, judged outside
/// the 36 gunas. Raw presence is kept on MatchingResult
/// as before. Effective means present and not cancelled
/// in that chart. Both effective, or neither effective,
/// is compatible. One effective alone is not.
class ManglikCompatibility {
  const ManglikCompatibility({
    required this.firstEffective,
    required this.secondEffective,
    required this.compatible,
    required this.reason,
    required this.cancellations,
  });

  final bool firstEffective;
  final bool secondEffective;
  final bool compatible;
  final String reason;

  /// Cancellation rules found, one line per chart.
  final List<String> cancellations;
}

class MatchingResult {
  const MatchingResult({
    required this.total,
    required this.rows,
    required this.verdict,
    required this.mangalFirst,
    required this.mangalSecond,
    required this.manglik,
  });

  static const double maxTotal = 36;

  final double total;
  final List<GunaScore> rows;
  final String verdict;

  /// True when Mars sits in bhava 1, 2, 4, 7, 8 or 12 in the
  /// lagna chart or the Moon chart, before cancellation.
  final bool mangalFirst;
  final bool mangalSecond;

  /// Manglik compatibility with cancellations applied.
  final ManglikCompatibility manglik;

  /// Rows that are doshas after exceptions, for the report.
  List<GunaScore> get doshas =>
      rows.where((GunaScore r) => r.isDosha).toList();

  String get totalText {
    final String shown = total == total.truncateToDouble()
        ? total.toInt().toString()
        : total.toString();
    return '$shown / ${maxTotal.toInt()}';
  }
}

/// Varna rank by Moon rashi: Brahmin 4, Kshatriya 3,
/// Vaishya 2, Shudra 1.
const Map<String, int> _varnaRank = <String, int>{
  'Karka': 4,
  'Vrishchika': 4,
  'Meena': 4,
  'Mesha': 3,
  'Simha': 3,
  'Dhanu': 3,
  'Vrishabha': 2,
  'Kanya': 2,
  'Makara': 2,
  'Mithuna': 1,
  'Tula': 1,
  'Kumbha': 1,
};

const Map<int, String> _varnaName = <int, String>{
  4: 'Brahmin',
  3: 'Kshatriya',
  2: 'Vaishya',
  1: 'Shudra',
};

/// Vashya group of each Moon rashi. Dhanu and Makara are
/// split at 15 degrees, handled in _vashyaGroup.
const Map<String, String> _vashyaGroupFixed = <String, String>{
  'Mesha': 'Chatushpada',
  'Vrishabha': 'Chatushpada',
  'Mithuna': 'Manava',
  'Karka': 'Jalachara',
  'Simha': 'Vanachara',
  'Kanya': 'Manava',
  'Tula': 'Manava',
  'Vrishchika': 'Keeta',
  'Kumbha': 'Manava',
  'Meena': 'Jalachara',
};

/// Vashya matrix, girl group as row, boy group as column.
/// Same group 2, Vanachara with any other group 0.
const Map<String, Map<String, double>> _vashyaMatrix =
    <String, Map<String, double>>{
  'Chatushpada': <String, double>{
    'Chatushpada': 2,
    'Manava': 1,
    'Jalachara': 1,
    'Vanachara': 0.5,
    'Keeta': 1,
  },
  'Manava': <String, double>{
    'Chatushpada': 1,
    'Manava': 2,
    'Jalachara': 0.5,
    'Vanachara': 0,
    'Keeta': 1,
  },
  'Jalachara': <String, double>{
    'Chatushpada': 1,
    'Manava': 0.5,
    'Jalachara': 2,
    'Vanachara': 1,
    'Keeta': 1,
  },
  'Vanachara': <String, double>{
    'Chatushpada': 0,
    'Manava': 0,
    'Jalachara': 0,
    'Vanachara': 2,
    'Keeta': 0,
  },
  'Keeta': <String, double>{
    'Chatushpada': 1,
    'Manava': 1,
    'Jalachara': 1,
    'Vanachara': 0,
    'Keeta': 2,
  },
};

/// Yoni animal by nakshatra, in kNakshatras order.
const List<String> _yoniAnimal = <String>[
  'Horse', // Ashwini
  'Elephant', // Bharani
  'Goat', // Krittika
  'Serpent', // Rohini
  'Serpent', // Mrigashira
  'Dog', // Ardra
  'Cat', // Punarvasu
  'Goat', // Pushya
  'Cat', // Ashlesha
  'Rat', // Magha
  'Rat', // Purva Phalguni
  'Cow', // Uttara Phalguni
  'Buffalo', // Hasta
  'Tiger', // Chitra
  'Buffalo', // Swati
  'Tiger', // Vishakha
  'Deer', // Anuradha
  'Deer', // Jyeshtha
  'Dog', // Mula
  'Monkey', // Purva Ashadha
  'Mongoose', // Uttara Ashadha
  'Monkey', // Shravana
  'Lion', // Dhanishta
  'Horse', // Shatabhisha
  'Lion', // Purva Bhadrapada
  'Cow', // Uttara Bhadrapada
  'Elephant', // Revati
];

/// Friend animal pairs, 3 points.
const List<Set<String>> _yoniFriends = <Set<String>>[
  <String>{'Horse', 'Elephant'},
  <String>{'Elephant', 'Cow'},
];

/// The one mild enemy pair, 1 point: Serpent with Rat.
const Set<String> _yoniMildEnemy = <String>{'Serpent', 'Rat'};

/// Bitter enemy pairs, Mahavaira, 0 points.
const List<Set<String>> _yoniBitterEnemies = <Set<String>>[
  <String>{'Horse', 'Buffalo'},
  <String>{'Elephant', 'Lion'},
  <String>{'Goat', 'Monkey'},
  <String>{'Serpent', 'Mongoose'},
  <String>{'Dog', 'Deer'},
  <String>{'Cat', 'Rat'},
  <String>{'Cow', 'Tiger'},
];

/// Natural friends of each planet lord.
const Map<String, Set<String>> _friends = <String, Set<String>>{
  'Sun': <String>{'Moon', 'Mars', 'Jupiter'},
  'Moon': <String>{'Sun', 'Mercury'},
  'Mars': <String>{'Sun', 'Moon', 'Jupiter'},
  'Mercury': <String>{'Sun', 'Venus'},
  'Jupiter': <String>{'Sun', 'Moon', 'Mars'},
  'Venus': <String>{'Mercury', 'Saturn'},
  'Saturn': <String>{'Mercury', 'Venus'},
};

/// Natural enemies of each planet lord.
const Map<String, Set<String>> _enemies = <String, Set<String>>{
  'Sun': <String>{'Venus', 'Saturn'},
  'Moon': <String>{},
  'Mars': <String>{'Mercury'},
  'Mercury': <String>{'Moon'},
  'Jupiter': <String>{'Mercury', 'Venus'},
  'Venus': <String>{'Sun', 'Moon'},
  'Saturn': <String>{'Sun', 'Moon', 'Mars'},
};

/// Gana by nakshatra, in kNakshatras order.
const List<String> _gana = <String>[
  'Deva', // Ashwini
  'Manushya', // Bharani
  'Rakshasa', // Krittika
  'Manushya', // Rohini
  'Deva', // Mrigashira
  'Manushya', // Ardra
  'Deva', // Punarvasu
  'Deva', // Pushya
  'Rakshasa', // Ashlesha
  'Rakshasa', // Magha
  'Manushya', // Purva Phalguni
  'Manushya', // Uttara Phalguni
  'Deva', // Hasta
  'Rakshasa', // Chitra
  'Deva', // Swati
  'Rakshasa', // Vishakha
  'Deva', // Anuradha
  'Rakshasa', // Jyeshtha
  'Rakshasa', // Mula
  'Manushya', // Purva Ashadha
  'Manushya', // Uttara Ashadha
  'Deva', // Shravana
  'Rakshasa', // Dhanishta
  'Rakshasa', // Shatabhisha
  'Manushya', // Purva Bhadrapada
  'Manushya', // Uttara Bhadrapada
  'Deva', // Revati
];

/// Nadi by nakshatra, in kNakshatras order.
const List<String> _nadi = <String>[
  'Aadi', // Ashwini
  'Madhya', // Bharani
  'Antya', // Krittika
  'Antya', // Rohini
  'Madhya', // Mrigashira
  'Aadi', // Ardra
  'Aadi', // Punarvasu
  'Madhya', // Pushya
  'Antya', // Ashlesha
  'Antya', // Magha
  'Madhya', // Purva Phalguni
  'Aadi', // Uttara Phalguni
  'Aadi', // Hasta
  'Madhya', // Chitra
  'Antya', // Swati
  'Antya', // Vishakha
  'Madhya', // Anuradha
  'Aadi', // Jyeshtha
  'Aadi', // Mula
  'Madhya', // Purva Ashadha
  'Antya', // Uttara Ashadha
  'Antya', // Shravana
  'Madhya', // Dhanishta
  'Aadi', // Shatabhisha
  'Aadi', // Purva Bhadrapada
  'Madhya', // Uttara Bhadrapada
  'Antya', // Revati
];

/// Tara names by remainder, 1 to 9.
const List<String> _taraNames = <String>[
  'Janma',
  'Sampat',
  'Vipat',
  'Kshema',
  'Pratyak',
  'Sadhaka',
  'Vadha',
  'Mitra',
  'Parama Mitra',
];

int _bhavaOf(KundliResult kundli, String planet) {
  for (final PlanetDetail p in kundli.planets) {
    if (p.name == planet) {
      return int.tryParse(p.bhava.replaceAll('Bhava ', '')) ?? 0;
    }
  }
  return 0;
}

String? _rashiOf(KundliResult kundli, String planet) {
  for (final PlanetDetail p in kundli.planets) {
    if (p.name == planet) return p.rashi;
  }
  return null;
}

/// Moon degrees inside its rashi, from the Moon planet
/// detail text like 10 degrees 24 minutes. Null when the
/// chart has no Moon planet, as in a hand built test chart.
double? _moonDegree(KundliResult kundli) {
  for (final PlanetDetail p in kundli.planets) {
    if (p.name != 'Moon') continue;
    final List<String> bits = p.degree.split('°');
    if (bits.length != 2) return null;
    final double? deg = double.tryParse(bits[0].trim());
    if (deg == null) return null;
    final double? min =
        double.tryParse(bits[1].replaceAll('′', '').trim());
    return deg + (min ?? 0) / 60.0;
  }
  return null;
}

String _vashyaGroup(KundliResult kundli) {
  final String? fixed = _vashyaGroupFixed[kundli.moonRashi];
  if (fixed != null) return fixed;
  final double deg = _moonDegree(kundli) ?? 0;
  if (kundli.moonRashi == 'Dhanu') {
    return deg < 15 ? 'Manava' : 'Chatushpada';
  }
  return deg < 15 ? 'Chatushpada' : 'Jalachara';
}

bool _hasMangalDosha(
  KundliResult kundli,
  MatchingTradition tradition,
) {
  final Set<int> doshaBhavas = tradition.includeSecondHouseManglik
      ? <int>{1, 2, 4, 7, 8, 12}
      : <int>{1, 4, 7, 8, 12};
  if (doshaBhavas.contains(_bhavaOf(kundli, 'Mars'))) return true;
  return doshaBhavas.contains(_bhavaOf(kundli.moonChart, 'Mars'));
}

/// Cancellation rules that can be checked from the chart
/// alone: Mars in its own rashi Mesha or Vrishchika, or
/// exalted in Makara, or Jupiter conjunct Mars or
/// aspecting Mars from the 5th, 7th or 9th rashi.
/// Empty when no rule applies.
String _mangalCancellation(KundliResult kundli) {
  final String? marsRashi = _rashiOf(kundli, 'Mars');
  if (marsRashi == 'Mesha' || marsRashi == 'Vrishchika') {
    return 'Mars in own rashi $marsRashi';
  }
  if (marsRashi == 'Makara') {
    return 'Mars exalted in Makara';
  }
  final String? jupiterRashi = _rashiOf(kundli, 'Jupiter');
  if (marsRashi != null && jupiterRashi == marsRashi) {
    return 'Jupiter conjunct Mars in $marsRashi';
  }
  if (marsRashi != null && jupiterRashi != null) {
    final int marsIndex = kRashis.indexOf(marsRashi);
    final int jupiterIndex = kRashis.indexOf(jupiterRashi);
    final int fromMars =
        ((jupiterIndex - marsIndex) % 12 + 12) % 12 + 1;
    if (fromMars == 5 || fromMars == 7 || fromMars == 9) {
      return 'Jupiter aspects Mars from the $fromMars th rashi';
    }
  }
  return '';
}

String _scoreText(double score, double max) {
  final String shown = score == score.truncateToDouble()
      ? score.toInt().toString()
      : score.toString();
  final String maxShown = max == max.truncateToDouble()
      ? max.toInt().toString()
      : max.toString();
  return '$shown / $maxShown';
}

/// One direction of the Tara count. The count runs
/// inclusive from [from] nakshatra to [to] nakshatra.
({int number, String name, bool good}) _taraOneWay(
  int from,
  int to,
) {
  final int count = ((to - from) % 27) + 1;
  final int number = count % 9 == 0 ? 9 : count % 9;
  return (
    number: number,
    name: _taraNames[number - 1],
    good: number != 3 && number != 5 && number != 7,
  );
}

String _relation(String lordA, String lordB) {
  if (lordA == lordB) return 'same';
  if (_friends[lordA]?.contains(lordB) ?? false) return 'friend';
  if (_enemies[lordA]?.contains(lordB) ?? false) return 'enemy';
  return 'neutral';
}

class MatchingCalculator {
  MatchingCalculator._();

  static MatchingResult calculate({
    required KundliResult first,
    required KundliResult second,
    MatchingTradition tradition = const MatchingTradition(),
  }) {
    final List<GunaScore> rows = <GunaScore>[];

    final int firstVarna = _varnaRank[first.moonRashi] ?? 1;
    final int secondVarna = _varnaRank[second.moonRashi] ?? 1;
    final double varna = firstVarna >= secondVarna ? 1 : 0;
    rows.add(GunaScore(
      label: 'Varna',
      score: varna,
      max: 1,
      note: 'Moon rashi ${first.moonRashi} is '
          '${_varnaName[firstVarna]} and ${second.moonRashi} is '
          '${_varnaName[secondVarna]}.',
      rule: 'First varna equal or higher than second: 1, else 0.',
    ));

    final String firstGroup = _vashyaGroup(first);
    final String secondGroup = _vashyaGroup(second);
    final double vashya =
        _vashyaMatrix[secondGroup]?[firstGroup] ?? 0;
    rows.add(GunaScore(
      label: 'Vashya',
      score: vashya,
      max: 2,
      note: 'Groups $firstGroup and $secondGroup.',
      rule: 'Vashya matrix, girl group as row, boy group as column.',
    ));

    final int firstNak = kNakshatras.indexOf(first.moonNakshatra);
    final int secondNak = kNakshatras.indexOf(second.moonNakshatra);
    final ({int number, String name, bool good}) taraA =
        _taraOneWay(secondNak, firstNak);
    final ({int number, String name, bool good}) taraB =
        _taraOneWay(firstNak, secondNak);
    final double taraScore =
        (taraA.good ? 1.5 : 0) + (taraB.good ? 1.5 : 0);
    rows.add(GunaScore(
      label: 'Tara',
      score: taraScore,
      max: 3,
      note: 'Tara ${taraA.number} ${taraA.name} one way and '
          'Tara ${taraB.number} ${taraB.name} the other way.',
      rule: '1.5 per direction that avoids Tara 3, 5 and 7.',
    ));

    final String firstYoni =
        firstNak < 0 ? '' : _yoniAnimal[firstNak];
    final String secondYoni =
        secondNak < 0 ? '' : _yoniAnimal[secondNak];
    final Set<String> yoniPair = <String>{firstYoni, secondYoni};
    final double yoni = firstYoni == secondYoni
        ? 4
        : _yoniFriends.any(
              (Set<String> pair) =>
                  pair.length == yoniPair.length &&
                  pair.containsAll(yoniPair),
            )
            ? 3
            : _yoniBitterEnemies.any(
                  (Set<String> pair) =>
                      pair.length == yoniPair.length &&
                      pair.containsAll(yoniPair),
                )
                ? 0
                : yoniPair.length == _yoniMildEnemy.length &&
                        yoniPair.containsAll(_yoniMildEnemy)
                    ? 1
                    : 2;
    final String yoniTier = yoni == 4
        ? 'same animal'
        : yoni == 3
            ? 'friend animals'
            : yoni == 0
                ? 'bitter enemy animals'
                : yoni == 1
                    ? 'mild enemy animals'
                    : 'neutral animals';
    rows.add(GunaScore(
      label: 'Yoni',
      score: yoni,
      max: 4,
      note: '$firstYoni and $secondYoni, $yoniTier.',
      rule: 'Same 4, friend 3, neutral 2, mild enemy 1, '
          'bitter enemy 0.',
    ));

    final String firstLord =
        kRashiLords[kRashis.indexOf(first.moonRashi)];
    final String secondLord =
        kRashiLords[kRashis.indexOf(second.moonRashi)];
    final String relA = _relation(firstLord, secondLord);
    final String relB = _relation(secondLord, firstLord);
    final double maitri = relA == 'same'
        ? 5
        : relA == 'friend' && relB == 'friend'
            ? 5
            : relA == 'friend' && relB == 'neutral' ||
                    relA == 'neutral' && relB == 'friend'
                ? 4
                : relA == 'neutral' && relB == 'neutral'
                    ? 3
                    : relA == 'friend' && relB == 'enemy' ||
                            relA == 'enemy' && relB == 'friend'
                        ? 1
                        : relA == 'neutral' && relB == 'enemy' ||
                                relA == 'enemy' && relB == 'neutral'
                            ? 0.5
                            : 0;
    rows.add(GunaScore(
      label: 'Graha Maitri',
      score: maitri,
      max: 5,
      note: 'Moon lords $firstLord and $secondLord, '
          '$relA one way and $relB the other way.',
      rule: 'Same or mutual friend 5, friend with neutral 4, '
          'both neutral 3, friend with enemy 1, neutral with '
          'enemy 0.5, mutual enemy 0.',
    ));

    final String firstGana = firstNak < 0 ? '' : _gana[firstNak];
    final String secondGana = secondNak < 0 ? '' : _gana[secondNak];
    final double gana = firstGana == secondGana
        ? 6
        : firstGana == 'Deva' && secondGana == 'Manushya' ||
                firstGana == 'Manushya' && secondGana == 'Deva'
            ? 5
            : firstGana == 'Deva' && secondGana == 'Rakshasa' ||
                    firstGana == 'Rakshasa' && secondGana == 'Deva'
                ? 1
                : 0;
    final bool lordsFriendly =
        _friends[firstLord]?.contains(secondLord) ?? false;
    final bool lordsMutualFriendly =
        lordsFriendly && (_friends[secondLord]?.contains(firstLord) ?? false);
    final String ganaException =
        tradition.applyGanaException && gana <= 1 && lordsMutualFriendly
            ? 'Gana dosha cleared: Moon lords $firstLord and '
                '$secondLord are mutual friends.'
            : '';
    rows.add(GunaScore(
      label: 'Gana',
      score: gana,
      max: 6,
      note: '$firstGana and $secondGana.',
      rule: 'Same 6, Deva with Manushya 5, Deva with '
          'Rakshasa 1, Manushya with Rakshasa 0.',
      isDosha: gana <= 1 && ganaException.isEmpty,
      exception: ganaException,
    ));

    final int firstSign = kRashis.indexOf(first.moonRashi);
    final int secondSign = kRashis.indexOf(second.moonRashi);
    final int position = ((secondSign - firstSign) % 12) + 1;
    final bool bhakootDosha = position == 2 ||
        position == 5 ||
        position == 6 ||
        position == 8 ||
        position == 9 ||
        position == 12;
    final double bhakoot = bhakootDosha ? 0 : 7;
    final String firstNadi = firstNak < 0 ? '' : _nadi[firstNak];
    final String secondNadi = secondNak < 0 ? '' : _nadi[secondNak];
    final bool nadiPure = firstNadi != secondNadi;
    final String bhakootException =
        tradition.applyBhakootException && bhakootDosha && nadiPure &&
                (firstLord == secondLord || lordsMutualFriendly)
            ? 'Bhakoot dosha cleared: ${firstLord == secondLord ? 'same Moon lord $firstLord' : 'mutual friend Moon lords $firstLord and $secondLord'} and pure Nadi.'
            : '';
    rows.add(GunaScore(
      label: 'Bhakoot',
      score: bhakoot,
      max: 7,
      note: 'Moon signs $position apart, '
          '${bhakootDosha ? '2/12, 5/9 or 6/8 spacing' : 'safe spacing'}.',
      rule: '0 on 2/12, 5/9 and 6/8, 7 on every other spacing.',
      isDosha: bhakootDosha && bhakootException.isEmpty,
      exception: bhakootException,
    ));

    final bool nadiDosha = firstNadi == secondNadi;
    final String nadiException =
        tradition.applyNadiException && nadiDosha &&
                first.moonRashi == second.moonRashi &&
                first.moonNakshatra != second.moonNakshatra
            ? 'Nadi dosha cleared: same Moon rashi ${first.moonRashi} with different nakshatras.'
            : '';
    rows.add(GunaScore(
      label: 'Nadi',
      score: nadiDosha ? 0 : 8,
      max: 8,
      note: '$firstNadi and $secondNadi.'
          '${nadiException.isEmpty && nadiDosha ? ' Same nakshatra different pada is not checked, the chart stores no pada.' : ''}',
      rule: 'Different Nadi 8, same Nadi 0. An exception '
          'clears the dosha flag, it never adds points back.',
      isDosha: nadiDosha && nadiException.isEmpty,
      exception: nadiException,
    ));

    final double total =
        rows.fold<double>(0, (double sum, GunaScore r) => sum + r.score);
    final String verdict = total >= 28
        ? 'Very Good Match'
        : total >= 18
            ? 'Average Match'
            : 'Low Match';
    final bool rawFirst = _hasMangalDosha(first, tradition);
    final bool rawSecond = _hasMangalDosha(second, tradition);
    final String cancelFirst =
        rawFirst ? _mangalCancellation(first) : '';
    final String cancelSecond =
        rawSecond ? _mangalCancellation(second) : '';
    final bool effectiveFirst = rawFirst && cancelFirst.isEmpty;
    final bool effectiveSecond = rawSecond && cancelSecond.isEmpty;
    final bool manglikCompatible =
        effectiveFirst == effectiveSecond;
    final List<String> cancellations = <String>[];
    if (cancelFirst.isNotEmpty) {
      cancellations.add('First: $cancelFirst.');
    }
    if (cancelSecond.isNotEmpty) {
      cancellations.add('Second: $cancelSecond.');
    }
    final String manglikReason = !effectiveFirst && !effectiveSecond
        ? 'Neither chart carries an effective Mangal Dosha.'
        : effectiveFirst && effectiveSecond
            ? 'Both charts carry Mangal Dosha, so it cancels mutually.'
            : 'Only one chart carries an effective Mangal Dosha.';
    return MatchingResult(
      total: total,
      rows: rows,
      verdict: verdict,
      mangalFirst: rawFirst,
      mangalSecond: rawSecond,
      manglik: ManglikCompatibility(
        firstEffective: effectiveFirst,
        secondEffective: effectiveSecond,
        compatible: manglikCompatible,
        reason: manglikReason,
        cancellations: cancellations,
      ),
    );
  }
}

/// "27.5 / 36" for a guna row, whole numbers without the .0.
String gunaScoreText(GunaScore row) => _scoreText(row.score, row.max);
