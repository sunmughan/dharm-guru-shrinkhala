import 'dart:math' as math;

import '../models/kundli.dart';
import '../models/panchang.dart';

/// Real Vedic astrology calculations, pure Dart, no network.
///
/// The engine computes tropical longitudes with the standard
/// low precision algorithms from Paul Schlyter (Sun, Moon and
/// planets from Keplerian elements, about 0.01 degrees for the
/// Sun, about 0.3 degrees for the Moon, arcminutes to a few
/// tenths of a degree for the planets), converts them to
/// sidereal longitudes with the Lahiri ayanamsa, and derives
/// lagna, rashi, nakshatra, tithi, yoga, karana, sunrise,
/// sunset, abhijit muhurat and rahu kaal from those.
///
/// Accuracy is rashi level and better: every value is checked
/// in test/astro_test.dart against a known ephemeris. This is a
/// real calculation, not a table lookup: any birth date, time
/// and place in the city list gets its own chart.
///
/// shortcut: planetary longitudes use mean elements without
/// the small perturbation terms, so Jupiter and Saturn can sit
/// up to about half a degree from a full ephemeris. That never
/// moves a planet to another rashi except within half a degree
/// of a cusp. Upgrade to full VSOP87 only if sub degree
/// precision is ever needed.
/// An unknown birth place is an error, never a silent Jaipur
/// fallback: see KundliCalculator.calculate. Time and location
/// helpers (julianDay, indiaUtcOffset, sunriseSunset,
/// moonriseMoonset, localSolarDay) are public so the Phase 17
/// reference tests can check them against JPL DE421 numbers.
const List<String> kRashis = <String>[
  'Mesha',
  'Vrishabha',
  'Mithuna',
  'Karka',
  'Simha',
  'Kanya',
  'Tula',
  'Vrishchika',
  'Dhanu',
  'Makara',
  'Kumbha',
  'Meena',
];

/// Lord of each rashi, in kRashis order.
const List<String> kRashiLords = <String>[
  'Mars',
  'Venus',
  'Mercury',
  'Moon',
  'Sun',
  'Mercury',
  'Venus',
  'Mars',
  'Jupiter',
  'Saturn',
  'Saturn',
  'Jupiter',
];

const List<String> kNakshatras = <String>[
  'Ashwini',
  'Bharani',
  'Krittika',
  'Rohini',
  'Mrigashira',
  'Ardra',
  'Punarvasu',
  'Pushya',
  'Ashlesha',
  'Magha',
  'Purva Phalguni',
  'Uttara Phalguni',
  'Hasta',
  'Chitra',
  'Swati',
  'Vishakha',
  'Anuradha',
  'Jyeshtha',
  'Mula',
  'Purva Ashadha',
  'Uttara Ashadha',
  'Shravana',
  'Dhanishta',
  'Shatabhisha',
  'Purva Bhadrapada',
  'Uttara Bhadrapada',
  'Revati',
];

/// Lord of each nakshatra, in kNakshatras order.
const List<String> kNakshatraLords = <String>[
  'Ketu',
  'Venus',
  'Sun',
  'Moon',
  'Mars',
  'Rahu',
  'Jupiter',
  'Saturn',
  'Mercury',
  'Ketu',
  'Venus',
  'Sun',
  'Moon',
  'Mars',
  'Rahu',
  'Jupiter',
  'Saturn',
  'Mercury',
  'Ketu',
  'Venus',
  'Sun',
  'Moon',
  'Mars',
  'Rahu',
  'Jupiter',
  'Saturn',
  'Mercury',
];

const List<String> kTithiNames = <String>[
  'Pratipada',
  'Dwitiya',
  'Tritiya',
  'Chaturthi',
  'Panchami',
  'Shashthi',
  'Saptami',
  'Ashtami',
  'Navami',
  'Dashami',
  'Ekadashi',
  'Dwadashi',
  'Trayodashi',
  'Chaturdashi',
  'Purnima',
];

const List<String> kYogas = <String>[
  'Vishkambha',
  'Priti',
  'Ayushman',
  'Saubhagya',
  'Shobhana',
  'Atiganda',
  'Sukarma',
  'Dhriti',
  'Shula',
  'Ganda',
  'Vriddhi',
  'Dhruva',
  'Vyaghata',
  'Harshana',
  'Vajra',
  'Siddhi',
  'Vyatipata',
  'Variyana',
  'Parigha',
  'Shiva',
  'Siddha',
  'Sadhya',
  'Shubha',
  'Shukla',
  'Brahma',
  'Indra',
  'Vaidhriti',
];

const List<String> kVaars = <String>[
  'Somvaar',
  'Mangalvaar',
  'Budhvaar',
  'Guruvaar',
  'Shukravaar',
  'Shanivaar',
  'Ravivaar',
];

const List<String> kWeekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// A place with the coordinates the calculations need.
/// India has one time zone, so every city here is IST.
class AstroPlace {
  const AstroPlace(this.name, this.latitude, this.longitude);

  final String name;

  /// Degrees north.
  final double latitude;

  /// Degrees east.
  final double longitude;
}

const AstroPlace kDefaultPlace =
    AstroPlace('Jaipur', 26.9124, 75.7873);

