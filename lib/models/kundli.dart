/// Kundli data types. Every value here comes from the real
/// engine in lib/services/astro.dart, calculated from birth
/// date, time and place. No fixed chart is stored anywhere.
class BirthDetails {
  const BirthDetails({
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.rashi,
    required this.nakshatra,
    required this.tithiAtBirth,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String rashi;
  final String nakshatra;
  final String tithiAtBirth;

  /// Exact coordinates from place autocomplete, when the place
  /// was picked from suggestions. Null means the engine falls
  /// back to the city list for the place text.
  final double? latitude;
  final double? longitude;
}

class PlanetDetail {
  const PlanetDetail({
    required this.name,
    required this.rashi,
    required this.bhava,
    required this.degree,
    required this.swami,
    required this.note,
    required this.longitude,
  });

  final String name;
  final String rashi;
  final String bhava;
  final String degree;
  final String swami;
  final String note;

  /// Sidereal longitude in degrees, 0 to 360. The rashi and
  /// degree strings above are views of this one number, so
  /// divisional charts and dignity never re parse text.
  final double longitude;
}

/// Planet abbreviations used in the chart and the planet list,
/// in the same order as the planet details table.
const Map<String, String> kPlanetAbbreviations = <String, String>{
  'Sun': 'Su',
  'Moon': 'Mo',
  'Mars': 'Ma',
  'Mercury': 'Me',
  'Jupiter': 'Ju',
  'Venus': 'Ve',
  'Saturn': 'Sa',
  'Rahu': 'Ra',
  'Ketu': 'Ke',
};
