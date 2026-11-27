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
  });

  final String name;
  final String dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;
  final String rashi;
  final String nakshatra;
  final String tithiAtBirth;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'dateOfBirth': dateOfBirth,
    'timeOfBirth': timeOfBirth,
    'placeOfBirth': placeOfBirth,
    'rashi': rashi,
    'nakshatra': nakshatra,
    'tithiAtBirth': tithiAtBirth,
  };

  static BirthDetails fromJson(Map<String, dynamic> json) => BirthDetails(
    name: json['name'] as String? ?? '',
    dateOfBirth: json['dateOfBirth'] as String? ?? '',
    timeOfBirth: json['timeOfBirth'] as String? ?? '',
    placeOfBirth: json['placeOfBirth'] as String? ?? '',
    rashi: json['rashi'] as String? ?? '',
    nakshatra: json['nakshatra'] as String? ?? '',
    tithiAtBirth: json['tithiAtBirth'] as String? ?? '',
  );
}

class PlanetDetail {
  const PlanetDetail({
    required this.name,
    required this.rashi,
    required this.bhava,
    required this.degree,
    required this.swami,
    required this.note,
  });

  final String name;
  final String rashi;
  final String bhava;
  final String degree;
  final String swami;
  final String note;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'rashi': rashi,
    'bhava': bhava,
    'degree': degree,
    'swami': swami,
    'note': note,
  };

  static PlanetDetail fromJson(Map<String, dynamic> json) => PlanetDetail(
    name: json['name'] as String? ?? '',
    rashi: json['rashi'] as String? ?? '',
    bhava: json['bhava'] as String? ?? '',
    degree: json['degree'] as String? ?? '',
    swami: json['swami'] as String? ?? '',
    note: json['note'] as String? ?? '',
  );
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