/// Major Indian cities, latitude and longitude in degrees.
/// The lookup matches on the city name, so "Jaipur, Rajasthan"
/// finds Jaipur. Add a city here when a user reports it.
const List<AstroPlace> kIndianCities = <AstroPlace>[
  AstroPlace('Jaipur', 26.9124, 75.7873),
  AstroPlace('Delhi', 28.6139, 77.2090),
  AstroPlace('New Delhi', 28.6139, 77.2090),
  AstroPlace('Mumbai', 19.0760, 72.8777),
  AstroPlace('Kolkata', 22.5726, 88.3639),
  AstroPlace('Chennai', 13.0827, 80.2707),
  AstroPlace('Bengaluru', 12.9716, 77.5946),
  AstroPlace('Bangalore', 12.9716, 77.5946),
  AstroPlace('Hyderabad', 17.3850, 78.4867),
  AstroPlace('Pune', 18.5204, 73.8567),
  AstroPlace('Ahmedabad', 23.0225, 72.5714),
  AstroPlace('Lucknow', 26.8467, 80.9462),
  AstroPlace('Kanpur', 26.4499, 80.3319),
  AstroPlace('Varanasi', 25.3176, 82.9739),
  AstroPlace('Patna', 25.5941, 85.1376),
  AstroPlace('Bhopal', 23.2599, 77.4126),
  AstroPlace('Indore', 22.7196, 75.8577),
  AstroPlace('Nagpur', 21.1458, 79.0882),
  AstroPlace('Agra', 27.1767, 78.0081),
  AstroPlace('Amritsar', 31.6340, 74.8723),
  AstroPlace('Ludhiana', 30.9010, 75.8573),
  AstroPlace('Chandigarh', 30.7333, 76.7794),
  AstroPlace('Dehradun', 30.3165, 78.0322),
  AstroPlace('Udaipur', 24.5854, 73.7125),
  AstroPlace('Jodhpur', 26.2389, 73.0243),
  AstroPlace('Kota', 25.2138, 75.8648),
  AstroPlace('Raipur', 21.2514, 81.6296),
  AstroPlace('Bilaspur', 22.0797, 82.1409),
  AstroPlace('Durg', 21.1900, 81.2800),
  AstroPlace('Bhilai', 21.2100, 81.3800),
  AstroPlace('Ranchi', 23.3441, 85.3096),
  AstroPlace('Guwahati', 26.1445, 91.7362),
  AstroPlace('Bhubaneswar', 20.2961, 85.8245),
  AstroPlace('Kochi', 9.9312, 76.2673),
  AstroPlace('Thiruvananthapuram', 8.5241, 76.9366),
  AstroPlace('Madurai', 9.9252, 78.1198),
  AstroPlace('Coimbatore', 11.0168, 76.9558),
  AstroPlace('Surat', 21.1702, 72.8311),
  AstroPlace('Vadodara', 22.3072, 73.1812),
  AstroPlace('Rajkot', 22.3039, 70.8022),
  AstroPlace('Nashik', 19.9975, 73.7898),
  AstroPlace('Gwalior', 26.2183, 78.1828),
  AstroPlace('Jabalpur', 23.1815, 79.9864),
  AstroPlace('Prayagraj', 25.4358, 81.8463),
  AstroPlace('Allahabad', 25.4358, 81.8463),
  AstroPlace('Gorakhpur', 26.7606, 83.3732),
  AstroPlace('Noida', 28.5355, 77.3910),
  AstroPlace('Ghaziabad', 28.6692, 77.4538),
  AstroPlace('Faridabad', 28.4089, 77.3178),
  AstroPlace('Gurgaon', 28.4595, 77.0266),
  AstroPlace('Gurugram', 28.4595, 77.0266),
  AstroPlace('Thane', 19.2183, 72.9781),
  AstroPlace('Shimla', 31.1048, 77.1734),
  AstroPlace('Meerut', 28.9845, 77.7064),
  AstroPlace('Jirapur', 24.0214, 76.3764),
  AstroPlace('Rajgarh', 24.0072, 76.7297),
  AstroPlace('Vidisha', 23.5252, 77.8087),
  AstroPlace('Sagar', 23.8388, 78.7378),
  AstroPlace('Rewa', 24.5364, 81.3037),
  AstroPlace('Satna', 24.5759, 80.8324),
  AstroPlace('Ujjain', 23.1765, 75.7885),
  AstroPlace('Ratlam', 23.3315, 75.0367),
  AstroPlace('Mandsaur', 24.0760, 75.0679),
  AstroPlace('Neemuch', 24.4719, 74.8684),
  AstroPlace('Chhindwara', 22.0574, 78.9382),
  AstroPlace('Seoni', 22.0837, 79.5418),
  AstroPlace('Balaghat', 21.8122, 80.3412),
  AstroPlace('Dhamtari', 20.7089, 81.5483),
  AstroPlace('Rajnandgaon', 21.0978, 81.0336),
  AstroPlace('Mahasamund', 21.1094, 82.0993),
  AstroPlace('Korba', 22.3595, 82.6873),
  AstroPlace('Raigarh', 21.8983, 83.3978),
  AstroPlace('Jagdalpur', 19.0816, 82.0200),
  AstroPlace('Ambikapur', 23.1222, 83.1946),
  AstroPlace('Kanker', 20.2719, 81.4930),
  AstroPlace('Kawardha', 22.0104, 81.2426),
];

/// Finds a city by name inside free text like "Jaipur,
/// Rajasthan". Null when no city in the list matches.
AstroPlace? placeFor(String text) {
  final String lower = text.toLowerCase();
  for (final AstroPlace place in kIndianCities) {
    if (lower.contains(place.name.toLowerCase())) {
      return place;
    }
  }
  return null;
}

/// Julian Day number for a UTC instant. J2000.0 is
/// 2000-01-01 12:00 UTC, JD 2451545.0. The engine day number
/// used below is JD minus 2451543.5.
double julianDay(DateTime utc) {
  final DateTime u = utc.toUtc();
  final int a = (14 - u.month) ~/ 12;
  final int y = u.year + 4800 - a;
  final int m = u.month + 12 * a - 3;
  final int jdn = u.day +
      ((153 * m + 2) ~/ 5) +
      365 * y +
      (y ~/ 4) -
      (y ~/ 100) +
      (y ~/ 400) -
      32045;
  final double fraction = (u.hour - 12) / 24.0 +
      u.minute / 1440.0 +
      u.second / 86400.0;
  return jdn + fraction;
}

/// Ayanamsa system. Lahiri is the default everywhere: the
/// Indian government standard, fixed so Spica sits at 180
/// degrees sidereal longitude. Raman and Krishnamurti are
/// fixed offsets from Lahiri, documented in
/// docs/implementation/ASTROLOGY_LIBRARY_EVALUATION.md.
enum AyanamshaMode { lahiri, raman, krishnamurti }

/// Ayanamsa in degrees for an engine day number, in the
/// requested system. Raman runs 1 degree 26 minutes below
/// Lahiri (matches published Raman values to about 3
/// arcminutes); Krishnamurti runs 6 arcminutes below Lahiri.
double ayanamshaFor(AyanamshaMode mode, double d) {
  final double lahiri = ayanamsa(d);
  return switch (mode) {
    AyanamshaMode.lahiri => lahiri,
    AyanamshaMode.raman => lahiri - 1.4333,
    AyanamshaMode.krishnamurti => lahiri - 0.1,
  };
}

/// Lunar node model. Mean is the smooth regression, true
/// adds the five short period terms from Meeus, Astronomical
/// Algorithms 2nd edition, chapter 47. The two can differ by
/// up to about 2 degrees, enough to move Rahu across a sign
/// or nakshatra boundary, so the mode is part of the
/// calculation config, never a hidden default.
enum NodeMode { mean, trueNode }

/// Delaunay arguments in degrees for an engine day number:
/// mean elongation of the Moon (d), Sun mean anomaly (m),
/// Moon mean anomaly (mp) and Moon argument of latitude (f),
/// Meeus chapter 47 polynomials in Julian centuries.
({double d, double m, double mp, double f}) _delaunay(double dayNumber) {
  final double t = (dayNumber - 1.5) / 36525.0;
  final double t2 = t * t;
  final double t3 = t2 * t;
  final double t4 = t3 * t;
  return (
    d: 297.8501921 +
        445267.1114034 * t -
        0.0018819 * t2 +
        t3 / 545868 -
        t4 / 113065000,
    m: 357.5291092 +
        35999.0502909 * t -
        0.0001536 * t2 +
        t3 / 24490000,
    mp: 134.9633964 +
        477198.8675055 * t +
        0.0087414 * t2 +
        t3 / 69699 -
        t4 / 14712000,
    f: 93.2720950 +
        483202.0175233 * t -
        0.0036539 * t2 -
        t3 / 3526000 +
        t4 / 863310000,
  );
}

