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
/// shortcut: places outside the city list fall back to Jaipur
/// coordinates and the result is marked approximate. Add the
/// city to the list when a user reports it.
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
  /// coordinates were used instead.
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
class KundliCalculator {
  KundliCalculator._();

  static KundliResult calculate({
    required DateTime birthLocal,
    required String placeText,
    bool timeKnown = true,
  }) {
    final AstroPlace? found = placeFor(placeText);
    final AstroPlace place = found ?? kDefaultPlace;
    final DateTime local = timeKnown
        ? birthLocal
        : DateTime(
            birthLocal.year, birthLocal.month, birthLocal.day, 12,
          );
    // India is IST, UTC plus 5 hours 30 minutes.
    final DateTime utc = local.subtract(
      const Duration(hours: 5, minutes: 30),
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
      placeApproximate: found == null,
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

    // Sunrise and sunset from the solar declination.
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
    final double sunrise = noonLocal - h0;
    final double sunset = noonLocal + h0;
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
  final DateTime utc = birthLocal.subtract(
    const Duration(hours: 5, minutes: 30),
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

/// Parses the birth form text the app already uses:
/// date "1 January 2000", time "07:30 AM". Null when the
/// text does not parse, so the form can reject it.
DateTime? parseBirthDateTime(String dateText, String timeText) {
  final List<String> dateBits = dateText.trim().split(' ');
  if (dateBits.length != 3) return null;
  const Map<String, int> months = <String, int>{
    'January': 1, 'February': 2, 'March': 3, 'April': 4,
    'May': 5, 'June': 6, 'July': 7, 'August': 8,
    'September': 9, 'October': 10, 'November': 11,
    'December': 12,
  };
  final int? month = months[dateBits[1]];
  final int? day = int.tryParse(dateBits[0]);
  final int? year = int.tryParse(dateBits[2]);
  if (month == null || day == null || year == null) return null;
  final List<String> timeBits = timeText.trim().split(' ');
  if (timeBits.length != 2) return null;
  final List<String> hm = timeBits[0].split(':');
  if (hm.length != 2) return null;
  final int? hour12 = int.tryParse(hm[0]);
  final int? minute = int.tryParse(hm[1]);
  if (hour12 == null || minute == null) return null;
  if (hour12 < 1 || hour12 > 12 || minute < 0 || minute > 59) return null;
  final String suffix = timeBits[1].toUpperCase();
  if (suffix != 'AM' && suffix != 'PM') return null;
  if (day < 1 || day > 31) return null;
  int hour = hour12 % 12;
  if (suffix == 'PM') hour += 12;
  final DateTime parsed = DateTime(year, month, day, hour, minute);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return parsed;
}
