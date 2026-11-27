import 'astro.dart';
import '../models/kundli.dart';

/// Library content: real computed Vedic reference material.
/// Nothing here is stored text pretending to be an article.
/// Festival days are computed from the Panchang engine, the
/// dasha timeline comes from the real chart, and the planet
/// reference is traditional knowledge paired with the users
/// own computed positions when a profile exists.

/// "2026-11-27" style day shown as "27 November 2026".
String formatDay(DateTime day) {
  const List<String> months = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  return '${day.day} ${months[day.month - 1]} ${day.year}';
}

/// One festival day found by scanning the Panchang engine.
class FestivalDay {
  const FestivalDay({
    required this.date,
    required this.tithi,
    required this.observance,
  });

  final DateTime date;
  final String tithi;
  final String observance;
}

/// Tithi base names worth marking, with the observance line
/// shown for each. The engine tithi carries a Shukla or
/// Krishna prefix; the base name is matched after stripping it.
const Map<String, String> kFestivalTithis = <String, String>{
  'Purnima': 'Full moon day',
  'Amavasya': 'New moon day',
  'Ekadashi': 'Ekadashi fast day',
  'Chaturthi': 'Ganesh Chaturthi',
  'Ashtami': 'Ashtami',
  'Navami': 'Navami',
};

/// Festival days in the next [days] days from [from],
/// computed day by day with the Panchang engine. Dates are
/// ascending and every entry lies inside the window.
List<FestivalDay> festivalDays({
  required DateTime from,
  int days = 30,
  AstroPlace place = kDefaultPlace,
}) {
  final List<FestivalDay> found = <FestivalDay>[];
  final DateTime start = DateTime(from.year, from.month, from.day);
  for (int i = 0; i < days; i++) {
    final DateTime day = start.add(Duration(days: i));
    final String tithi = PanchangCalculator.forDate(day, place).tithi;
    final String base =
        tithi.replaceFirst('Shukla ', '').replaceFirst('Krishna ', '');
    final String? observance = kFestivalTithis[base];
    if (observance != null) {
      found.add(
        FestivalDay(date: day, tithi: tithi, observance: observance),
      );
    }
  }
  return found;
}

/// Traditional reference for one planet: the sign it rules,
/// where it is exalted and debilitated, and what it signifies.
/// Rahu and Ketu rule no sign of their own.
class PlanetReference {
  const PlanetReference({
    required this.name,
    required this.rules,
    required this.exalted,
    required this.debilitated,
    required this.signifies,
  });

  final String name;
  final String rules;
  final String exalted;
  final String debilitated;
  final String signifies;
}

const List<PlanetReference> kPlanetReference = <PlanetReference>[
  PlanetReference(
    name: 'Sun',
    rules: 'Leo',
    exalted: 'Aries',
    debilitated: 'Libra',
    signifies: 'Vitality, authority, father, self respect',
  ),
  PlanetReference(
    name: 'Moon',
    rules: 'Cancer',
    exalted: 'Taurus',
    debilitated: 'Scorpio',
    signifies: 'Mind, emotions, mother, inner peace',
  ),
  PlanetReference(
    name: 'Mars',
    rules: 'Aries and Scorpio',
    exalted: 'Capricorn',
    debilitated: 'Cancer',
    signifies: 'Energy, courage, drive, property',
  ),
  PlanetReference(
    name: 'Mercury',
    rules: 'Gemini and Virgo',
    exalted: 'Virgo',
    debilitated: 'Pisces',
    signifies: 'Speech, intellect, trade, learning',
  ),
  PlanetReference(
    name: 'Jupiter',
    rules: 'Sagittarius and Pisces',
    exalted: 'Cancer',
    debilitated: 'Capricorn',
    signifies: 'Wisdom, fortune, teacher, children',
  ),
  PlanetReference(
    name: 'Venus',
    rules: 'Taurus and Libra',
    exalted: 'Pisces',
    debilitated: 'Virgo',
    signifies: 'Love, comfort, beauty, marriage',
  ),
  PlanetReference(
    name: 'Saturn',
    rules: 'Capricorn and Aquarius',
    exalted: 'Libra',
    debilitated: 'Aries',
    signifies: 'Discipline, karma, patience, service',
  ),
  PlanetReference(
    name: 'Rahu',
    rules: 'No sign of its own',
    exalted: 'Taurus',
    debilitated: 'Scorpio',
    signifies: 'Ambition, foreign ties, sudden change',
  ),
  PlanetReference(
    name: 'Ketu',
    rules: 'No sign of its own',
    exalted: 'Scorpio',
    debilitated: 'Taurus',
    signifies: 'Detachment, insight, moksha, past karma',
  ),
];

/// The users own computed position for one planet, or null
/// when the chart has no such planet.
PlanetDetail? findPlanet(KundliResult kundli, String name) {
  for (final PlanetDetail p in kundli.planets) {
    if (p.name == name) return p;
  }
  return null;
}