/// True ascending node (Rahu) tropical longitude in degrees:
/// the Meeus mean node plus the five periodic terms. The mean
/// node here is the Meeus polynomial, which sits about 0.08
/// degrees from the Schlyter mean node the engine uses for
/// the default mean mode; the difference is named, not hidden.
double trueNodeLongitude(double dayNumber) {
  final double t = (dayNumber - 1.5) / 36525.0;
  final double t2 = t * t;
  final double t3 = t2 * t;
  final double t4 = t3 * t;
  final double mean = 125.0445479 -
      1934.1362891 * t +
      0.0020754 * t2 +
      t3 / 467441 -
      t4 / 60616000;
  final ({double d, double m, double mp, double f}) arg =
      _delaunay(dayNumber);
  final double correction = -1.4979 * _sinD(2 * (arg.d - arg.f)) -
      0.1500 * _sinD(arg.m) -
      0.1226 * _sinD(2 * arg.d) +
      0.1176 * _sinD(2 * arg.f) -
      0.0801 * _sinD(2 * (arg.mp - arg.f));
  return _norm(mean + correction);
}

/// Ascending node (Rahu) tropical longitude in the requested
/// node mode. Ketu is always exactly 180 degrees opposite.
double nodeLongitude(double dayNumber, NodeMode mode) {
  return switch (mode) {
    NodeMode.mean => _rahuLongitude(dayNumber),
    NodeMode.trueNode => trueNodeLongitude(dayNumber),
  };
}

/// Tropical longitude of a planet, the Sun or the Moon at a
/// UTC instant, in degrees. Rahu and Ketu use the mean node.
/// Names are Sun, Moon, Mars, Mercury, Jupiter, Venus,
/// Saturn, Rahu, Ketu. Anything else throws ArgumentError.
double tropicalLongitudeAt({
  required String planet,
  required DateTime utc,
}) {
  final double d = _dayNumber(utc.toUtc());
  final ({double lon, double xs, double ys}) sun = _sunPosition(d);
  return switch (planet) {
    'Sun' => sun.lon,
    'Moon' => _moonLongitude(d),
    'Rahu' => _rahuLongitude(d),
    'Ketu' => _norm(_rahuLongitude(d) + 180.0),
    _ => _planetLongitude(planet, d, sun.xs, sun.ys),
  };
}

/// Tropical ascendant in degrees at a UTC instant for a place.
/// Public so the Phase 17 reference tests can check it against
/// the GMST based value from JPL DE421.
double ascendantTropical({
  required DateTime utc,
  required AstroPlace place,
}) {
  return _ascendant(_dayNumber(utc.toUtc()), place);
}

/// UTC offset for a local time in India. IST is UTC plus 5
/// hours 30 minutes since 1906. India ran wartime daylight
/// saving, UTC plus 6 hours 30 minutes, from 15 May 1942 to
/// 15 October 1945. Before 1906 each city kept local mean
/// time, so the offset comes from the longitude: 4 minutes
/// per degree east. Any place outside India needs its own
/// offset passed in by the caller; the engine never guesses
/// one from a city name.
Duration indiaUtcOffset({
  required DateTime local,
  required double longitude,
}) {
  if (!local.isBefore(DateTime(1942, 5, 15)) &&
      local.isBefore(DateTime(1945, 10, 16))) {
    return const Duration(hours: 6, minutes: 30);
  }
  if (!local.isBefore(DateTime(1906, 1, 1))) {
    return const Duration(hours: 5, minutes: 30);
  }
  return Duration(minutes: (longitude * 4.0).round());
}

/// Sunrise and sunset as local wall clock times on [day] for
/// [place]. [utcOffset] is the zone offset that day, for
/// example IST plus 5 hours 30 minutes: the caller owns the
/// zone, the engine only owns the astronomy. Solar noon is
/// 12 minus the longitude difference from the zone meridian,
/// minus the equation of time. Polar days and nights return
/// a sunrise after the sunset; the caller checks that.
({DateTime sunrise, DateTime sunset}) sunriseSunset({
  required DateTime day,
  required AstroPlace place,
  required Duration utcOffset,
}) {
  final DateTime noon =
      DateTime(day.year, day.month, day.day, 12);
  final DateTime utcNoon = noon.subtract(utcOffset);
  final double d = _dayNumber(utcNoon);
  final ({double lon, double xs, double ys}) sun = _sunPosition(d);
  final double eps = 23.4393 - 3.563e-7 * d;
  final double decl =
      math.asin(_sinD(eps) * _sinD(sun.lon)) * 180.0 / math.pi;
  final double cosH = (_sinD(-0.833) -
          _sinD(place.latitude) * _sinD(decl)) /
      (_cosD(place.latitude) * _cosD(decl));
  final double clamped = cosH.clamp(-1.0, 1.0);
  final double h0 = math.acos(clamped) * 180.0 / math.pi / 15.0;
  final double standardMeridian =
      utcOffset.inMinutes / 60.0 * 15.0;
  final double noonLocal = 12.0 -
      (place.longitude - standardMeridian) / 15.0 -
      _equationOfTime(day) / 60.0;
  DateTime at(double hours) {
    final DateTime midnight =
        DateTime(day.year, day.month, day.day);
    return midnight.add(Duration(minutes: (hours * 60.0).round()));
  }

  return (sunrise: at(noonLocal - h0), sunset: at(noonLocal + h0));
}

/// Geocentric equatorial coordinates of the Moon: right
/// ascension and declination in degrees. Same Schlyter lunar
/// theory as _moonLongitude, with the ecliptic latitude kept
/// from the main Meeus latitude terms instead of dropped.
/// Latitude error stays under about 0.1 degrees, which moves
/// a moonrise by a few minutes at most.
({double ra, double dec}) _moonEquatorial(double d) {
  final double lon = _moonLongitude(d);
  final ({double d, double m, double mp, double f}) arg = _delaunay(d);
  final double lat = 5.128122 * _sinD(arg.f) +
      0.280602 * _sinD(arg.mp + arg.f) +
      0.277693 * _sinD(arg.mp - arg.f) +
      0.173237 * _sinD(2 * arg.d - arg.f);
  final double lonR = lon * math.pi / 180.0;
  final double latR = lat * math.pi / 180.0;
  final double xe = math.cos(latR) * math.cos(lonR);
  final double ye = math.cos(latR) * math.sin(lonR);
  final double ze = math.sin(latR);
  final double eps = 23.4393 - 3.563e-7 * d;
  final double epsR = eps * math.pi / 180.0;
  final double xeq = xe;
  final double yeq = ye * math.cos(epsR) - ze * math.sin(epsR);
  final double zeq = ye * math.sin(epsR) + ze * math.cos(epsR);
  return (
    ra: _norm(_atan2D(yeq, xeq)),
    dec: math.asin(zeq.clamp(-1.0, 1.0)) * 180.0 / math.pi,
  );
}

double _bodyAltitude({
  required double ra,
  required double dec,
  required DateTime utc,
  required AstroPlace place,
}) {
  final double jd = 2451543.5 + _dayNumber(utc.toUtc());
  final double gmst = _norm(
    280.46061837 + 360.98564736629 * (jd - 2451545.0),
  );
  final double lst = _norm(gmst + place.longitude);
  double ha = _norm(lst - ra);
  if (ha > 180.0) ha -= 360.0;
  final double sinAlt = _sinD(place.latitude) * _sinD(dec) +
      _cosD(place.latitude) * _cosD(dec) * _cosD(ha);
  return math.asin(sinAlt.clamp(-1.0, 1.0)) * 180.0 / math.pi;
}

