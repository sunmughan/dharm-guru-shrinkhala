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

/// Sample planet data. Only Surya carries a full sample degree.
/// Other planets are listed as sample rows with values to be added
/// by the kundli calculation service in a later phase. Nothing here
/// is a prediction.
class SampleKundli {
  SampleKundli._();

  static const BirthDetails birth = BirthDetails.sample;

  static const String lagna = 'Meena';

  static const PlanetDetail surya = PlanetDetail(
    name: 'Surya',
    rashi: 'Meena',
    bhava: 'Lagna',
    degree: '01° 24′',
    swami: 'Guru',
    note: 'Surya in Meena lagna at 01° 24′. Sample data.',
  );

  static const List<PlanetDetail> planets = <PlanetDetail>[
    surya,
    PlanetDetail(
      name: 'Chandra',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Mangal',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Budh',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Guru',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Shukra',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Shani',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Rahu',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
    PlanetDetail(
      name: 'Ketu',
      rashi: 'Sample rashi',
      bhava: 'Sample bhava',
      degree: 'Sample degree',
      swami: 'Sample swami',
      note: 'Sample row. Value to be added by kundli calculation.',
    ),
  ];
}
