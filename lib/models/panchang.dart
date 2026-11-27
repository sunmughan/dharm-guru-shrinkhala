/// Panchang model. Values come from the real engine in
/// lib/services/astro.dart for the chosen date and city, or
/// from a panchang document the admin published for that date.
/// No fixed values are stored anywhere.
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
}

/// Horoscope content model. Content is published from the admin
/// panel only. When nothing is published, the app says so.
class HoroscopeEntry {
  const HoroscopeEntry({
    required this.rashi,
    required this.date,
    required this.summary,
  });

  final String rashi;
  final String date;
  final String summary;
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
