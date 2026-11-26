/// Panchang model. Exact sample values from
/// design/screens/08-panchang.md and
/// design/flows/02-panchang-clarity.md.
/// Sample date is Saturday 14 March 1998, Jaipur. The weekday
/// is Saturday, so the vaar is Shanivaar. Sample data only,
/// until the panchang calculation service is built. No value
/// here is presented as a calculated result.
class Panchang {
  const Panchang({
    required this.weekday,
    required this.city,
    required this.tithi,
    required this.vaar,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.sunrise,
    required this.sunset,
    required this.shubhMuhurat,
    required this.rahuKaal,
  });

  final String weekday;
  final String city;
  final String tithi;
  final String vaar;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String sunrise;
  final String sunset;
  final String shubhMuhurat;
  final String rahuKaal;

  String get dateLine => '$weekday, $city';

  static const Panchang sample = Panchang(
    weekday: 'Saturday',
    city: 'Jaipur',
    tithi: 'Shukla Panchami',
    vaar: 'Shanivaar',
    nakshatra: 'Rohini till 04:12 PM',
    yoga: 'Siddhi',
    karana: 'Bava',
    sunrise: '06:48 AM',
    sunset: '05:52 PM',
    shubhMuhurat: '09:42 AM to 11:15 AM and 04:30 PM to 06:05 PM',
    rahuKaal: '01:30 PM to 03:00 PM. Avoid starting new work '
        'in this window.',
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
