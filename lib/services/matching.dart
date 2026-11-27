import '../models/kundli.dart';
import 'astro.dart';

/// Ashtakoot guna milan, computed from the two real charts.
/// Every guna reads the Moon rashi and Moon nakshatra the
/// engine calculated for each person. No score is fixed.
/// Total is out of 36: Varna 1, Vashya 2, Tara 3, Yoni 4,
/// Graha Maitri 5, Gana 6, Bhakoot 7, Nadi 8.
///
/// shortcut: Yoni scores 4 for the same animal and 2 for a
/// different animal; the friendly and enemy animal refinement
/// is deferred until the owner confirms the table. Graha
/// Maitri and the other gunas use the standard published
/// tables.
class GunaScore {
  const GunaScore({
    required this.label,
    required this.score,
    required this.max,
    required this.note,
  });

  final String label;
  final double score;
  final double max;
  final String note;
}

class MatchingResult {
  const MatchingResult({
    required this.total,
    required this.rows,
    required this.verdict,
    required this.mangalFirst,
    required this.mangalSecond,
  });

  static const double maxTotal = 36;

  final double total;
  final List<GunaScore> rows;
  final String verdict;

  /// True when Mars sits in bhava 1, 2, 4, 7, 8 or 12 in the
  /// lagna chart or the Moon chart.
  final bool mangalFirst;
  final bool mangalSecond;

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

/// Vashya pairs: each pair rules the other.
const List<Set<String>> _vashyaPairs = <Set<String>>[
  <String>{'Mesha', 'Simha'},
  <String>{'Vrishabha', 'Karka'},
  <String>{'Mithuna', 'Kanya'},
  <String>{'Tula', 'Vrishchika'},
  <String>{'Dhanu', 'Meena'},
  <String>{'Makara', 'Kumbha'},
];

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

int _bhavaOf(KundliResult kundli, String planet) {
  for (final PlanetDetail p in kundli.planets) {
    if (p.name == planet) {
      return int.tryParse(p.bhava.replaceAll('Bhava ', '')) ?? 0;
    }
  }
  return 0;
}

bool _hasMangalDosha(KundliResult kundli) {
  const Set<int> doshaBhavas = <int>{1, 2, 4, 7, 8, 12};
  if (doshaBhavas.contains(_bhavaOf(kundli, 'Mars'))) return true;
  return doshaBhavas.contains(_bhavaOf(kundli.moonChart, 'Mars'));
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

class MatchingCalculator {
  MatchingCalculator._();

  static MatchingResult calculate({
    required KundliResult first,
    required KundliResult second,
  }) {
    final List<GunaScore> rows = <GunaScore>[];

    final int firstVarna = _varnaRank[first.moonRashi] ?? 1;
    final int secondVarna = _varnaRank[second.moonRashi] ?? 1;
    final double varna = firstVarna >= secondVarna ? 1 : 0;
    rows.add(GunaScore(
      label: 'Varna',
      score: varna,
      max: 1,
      note: 'Moon rashi ${first.moonRashi} and ${second.moonRashi}.',
    ));

    final bool vashya = _vashyaPairs.any(
      (Set<String> pair) =>
          pair.contains(first.moonRashi) &&
          pair.contains(second.moonRashi),
    );
    rows.add(GunaScore(
      label: 'Vashya',
      score: vashya ? 2 : 0,
      max: 2,
      note: vashya ? 'The rashis rule each other.' : 'No vashya bond.',
    ));

    final int firstNak = kNakshatras.indexOf(first.moonNakshatra);
    final int secondNak = kNakshatras.indexOf(second.moonNakshatra);
    final int count = ((firstNak - secondNak) % 27) + 1;
    final int tara = count % 9 == 0 ? 9 : count % 9;
    final double taraScore =
        tara == 3 || tara == 5 || tara == 7 ? 3 : tara == 9 ? 0 : 1.5;
    rows.add(GunaScore(
      label: 'Tara',
      score: taraScore,
      max: 3,
      note: 'Tara $tara from the second nakshatra.',
    ));

    final String firstYoni =
        firstNak < 0 ? '' : _yoniAnimal[firstNak];
    final String secondYoni =
        secondNak < 0 ? '' : _yoniAnimal[secondNak];
    final double yoni = firstYoni == secondYoni ? 4 : 2;
    rows.add(GunaScore(
      label: 'Yoni',
      score: yoni,
      max: 4,
      note: '$firstYoni and $secondYoni.',
    ));

    final String firstLord =
        kRashiLords[kRashis.indexOf(first.moonRashi)];
    final String secondLord =
        kRashiLords[kRashis.indexOf(second.moonRashi)];
    final bool firstFriend = _friends[firstLord]?.contains(secondLord) ?? false;
    final bool secondFriend =
        _friends[secondLord]?.contains(firstLord) ?? false;
    final bool firstEnemy = _enemies[firstLord]?.contains(secondLord) ?? false;
    final bool secondEnemy =
        _enemies[secondLord]?.contains(firstLord) ?? false;
    final double maitri = firstFriend && secondFriend
        ? 5
        : firstFriend || secondFriend
            ? firstEnemy || secondEnemy
                ? 2
                : 4
            : firstEnemy && secondEnemy
                ? 0
                : firstEnemy || secondEnemy
                    ? 1
                    : 3;
    rows.add(GunaScore(
      label: 'Graha Maitri',
      score: maitri,
      max: 5,
      note: 'Moon lords $firstLord and $secondLord.',
    ));

    final String firstGana = firstNak < 0 ? '' : _gana[firstNak];
    final String secondGana = secondNak < 0 ? '' : _gana[secondNak];
    final double gana = firstGana == secondGana
        ? 6
        : firstGana == 'Deva' && secondGana == 'Manushya' ||
                firstGana == 'Manushya' && secondGana == 'Deva'
            ? 5
            : 0;
    rows.add(GunaScore(
      label: 'Gana',
      score: gana,
      max: 6,
      note: '$firstGana and $secondGana.',
    ));

    final int firstSign = kRashis.indexOf(first.moonRashi);
    final int secondSign = kRashis.indexOf(second.moonRashi);
    final int position = ((secondSign - firstSign) % 12) + 1;
    final double bhakoot =
        position == 2 || position == 3 || position == 4 || position == 10 ||
                position == 11 || position == 12
            ? 7
            : 0;
    rows.add(GunaScore(
      label: 'Bhakoot',
      score: bhakoot,
      max: 7,
      note: 'Moon signs $position apart.',
    ));

    final String firstNadi = firstNak < 0 ? '' : _nadi[firstNak];
    final String secondNadi = secondNak < 0 ? '' : _nadi[secondNak];
    rows.add(GunaScore(
      label: 'Nadi',
      score: firstNadi == secondNadi ? 0 : 8,
      max: 8,
      note: '$firstNadi and $secondNadi.',
    ));

    final double total =
        rows.fold<double>(0, (double sum, GunaScore r) => sum + r.score);
    final String verdict = total >= 28
        ? 'Very Good Match'
        : total >= 18
            ? 'Average Match'
            : 'Low Match';
    return MatchingResult(
      total: total,
      rows: rows,
      verdict: verdict,
      mangalFirst: _hasMangalDosha(first),
      mangalSecond: _hasMangalDosha(second),
    );
  }
}

/// "27.5 / 36" for a guna row, whole numbers without the .0.
String gunaScoreText(GunaScore row) => _scoreText(row.score, row.max);
