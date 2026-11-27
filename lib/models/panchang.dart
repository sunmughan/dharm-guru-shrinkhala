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

  Map<String, Object?> toJson() => <String, Object?>{
    'weekday': weekday,
    'city': city,
    'tithi': tithi,
    'vaar': vaar,
    'nakshatra': nakshatra,
    'yoga': yoga,
    'karana': karana,
    'sunrise': sunrise,
    'sunset': sunset,
    'shubhMuhurat': shubhMuhurat,
    'rahuKaal': rahuKaal,
  };

  static Panchang fromJson(Map<String, dynamic> json) => Panchang(
    weekday: json['weekday'] as String? ?? '',
    city: json['city'] as String? ?? '',
    tithi: json['tithi'] as String? ?? '',
    vaar: json['vaar'] as String? ?? '',
    nakshatra: json['nakshatra'] as String? ?? '',
    yoga: json['yoga'] as String? ?? '',
    karana: json['karana'] as String? ?? '',
    sunrise: json['sunrise'] as String? ?? '',
    sunset: json['sunset'] as String? ?? '',
    shubhMuhurat: json['shubhMuhurat'] as String? ?? '',
    rahuKaal: json['rahuKaal'] as String? ?? '',
  );

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

  Map<String, Object?> toJson() => <String, Object?>{
    'rashi': rashi,
    'date': date,
    'summary': summary,
  };

  static HoroscopeEntry fromJson(Map<String, dynamic> json) => HoroscopeEntry(
    rashi: json['rashi'] as String? ?? '',
    date: json['date'] as String? ?? '',
    summary: json['summary'] as String? ?? '',
  );
}

enum PlanTier { free, premium }

/// User profile model. Pricing is to be decided. No price is stored here.
class UserProfile {
  const UserProfile({required this.displayName, required this.plan});

  final String displayName;
  final PlanTier plan;

  Map<String, Object?> toJson() => <String, Object?>{
    'displayName': displayName,
    'plan': plan.name,
  };

  static UserProfile fromJson(Map<String, dynamic> json) => UserProfile(
    displayName: json['displayName'] as String? ?? '',
    plan: json['plan'] == 'premium' ? PlanTier.premium : PlanTier.free,
  );
}