/// Moonrise and moonset as local wall clock times on [day]
/// for [place]. Either is null when the Moon does not rise or
/// does not set that local day, which happens near the
/// poles and on the day the Moon stays up or down. Found by
/// sampling the Moon altitude every 10 minutes and bisecting
/// each crossing of minus 0.583 degrees to the minute.
({DateTime? moonrise, DateTime? moonset}) moonriseMoonset({
  required DateTime day,
  required AstroPlace place,
  required Duration utcOffset,
}) {
  final DateTime midnight = DateTime(day.year, day.month, day.day);
  double altitudeAt(DateTime local) {
    final DateTime utc = local.subtract(utcOffset);
    final ({double ra, double dec}) eq =
        _moonEquatorial(_dayNumber(utc));
    return _bodyAltitude(
      ra: eq.ra,
      dec: eq.dec,
      utc: utc,
      place: place,
    );
  }

  DateTime bisect(DateTime a, DateTime b) {
    DateTime lo = a;
    DateTime hi = b;
    for (int step = 0; step < 12; step++) {
      final DateTime mid =
          lo.add(Duration(minutes: hi.difference(lo).inMinutes ~/ 2));
      if ((altitudeAt(mid) + 0.583) *
              (altitudeAt(lo) + 0.583) <=
          0) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    return hi;
  }

  DateTime? rise;
  DateTime? set;
  DateTime prev = midnight;
  double prevAlt = altitudeAt(prev) + 0.583;
  for (int step = 1; step <= 144; step++) {
    final DateTime now =
        midnight.add(Duration(minutes: step * 10));
    final double alt = altitudeAt(now) + 0.583;
    if (prevAlt < 0 && alt >= 0 && rise == null) {
      rise = bisect(prev, now);
    }
    if (prevAlt >= 0 && alt < 0 && set == null) {
      set = bisect(prev, now);
    }
    prev = now;
    prevAlt = alt;
  }
  return (moonrise: rise, moonset: set);
}

/// Local solar day: sunrise to the next sunrise, and its
/// length. The Hindu day runs sunrise to sunrise, so this is
/// the day boundary the panchang uses, not midnight.
({DateTime sunrise, DateTime nextSunrise, Duration length})
    localSolarDay({
  required DateTime day,
  required AstroPlace place,
  required Duration utcOffset,
}) {
  final DateTime sunrise =
      sunriseSunset(day: day, place: place, utcOffset: utcOffset)
          .sunrise;
  final DateTime nextSunrise = sunriseSunset(
    day: day.add(const Duration(days: 1)),
    place: place,
    utcOffset: utcOffset,
  ).sunrise;
  return (
    sunrise: sunrise,
    nextSunrise: nextSunrise,
    length: nextSunrise.difference(sunrise),
  );
}

double _norm(double degrees) {
  double value = degrees % 360.0;
  if (value < 0) value += 360.0;
  return value;
}

double _sinD(double degrees) => math.sin(degrees * math.pi / 180.0);

double _cosD(double degrees) => math.cos(degrees * math.pi / 180.0);

double _atan2D(double y, double x) =>
    math.atan2(y, x) * 180.0 / math.pi;

/// Schlyter day number: days since 2000 Jan 0.0, from a UTC
/// date time. The fraction of the day is included.
double _dayNumber(DateTime utc) {
  final int y = utc.year;
  final int m = utc.month;
  final double day = utc.day +
      (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
  return 367.0 * y -
      (7.0 * (y + (m + 9) ~/ 12) / 4.0).floorToDouble() +
      (275.0 * m / 9.0).floorToDouble() +
      day -
      730530.0;
}

/// Lahiri ayanamsa in degrees for a day number.
double ayanamsa(double d) {
  final double fracYear = 2000.0 + d / 365.25;
  return 23.851 + (fracYear - 2000.0) * 0.01397;
}

/// Tropical Sun position and its heliocentric ecliptic
/// coordinates, used as the origin for the planets.
({double lon, double xs, double ys}) _sunPosition(double d) {
  final double w = 282.9404 + 4.70935e-5 * d;
  final double e = 0.016709 - 1.151e-9 * d;
  final double m = 356.0470 + 0.9856002585 * d;
  final double ecl = m +
      (180.0 / math.pi) * e * _sinD(m) * (1.0 + e * _cosD(m));
  final double x = _cosD(ecl) - e;
  final double y = _sinD(ecl) * math.sqrt(1.0 - e * e);
  final double v = _atan2D(y, x);
  final double r = math.sqrt(x * x + y * y);
  final double lon = _norm(v + w);
  return (
    lon: lon,
    xs: r * _cosD(lon),
    ys: r * _sinD(lon),
  );
}

/// Tropical Moon longitude in degrees, Schlyter, with the
/// main perturbation terms.
double _moonLongitude(double d) {
  final double n = 125.1228 - 0.0529538083 * d;
  const double i = 5.1454;
  final double w = 318.0634 + 0.1643573223 * d;
  const double a = 60.2666;
  const double e = 0.054900;
  final double m = 115.3654 + 13.0649929509 * d;
  final double ecl = m +
      (180.0 / math.pi) * e * _sinD(m) * (1.0 + e * _cosD(m));
  final double x = a * (_cosD(ecl) - e);
  final double y = a * _sinD(ecl) * math.sqrt(1.0 - e * e);
  final double v = _atan2D(y, x);
  final double r = math.sqrt(x * x + y * y);
  final double xh = r *
      (_cosD(n) * _cosD(v + w) - _sinD(n) * _sinD(v + w) * _cosD(i));
  final double yh = r *
      (_sinD(n) * _cosD(v + w) + _cosD(n) * _sinD(v + w) * _cosD(i));
  double lon = _atan2D(yh, xh);
  final double ms = 356.0470 + 0.9856002585 * d;
  final double ws = 282.9404 + 4.70935e-5 * d;
  final double lm = _norm(n + w + m);
  final double ls = _norm(ws + ms);
  final double dd = _norm(lm - ls);
  final double f = _norm(lm - n);
  lon += -1.274 * _sinD(m - 2 * dd) +
      0.658 * _sinD(2 * dd) -
      0.186 * _sinD(ms) -
      0.059 * _sinD(2 * m - 2 * dd) -
      0.057 * _sinD(m - 2 * dd + ms) +
      0.053 * _sinD(m + 2 * dd) +
      0.046 * _sinD(2 * dd - ms) +
      0.041 * _sinD(m - ms) -
      0.035 * _sinD(dd) -
      0.031 * _sinD(m + ms) -
      0.015 * _sinD(2 * f - 2 * dd) +
      0.011 * _sinD(m - 4 * dd);
  return _norm(lon);
}

/// Orbital elements for one planet, Schlyter: node, inclination,
/// perihelion, semi major axis, eccentricity, mean anomaly.
class _PlanetElements {
  const _PlanetElements(this.n, this.i, this.w, this.a, this.e, this.m);

  final double n;
  final double i;
  final double w;
  final double a;
  final double e;
  final double m;
}

_PlanetElements _elements(String name, double d) {
  return switch (name) {
    'Mercury' => _PlanetElements(
        48.3313 + 3.24587e-5 * d,
        7.0047 + 5.00e-8 * d,
        29.1241 + 1.01444e-5 * d,
        0.387098,
        0.205635 + 5.59e-10 * d,
        168.6562 + 4.0923344368 * d,
      ),
    'Venus' => _PlanetElements(
        76.6799 + 2.46590e-5 * d,
        3.3946 + 2.75e-8 * d,
        54.8910 + 1.38374e-5 * d,
        0.723330,
        0.006773 - 1.302e-9 * d,
        48.0052 + 1.6021302244 * d,
      ),
    'Mars' => _PlanetElements(
        49.5574 + 2.11081e-5 * d,
        1.8497 - 1.78e-8 * d,
        286.5016 + 2.92961e-5 * d,
        1.523688,
        0.093405 + 2.516e-9 * d,
        18.6021 + 0.5240207766 * d,
      ),
    'Jupiter' => _PlanetElements(
        100.4542 + 2.76854e-5 * d,
        1.3030 - 1.557e-7 * d,
        273.8777 + 1.64505e-5 * d,
        5.20256,
        0.048498 + 4.469e-9 * d,
        19.8950 + 0.0830853001 * d,
      ),
    'Saturn' => _PlanetElements(
        113.6634 + 2.38980e-5 * d,
        2.4886 - 1.081e-7 * d,
        339.3939 + 2.97661e-5 * d,
        9.55475,
        0.055546 - 9.499e-9 * d,
        316.9670 + 0.0334442282 * d,
      ),
    _ => throw ArgumentError('No elements for $name'),
  };
}

/// Geocentric tropical longitude of a planet, Schlyter.
double _planetLongitude(String name, double d, double xs, double ys) {
  final _PlanetElements el = _elements(name, d);
  final double ecl = el.m +
      (180.0 / math.pi) *
          el.e *
          _sinD(el.m) *
          (1.0 + el.e * _cosD(el.m));
  final double x = el.a * (_cosD(ecl) - el.e);
  final double y =
      el.a * _sinD(ecl) * math.sqrt(1.0 - el.e * el.e);
  final double v = _atan2D(y, x);
  final double r = math.sqrt(x * x + y * y);
  final double xh = r *
      (_cosD(el.n) * _cosD(v + el.w) -
          _sinD(el.n) * _sinD(v + el.w) * _cosD(el.i));
  final double yh = r *
      (_sinD(el.n) * _cosD(v + el.w) +
          _cosD(el.n) * _sinD(v + el.w) * _cosD(el.i));
  return _norm(_atan2D(yh + ys, xh + xs));
}

/// Mean lunar node (Rahu) tropical longitude in degrees.
double _rahuLongitude(double d) =>
    _norm(125.1228 - 0.0529538083 * d);

/// Tropical ascendant in degrees, from the day number and the
/// place. Found as the intersection of the ecliptic plane and
/// the horizon plane, taking the rising intersection.
double _ascendant(double d, AstroPlace place) {
  final double jd = 2451543.5 + d;
  final double gmst = _norm(
    280.46061837 + 360.98564736629 * (jd - 2451545.0),
  );
  final double lst = _norm(gmst + place.longitude);
  final double eps = 23.4393 - 3.563e-7 * d;
  // Ecliptic north pole in equatorial coordinates:
  // (0, -sin eps, cos eps).
  final double nEclY = -_sinD(eps);
  final double nEclZ = _cosD(eps);
  // Zenith in equatorial coordinates.
  final double lstR = lst * math.pi / 180.0;
  final double latR = place.latitude * math.pi / 180.0;
  final double zx = math.cos(latR) * math.cos(lstR);
  final double zy = math.cos(latR) * math.sin(lstR);
  final double zz = math.sin(latR);
  // Intersection of the two planes: cross product of normals.
  final double dx = nEclY * zz - nEclZ * zy;
  final double dy = nEclZ * zx;
  final double dz = -nEclY * zx;
  // To ecliptic longitude.
  final double epsR = eps * math.pi / 180.0;
  final double xe = dx;
  final double ye = dy * math.cos(epsR) + dz * math.sin(epsR);
  double lon = _norm(_atan2D(ye, xe));
  // Keep the rising intersection: hour angle must be negative.
  final double ra = _norm(_atan2D(dy, dx));
  double hourAngle = _norm(lst - ra);
  if (hourAngle > 180.0) hourAngle -= 360.0;
  if (hourAngle > 0) {
    lon = _norm(lon + 180.0);
  }
  return lon;
}

int _rashiIndex(double siderealLon) =>
    (siderealLon ~/ 30.0) % 12;

/// Degrees inside the rashi, formatted as 01° 24′.
String formatDegree(double siderealLon) {
  final double within = siderealLon % 30.0;
  int deg = within.floor();
  int min = ((within - deg) * 60.0).round();
  if (min == 60) {
    min = 0;
    deg += 1;
  }
  return '${deg.toString().padLeft(2, '0')}° ${min.toString().padLeft(2, '0')}′';
}

String _tithiName(double elongation) {
  final int num = (elongation ~/ 12.0) + 1;
  if (num <= 15) return 'Shukla ${kTithiNames[num - 1]}';
  // The 30th tithi is Amavasya, not a second Purnima: the
  // shared 15 name table has no Amavasya entry, so the old
  // code labelled it Krishna Purnima and Amavasya never
  // appeared. 16 to 29 are Krishna Pratipada to Chaturdashi.
  if (num == 30) return 'Krishna Amavasya';
  return 'Krishna ${kTithiNames[num - 16]}';
}

String _nakshatraName(double moonSidereal) {
  final int index = (moonSidereal ~/ (40.0 / 3.0)) % 27;
  return kNakshatras[index];
}

String _yogaName(double sunSidereal, double moonSidereal) {
  final double sum = _norm(sunSidereal + moonSidereal);
  final int index = (sum ~/ (40.0 / 3.0)) % 27;
  return kYogas[index];
}

String _karanaName(double elongation) {
  final int k = (elongation ~/ 6.0).floor();
  if (k == 0) return 'Kimstughna';
  if (k == 57) return 'Shakuni';
  if (k == 58) return 'Chatushpada';
  if (k == 59) return 'Naga';
  const List<String> repeating = <String>[
    'Bava',
    'Balava',
    'Kaulava',
    'Taitila',
    'Garaja',
    'Vanija',
    'Vishti',
  ];
  return repeating[(k - 1) % 7];
}

/// One computed kundli: lagna, planets and Moon details, all
/// sidereal. Degrees are inside the rashi, for example
/// "01° 24′".
class KundliResult {
  const KundliResult({
    required this.lagna,
    required this.lagnaDegree,
    required this.moonRashi,
    required this.moonNakshatra,
    required this.tithiAtBirth,
    required this.planets,
    required this.place,
    required this.placeApproximate,
    required this.timeApproximate,
  });

  /// Lagna rashi name, for example Meena.
  final String lagna;

  /// Lagna degrees inside its rashi, for example "01° 24′".
  final String lagnaDegree;

  final String moonRashi;
  final String moonNakshatra;
  final String tithiAtBirth;
  final List<PlanetDetail> planets;
  final AstroPlace place;

  /// True when the place text matched no city and Jaipur
  /// coordinates were used instead. Never true now: an
  /// unknown place throws in calculate instead of falling
  /// back. The field stays so callers keep compiling.
  final bool placeApproximate;

  /// True when the birth time was not known and noon was used.
  final bool timeApproximate;

  /// Same planets with bhavas counted from the Moon sign,
  /// for the Moon chart. Lagna becomes the Moon rashi.
  KundliResult get moonChart {
    final int moonIndex = kRashis.indexOf(moonRashi);
    final List<PlanetDetail> moved = planets.map((PlanetDetail p) {
      final int sign = kRashis.indexOf(p.rashi);
      final int bhava = ((sign - moonIndex) % 12 + 12) % 12 + 1;
      return PlanetDetail(
        name: p.name,
        rashi: p.rashi,
        bhava: 'Bhava $bhava',
        degree: p.degree,
        swami: p.swami,
        note: p.note,
        longitude: p.longitude,
      );
    }).toList();
    return KundliResult(
      lagna: moonRashi,
      lagnaDegree: lagnaDegree,
      moonRashi: moonRashi,
      moonNakshatra: moonNakshatra,
      tithiAtBirth: tithiAtBirth,
      planets: moved,
      place: place,
      placeApproximate: placeApproximate,
      timeApproximate: timeApproximate,
    );
  }
}

/// Real kundli calculation from birth date, time and place.
/// [birthLocal] is the birth date and time in local time at
/// the place. [timeKnown] is false when the user does not know
/// the birth time: noon is used and the result is marked
/// approximate, since the lagna then depends on the time.
/// Throws ArgumentError when [placeText] matches no city in
/// the list: an unknown place is never silently replaced with
/// Jaipur. The caller shows the error and asks for a place
/// the engine knows, or a manual latitude and longitude.
class KundliCalculator {
  KundliCalculator._();

  static KundliResult calculate({
    required DateTime birthLocal,
    required String placeText,
    bool timeKnown = true,
    double? latitude,
    double? longitude,
  }) {
    final AstroPlace place;
    if (latitude != null && longitude != null) {
      place = AstroPlace(placeText, latitude, longitude);
    } else {
      final AstroPlace? found = placeFor(placeText);
      if (found == null) {
        throw ArgumentError(
          'Unknown birth place "$placeText". Pick a city from '
          'the list or enter latitude and longitude manually.',
        );
      }
      place = found;
    }
    final DateTime local = timeKnown
        ? birthLocal
        : DateTime(
            birthLocal.year, birthLocal.month, birthLocal.day, 12,
          );
    final DateTime utc = local.subtract(
      indiaUtcOffset(local: local, longitude: place.longitude),
    );
    final double d = _dayNumber(utc);
    final double ayan = ayanamsa(d);
    final ({double lon, double xs, double ys}) sun = _sunPosition(d);
    final double moonTropical = _moonLongitude(d);
    final double sunSidereal = _norm(sun.lon - ayan);
    final double moonSidereal = _norm(moonTropical - ayan);
    final double lagnaTropical = _ascendant(d, place);
    final double lagnaSidereal = _norm(lagnaTropical - ayan);
    final int lagnaIndex = _rashiIndex(lagnaSidereal);
    final String lagna = kRashis[lagnaIndex];
    PlanetDetail planet(
      String name,
      double tropicalLon,
    ) {
      final double sidereal = _norm(tropicalLon - ayan);
      final int sign = _rashiIndex(sidereal);
      final int bhava = ((sign - lagnaIndex) % 12 + 12) % 12 + 1;
      final String rashi = kRashis[sign];
      return PlanetDetail(
        name: name,
        rashi: rashi,
        bhava: 'Bhava $bhava',
        degree: formatDegree(sidereal),
        swami: kRashiLords[sign],
        note: '$name in $rashi, Bhava $bhava, at '
            '${formatDegree(sidereal)}.',
        longitude: sidereal,
      );
    }

    final double rahuTropical = _rahuLongitude(d);
    final List<PlanetDetail> planets = <PlanetDetail>[
      planet('Sun', sun.lon),
      planet('Moon', moonTropical),
      planet('Mars', _planetLongitude('Mars', d, sun.xs, sun.ys)),
      planet('Mercury', _planetLongitude('Mercury', d, sun.xs, sun.ys)),
      planet('Jupiter', _planetLongitude('Jupiter', d, sun.xs, sun.ys)),
      planet('Venus', _planetLongitude('Venus', d, sun.xs, sun.ys)),
      planet('Saturn', _planetLongitude('Saturn', d, sun.xs, sun.ys)),
      planet('Rahu', rahuTropical),
      planet('Ketu', _norm(rahuTropical + 180.0)),
    ];
    final double elongation = _norm(moonSidereal - sunSidereal);
    return KundliResult(
      lagna: lagna,
      lagnaDegree: formatDegree(lagnaSidereal),
      moonRashi: kRashis[_rashiIndex(moonSidereal)],
      moonNakshatra: _nakshatraName(moonSidereal),
      tithiAtBirth: _tithiName(elongation),
      planets: planets,
      place: place,
      placeApproximate: false,
      timeApproximate: !timeKnown,
    );
  }
}

/// Equation of time in minutes, standard approximation.
double _equationOfTime(DateTime date) {
  final int n =
      date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  final double b = 360.0 / 365.0 * (n - 81);
  return 9.87 * _sinD(2 * b) - 7.53 * _cosD(b) - 1.5 * _sinD(b);
}

String _formatClock(double hours) {
  double h = hours % 24.0;
  if (h < 0) h += 24.0;
  final int hour = h.floor();
  final int minute = ((h - hour) * 60.0).round();
  final int shownHour = hour % 12 == 0 ? 12 : hour % 12;
  final String suffix = hour >= 12 ? 'PM' : 'AM';
  final int fixedMinute = minute == 60 ? 0 : minute;
  final int fixedHour =
      minute == 60 ? (shownHour == 12 ? 1 : shownHour + 1) : shownHour;
  return '${fixedHour.toString().padLeft(2, '0')}:${fixedMinute.toString().padLeft(2, '0')} $suffix';
}

/// Clock text for a local time in hours, same format the
/// panchang uses. Public so the daily timings module can
/// format its windows the same way.
String formatClockHours(double hours) => _formatClock(hours);

/// Sunrise, sunset and solar noon in local clock hours.
class SunTimes {
  const SunTimes({
    required this.sunrise,
    required this.sunset,
    required this.noon,
  });

  final double sunrise;
  final double sunset;
  final double noon;
}

/// Sunrise, sunset and solar noon for a date and a place.
/// Public so the daily timings module reuses the same
/// sunrise instead of recomputing it a second way.
SunTimes sunTimesFor(DateTime day, AstroPlace place) {
  final DateTime noon =
      DateTime(day.year, day.month, day.day, 12);
  final DateTime utcNoon = noon.subtract(
    const Duration(hours: 5, minutes: 30),
  );
  final double d = _dayNumber(utcNoon);
  final ({double lon, double xs, double ys}) sun = _sunPosition(d);
  final double eps = 23.4393 - 3.563e-7 * d;
  final double decl = math.asin(
        _sinD(eps) * _sinD(sun.lon),
      ) *
      180.0 /
      math.pi;
  final double cosH = (_sinD(-0.833) -
          _sinD(place.latitude) * _sinD(decl)) /
      (_cosD(place.latitude) * _cosD(decl));
  final double clamped = cosH.clamp(-1.0, 1.0);
  final double h0 =
      math.acos(clamped) * 180.0 / math.pi / 15.0;
  // Solar noon in local clock time: 12 minus the longitude
  // difference from the IST meridian, minus the equation of
  // time. IST meridian is 82.5 degrees east.
  final double noonLocal =
      12.0 - (place.longitude - 82.5) / 15.0 - _equationOfTime(day) / 60.0;
  return SunTimes(
    sunrise: noonLocal - h0,
    sunset: noonLocal + h0,
    noon: noonLocal,
  );
}

/// Sidereal longitudes of all nine grahas at a UTC moment,
/// in degrees. Public so the gochar, festival and strength
/// modules can read positions for any date, not just a birth.
Map<String, double> siderealLongitudes(DateTime utc) {
  final double d = _dayNumber(utc);
  final double ayan = ayanamsa(d);
  final ({double lon, double xs, double ys}) sun = _sunPosition(d);
  final double moonTropical = _moonLongitude(d);
  final double rahuTropical = _rahuLongitude(d);
  return <String, double>{
    'Sun': _norm(sun.lon - ayan),
    'Moon': _norm(moonTropical - ayan),
    'Mars':
        _norm(_planetLongitude('Mars', d, sun.xs, sun.ys) - ayan),
    'Mercury':
        _norm(_planetLongitude('Mercury', d, sun.xs, sun.ys) - ayan),
    'Jupiter':
        _norm(_planetLongitude('Jupiter', d, sun.xs, sun.ys) - ayan),
    'Venus':
        _norm(_planetLongitude('Venus', d, sun.xs, sun.ys) - ayan),
    'Saturn':
        _norm(_planetLongitude('Saturn', d, sun.xs, sun.ys) - ayan),
    'Rahu': _norm(rahuTropical - ayan),
    'Ketu': _norm(rahuTropical + 180.0 - ayan),
  };
}

/// Tropical longitudes of the seven visible grahas at a UTC
/// moment, for the Western system evaluation only. Rahu and
/// Ketu have no Western counterpart and are left out.
Map<String, double> tropicalLongitudes(DateTime utc) {
  final double d = _dayNumber(utc);
  final ({double lon, double xs, double ys}) sun = _sunPosition(d);
  final double moonTropical = _moonLongitude(d);
  return <String, double>{
    'Sun': sun.lon,
    'Moon': moonTropical,
    'Mars': _planetLongitude('Mars', d, sun.xs, sun.ys),
    'Mercury': _planetLongitude('Mercury', d, sun.xs, sun.ys),
    'Jupiter': _planetLongitude('Jupiter', d, sun.xs, sun.ys),
    'Venus': _planetLongitude('Venus', d, sun.xs, sun.ys),
    'Saturn': _planetLongitude('Saturn', d, sun.xs, sun.ys),
  };
}

/// Tropical ascendant in degrees at a UTC moment for a
/// place, for the Western system evaluation only.
double tropicalAscendant(DateTime utc, AstroPlace place) {
  final double d = _dayNumber(utc);
  return _ascendant(d, place);
}

/// Local sidereal time in hours at a UTC moment for a
/// longitude east in degrees. Used by the moonrise scan.
double localSiderealTimeHours(DateTime utc, double longitudeDeg) {
  final double d = _dayNumber(utc);
  final double jd = 2451543.5 + d;
  final double gmst = _norm(
    280.46061837 + 360.98564736629 * (jd - 2451545.0),
  );
  return _norm(gmst + longitudeDeg) / 15.0;
}

/// Real daily panchang, computed from the actual date and the
/// place, not from a stored table. Sun and Moon are taken at
/// local noon. Rahu kaal follows the standard weekday table
/// counted in 1.5 hour parts from sunrise.
class PanchangCalculator {
  PanchangCalculator._();

  static Panchang forDate(DateTime day, AstroPlace place) {
    final DateTime noon =
        DateTime(day.year, day.month, day.day, 12);
    final DateTime utcNoon = noon.subtract(
      const Duration(hours: 5, minutes: 30),
    );
    final double d = _dayNumber(utcNoon);
    final double ayan = ayanamsa(d);
    final ({double lon, double xs, double ys}) sun = _sunPosition(d);
    final double moonTropical = _moonLongitude(d);
    final double sunSidereal = _norm(sun.lon - ayan);
    final double moonSidereal = _norm(moonTropical - ayan);
    final double elongation = _norm(moonSidereal - sunSidereal);

    final SunTimes times = sunTimesFor(day, place);
    final double sunrise = times.sunrise;
    final double sunset = times.sunset;
    final double noonLocal = times.noon;
    final double abhijitStart = noonLocal - 24.0 / 60.0;
    final double abhijitEnd = noonLocal + 24.0 / 60.0;

    // Rahu kaal: weekday part of the day, 1.5 hours each,
    // counted from sunrise.
    const List<int> rahuPart = <int>[1, 6, 4, 5, 3, 2, 7];
    final int part = rahuPart[day.weekday - 1];
    final double rahuStart = sunrise + part * 1.5;
    final double rahuEnd = rahuStart + 1.5;

    // Nakshatra end time: Moon longitude at the start and the
    // end of the local day, linear crossing of the next
    // nakshatra boundary.
    String nakshatra = _nakshatraName(moonSidereal);
    final DateTime startUtc = DateTime(
      day.year, day.month, day.day,
    ).subtract(const Duration(hours: 5, minutes: 30));
    final DateTime endUtc = DateTime(
      day.year, day.month, day.day,
    ).add(const Duration(days: 1)).subtract(
          const Duration(hours: 5, minutes: 30),
        );
    final double moonStart =
        _norm(_moonLongitude(_dayNumber(startUtc)) - ayanamsa(_dayNumber(startUtc)));
    final double moonEnd =
        _norm(_moonLongitude(_dayNumber(endUtc)) - ayanamsa(_dayNumber(endUtc)));
    final double boundary =
        ((moonStart ~/ (40.0 / 3.0)) + 1) * (40.0 / 3.0);
    double walked = _norm(moonEnd - moonStart);
    if (walked == 0) walked = 360.0;
    final double toBoundary = _norm(boundary - moonStart);
    if (toBoundary > 0 && toBoundary < walked) {
      final double at = toBoundary / walked * 24.0;
      nakshatra = '$nakshatra till ${_formatClock(at)}';
    }

    return Panchang(
      weekday: kWeekdays[day.weekday - 1],
      city: place.name,
      tithi: _tithiName(elongation),
      vaar: kVaars[day.weekday - 1],
      nakshatra: nakshatra,
      yoga: _yogaName(sunSidereal, moonSidereal),
      karana: _karanaName(elongation),
      sunrise: _formatClock(sunrise),
      sunset: _formatClock(sunset),
      shubhMuhurat: 'Abhijit ${_formatClock(abhijitStart)} to '
          '${_formatClock(abhijitEnd)}',
      rahuKaal: '${_formatClock(rahuStart)} to ${_formatClock(rahuEnd)}. '
          'Avoid starting new work in this window.',
    );
  }
}

/// Vimshottari Mahadasha years, in cycle order.
const List<String> kDashaOrder = <String>[
  'Ketu',
  'Venus',
  'Sun',
  'Moon',
  'Mars',
  'Rahu',
  'Jupiter',
  'Saturn',
  'Mercury',
];

const Map<String, int> kDashaYears = <String, int>{
  'Ketu': 7,
  'Venus': 20,
  'Sun': 6,
  'Moon': 10,
  'Mars': 7,
  'Rahu': 18,
  'Jupiter': 16,
  'Saturn': 19,
  'Mercury': 17,
};

/// One Mahadasha span: the ruling planet and its dates.
class DashaInfo {
  const DashaInfo({
    required this.lord,
    required this.start,
    required this.end,
  });

  final String lord;
  final DateTime start;
  final DateTime end;
}

/// Current Vimshottari Mahadasha for a birth. The Moon
/// nakshatra lord opens the cycle, with the balance set by how
/// far the Moon has travelled through that nakshatra at birth.
DashaInfo vimshottariDasha({
  required DateTime birthLocal,
  required DateTime asOf,
}) {
  // India local time: IST, with the wartime and pre 1906
  // rules from indiaUtcOffset on the IST meridian.
  final DateTime utc = birthLocal.subtract(
    indiaUtcOffset(local: birthLocal, longitude: 82.5),
  );
  final double d = _dayNumber(utc);
  final double moonSidereal =
      _norm(_moonLongitude(d) - ayanamsa(d));
  final int nakshatraIndex =
      (moonSidereal ~/ (40.0 / 3.0)) % 27;
  final String firstLord = kNakshatraLords[nakshatraIndex];
  final double travelled =
      (moonSidereal % (40.0 / 3.0)) / (40.0 / 3.0);
  final double balanceYears =
      (1.0 - travelled) * kDashaYears[firstLord]!;
  int orderIndex = kDashaOrder.indexOf(firstLord);
  DateTime start = birthLocal;
  double spanYears = balanceYears;
  for (int step = 0; step < 40; step++) {
    final String lord = kDashaOrder[orderIndex % kDashaOrder.length];
    final int days = (spanYears * 365.25).round();
    final DateTime end = start.add(Duration(days: days));
    if (!asOf.isAfter(end)) {
      return DashaInfo(lord: lord, start: start, end: end);
    }
    start = end;
    orderIndex += 1;
    spanYears =
        kDashaYears[kDashaOrder[orderIndex % kDashaOrder.length]]!
            .toDouble();
  }
  return DashaInfo(
    lord: kDashaOrder[orderIndex % kDashaOrder.length],
    start: start,
    end: start.add(const Duration(days: 365)),
  );
}

/// Full Vimshottari timeline from birth: every Mahadasha span
/// in order, covering the whole 120 year cycle. Built by
/// walking vimshottariDasha forward from birth, so the spans
/// use the same Moon nakshatra math as the current dasha.
/// The last span is cut at birth plus 120 years.
List<DashaInfo> vimshottariTimeline({required DateTime birthLocal}) {
  final DateTime cycleEnd =
      DateTime(birthLocal.year + 120, birthLocal.month, birthLocal.day);
  final List<DashaInfo> spans = <DashaInfo>[];
  DateTime cursor = birthLocal;
  for (int step = 0; step < 12; step++) {
    final DashaInfo span =
        vimshottariDasha(birthLocal: birthLocal, asOf: cursor);
    final DateTime end =
        span.end.isAfter(cycleEnd) ? cycleEnd : span.end;
    spans.add(DashaInfo(lord: span.lord, start: span.start, end: end));
    if (!end.isBefore(cycleEnd)) {
      break;
    }
    cursor = end.add(const Duration(days: 1));
  }
  return spans;
}

/// Parses the birth form text the app already uses, plus the
/// formats older stored profiles carry: date "1 January 2000",
/// "29/07/1995", "29-07-1995" and "2000-01-15"; time "07:30 AM"
/// or 24 hour "07:30". Null when the text does not parse, so
/// the form can reject it.
DateTime? parseBirthDateTime(String dateText, String timeText) {
  final DateTime? date = parseBirthDate(dateText);
  if (date == null) return null;
  final ({int hour, int minute})? time = parseBirthTime(timeText);
  if (time == null) return null;
  final DateTime parsed = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  if (parsed.year != date.year ||
      parsed.month != date.month ||
      parsed.day != date.day) {
    return null;
  }
  return parsed;
}

/// One birth date in any format the app has ever stored.
/// Null when it does not parse to a real calendar date.
DateTime? parseBirthDate(String dateText) {
  final String text = dateText.trim();
  if (text.isEmpty) return null;
  final DateTime? iso = DateTime.tryParse(text);
  if (iso != null && text.contains('-') && text.split('-').first.length == 4) {
    return DateTime(iso.year, iso.month, iso.day);
  }
  const Map<String, int> months = <String, int>{
    'January': 1, 'February': 2, 'March': 3, 'April': 4,
    'May': 5, 'June': 6, 'July': 7, 'August': 8,
    'September': 9, 'October': 10, 'November': 11,
    'December': 12,
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
    'Jun': 6, 'Jul': 7, 'Aug': 8,
    'Sep': 9, 'Sept': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };
  final List<String> slash = text.split(RegExp(r'[/-]'));
  if (slash.length == 3) {
    final int? first = int.tryParse(slash[0]);
    final int? second = int.tryParse(slash[1]);
    final int? third = int.tryParse(slash[2]);
    if (first != null && second != null && third != null) {
      if (slash[0].length == 4) {
        return _realDate(third, second, first);
      }
      return _realDate(first, second, third);
    }
  }
  final List<String> words = text.split(' ');
  if (words.length == 3) {
    final int? day = int.tryParse(words[0]);
    final int? month = months[words[1]];
    final int? year = int.tryParse(words[2]);
    if (day != null && month != null && year != null) {
      return _realDate(day, month, year);
    }
  }
  return null;
}

DateTime? _realDate(int day, int month, int year) {
  if (day < 1 || day > 31 || month < 1 || month > 12) return null;
  final DateTime date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

/// One birth time: "07:30 AM" (case does not matter, the space
/// before AM/PM is optional) or 24 hour "21:45". Null when it
/// does not parse.
({int hour, int minute})? parseBirthTime(String timeText) {
  String text = timeText.trim().toUpperCase();
  if (text.isEmpty) return null;
  bool pm = false;
  bool hasSuffix = false;
  if (text.endsWith('AM') || text.endsWith('PM')) {
    pm = text.endsWith('PM');
    hasSuffix = true;
    text = text.substring(0, text.length - 2).trim();
  }
  final List<String> hm = text.split(':');
  if (hm.length != 2) return null;
  final int? hour = int.tryParse(hm[0]);
  final int? minute = int.tryParse(hm[1]);
  if (hour == null || minute == null) return null;
  if (minute < 0 || minute > 59) return null;
  if (hasSuffix) {
    if (hour < 1 || hour > 12) return null;
    int hour24 = hour % 12;
    if (pm) hour24 += 12;
    return (hour: hour24, minute: minute);
  }
  if (hour < 0 || hour > 23) return null;
  return (hour: hour, minute: minute);
}
