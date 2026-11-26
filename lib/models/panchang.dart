/// Panchang model. Phase 1 shows the layout with the sample date.
/// Tithi, vaar, nakshatra and shubh muhurat values are marked sample
/// until the panchang calculation service is built. No value here
/// is presented as a calculated result.
class Panchang {
  const Panchang({
    required this.date,
    required this.tithi,
    required this.vaar,
    required this.nakshatra,
    required this.shubhMuhurat,
    required this.sunrise,
    required this.sunset,
  });

  final String date;
  final String tithi;
  final String vaar;
  final String nakshatra;
  final String shubhMuhurat;
  final String sunrise;
  final String sunset;

  static const Panchang sample = Panchang(
    date: '14 March 1998',
    tithi: 'Sample tithi',
    vaar: 'Sample vaar',
    nakshatra: 'Sample nakshatra',
    shubhMuhurat: 'Sample shubh muhurat',
    sunrise: 'Sample sunrise',
    sunset: 'Sample sunset',
  );
}

/// Horoscope content model. Content is published from the admin panel
/// in a later phase. Phase 1 carries no prediction text.
class HoroscopeEntry {
  const HoroscopeEntry({
    required this.rashi,
    required this.date,
    required this.summary,
  });

  final String rashi;
  final String date;
  final String summary;

  static const HoroscopeEntry sample = HoroscopeEntry(
    rashi: 'Kanya',
    date: '14 March 1998',
    summary: 'Daily horoscope content will be published from the admin panel.',
  );
}

enum PlanTier { free, premium }

/// User profile model. Pricing is to be decided. No price is stored here.
class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.plan,
  });

  final String displayName;
  final PlanTier plan;
}
