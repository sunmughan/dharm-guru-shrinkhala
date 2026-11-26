/// Sample kundli data used on every Phase 1 screen.
/// Sample data only. Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan.
/// Sample name from the presentation: Aarav Sharma.
/// No real prediction is attached to this data.
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

  static const BirthDetails sample = BirthDetails(
    name: 'Aarav Sharma',
    dateOfBirth: '14 March 1998',
    timeOfBirth: '06:25 AM',
    placeOfBirth: 'Jaipur, Rajasthan',
    rashi: 'Kanya',
    nakshatra: 'Hasta',
    tithiAtBirth: 'Krishna Dwitiya',
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
}

/// Sample planet data. Exact values from
/// design/screens/06-planet-details.md. Nothing here
/// is a prediction.
class SampleKundli {
  SampleKundli._();

  static const BirthDetails birth = BirthDetails.sample;

  static const String lagna = 'Meena';

  static const PlanetDetail surya = PlanetDetail(
    name: 'Sun',
    rashi: 'Meena',
    bhava: 'Bhava 1',
    degree: '01° 24′',
    swami: 'Jupiter',
    note: 'Sun in Meena, Bhava 1, at 01° 24′. Sample data.',
  );

  /// Exact sample table from design/screens/06-planet-details.md.
  /// Birth 14 March 1998, Jaipur. Swami is the lord of the
  /// planet's rashi. Nothing here is a prediction.
  static const List<PlanetDetail> planets = <PlanetDetail>[
    surya,
    PlanetDetail(
      name: 'Moon',
      rashi: 'Kanya',
      bhava: 'Bhava 7',
      degree: '19° 08′',
      swami: 'Mercury',
      note: 'Moon in Kanya, Bhava 7, at 19° 08′. Sample data.',
    ),
    PlanetDetail(
      name: 'Mars',
      rashi: 'Mesha',
      bhava: 'Bhava 2',
      degree: '14° 52′',
      swami: 'Mars',
      note: 'Mars in Mesha, Bhava 2, at 14° 52′. Sample data.',
    ),
    PlanetDetail(
      name: 'Mercury',
      rashi: 'Meena',
      bhava: 'Bhava 1',
      degree: '16° 37′',
      swami: 'Jupiter',
      note: 'Mercury in Meena, Bhava 1, at 16° 37′. Sample data.',
    ),
    PlanetDetail(
      name: 'Jupiter',
      rashi: 'Kumbha',
      bhava: 'Bhava 12',
      degree: '22° 05′',
      swami: 'Saturn',
      note: 'Jupiter in Kumbha, Bhava 12, at 22° 05′. Sample data.',
    ),
    PlanetDetail(
      name: 'Venus',
      rashi: 'Makara',
      bhava: 'Bhava 11',
      degree: '09° 41′',
      swami: 'Saturn',
      note: 'Venus in Makara, Bhava 11, at 09° 41′. Sample data.',
    ),
    PlanetDetail(
      name: 'Saturn',
      rashi: 'Meena',
      bhava: 'Bhava 1',
      degree: '24° 18′',
      swami: 'Jupiter',
      note: 'Saturn in Meena, Bhava 1, at 24° 18′. Sample data.',
    ),
    PlanetDetail(
      name: 'Rahu',
      rashi: 'Simha',
      bhava: 'Bhava 6',
      degree: '11° 30′',
      swami: 'Sun',
      note: 'Rahu in Simha, Bhava 6, at 11° 30′. Sample data.',
    ),
    PlanetDetail(
      name: 'Ketu',
      rashi: 'Kumbha',
      bhava: 'Bhava 12',
      degree: '11° 30′',
      swami: 'Saturn',
      note: 'Ketu in Kumbha, Bhava 12, at 11° 30′. Sample data.',
    ),
  ];

  /// Planet abbreviations from the design system, in the same
  /// order as the planet details table.
  static const Map<String, String> abbreviations = <String, String>{
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
}
