import '../models/kundli.dart';
import 'astro.dart';
import 'divisional.dart';

/// Calculation contract (Phase 2). Every calculation in the
/// app goes through these three types, so a chart can be
/// reproduced from its input alone: same input and same
/// config version, same chart. Nothing here calls a network
/// service or a language model; every value is deterministic
/// math from lib/services/astro.dart and divisional.dart.
///
/// Version history:
/// 1.0.0: first contract. Lahiri ayanamsa, mean node, whole
/// sign houses, Schlyter planets. Unknown place and unknown
/// timezone are errors, never silent defaults.

/// Contract version of the calculation below.
const String kCalculationVersion = '1.0.0';

/// Birth input: a local date and time, a place, and the zone
/// that local time was read in. [utcOffsetMinutes] is the
/// offset of that zone on that date, in minutes east of UTC:
/// 330 for IST. When it is null, the engine resolves it only
/// for Asia/Kolkata through indiaUtcOffset; any other zone
/// without an explicit offset throws, because a guessed
/// offset silently moves the whole chart.
class BirthInput {
  const BirthInput({
    required this.date,
    required this.localTime,
    required this.latitude,
    required this.longitude,
    required this.ianaTimezone,
    required this.locationId,
    this.utcOffsetMinutes,
  });

  /// Local calendar date of birth.
  final DateTime date;

  /// Local wall clock time of birth on [date].
  final DateTime localTime;

  /// Degrees north, minus 90 to 90.
  final double latitude;

  /// Degrees east, minus 180 to 180.
  final double longitude;

  /// IANA zone name, for example Asia/Kolkata.
  final String ianaTimezone;

  /// Caller supplied id of the place, for example the
  /// geocoding result id. Empty when the place was entered
  /// by hand as coordinates.
  final String locationId;

  /// Minutes east of UTC on the birth date. Null only for
  /// Asia/Kolkata, where the engine knows the history.
  final int? utcOffsetMinutes;
}

/// Calculation configuration: every choice that changes the
/// chart, named up front so two charts can be compared.
class CalculationConfiguration {
  const CalculationConfiguration({
    this.ephemeris = 'schlyter',
    this.ayanamsha = AyanamshaMode.lahiri,
    this.zodiacMode = 'sidereal',
    this.houseSystem = 'wholeSign',
    this.nodeMode = NodeMode.mean,
    this.calculationVersion = kCalculationVersion,
  });

  /// Ephemeris model. schlyter is the pure Dart engine in
  /// astro.dart. No other model is implemented yet; asking
  /// for one throws.
  final String ephemeris;

  /// Ayanamsa system, default Lahiri.
  final AyanamshaMode ayanamsha;

  /// sidereal or tropical. The app only serves sidereal;
  /// tropical is accepted so reference checks can compare
  /// against JPL numbers in the same frame.
  final String zodiacMode;

  /// wholeSign is the only house system implemented. Equal
  /// house and Placidus are not computed; asking for them
  /// throws instead of returning a wrong system.
  final String houseSystem;

  /// Mean or true lunar node.
  final NodeMode nodeMode;

  /// Contract version that produced the result.
  final String calculationVersion;
}

/// One calculated chart. Planetary positions are sidereal
/// longitudes in degrees unless [CalculationConfiguration]
/// asked for tropical. Houses are whole sign houses from the
/// Lagna.
class CalculationResult {
  const CalculationResult({
    required this.utcInstant,
    required this.julianDayValue,
    required this.planetaryPositions,
    required this.ascendant,
    required this.houses,
    required this.nakshatras,
    required this.padas,
    required this.aspects,
    required this.metadata,
  });

  /// Birth instant in UTC.
  final DateTime utcInstant;

  /// Julian Day of [utcInstant].
  final double julianDayValue;

  /// Sidereal longitude per planet: Sun, Moon, Mars, Mercury,
  /// Jupiter, Venus, Saturn, Rahu, Ketu.
  final Map<String, double> planetaryPositions;

  /// Sidereal ascendant in degrees.
  final double ascendant;

  /// Whole sign houses: bhava number to sign name.
  final Map<int, String> houses;

  /// Nakshatra per planet.
  final Map<String, String> nakshatras;

  /// Nakshatra pada (1 to 4) per planet.
  final Map<String, int> padas;

  /// Vedic aspects in the chart.
  final List<PlanetAspect> aspects;

  /// Free form provenance: engine, ayanamsa value, node mode,
  /// place, config version. Nothing personal goes here.
  final Map<String, String> metadata;
}

/// Runs the contract: validates the input, resolves the UTC
/// instant, and calculates the chart from the shared engine.
class CalculationEngine {
  CalculationEngine._();

  static CalculationResult calculate({
    required BirthInput input,
    CalculationConfiguration config = const CalculationConfiguration(),
  }) {
    if (input.latitude < -90.0 || input.latitude > 90.0) {
      throw ArgumentError(
        'Latitude ${input.latitude} is outside minus 90 to 90.',
      );
    }
    if (input.longitude < -180.0 || input.longitude > 180.0) {
      throw ArgumentError(
        'Longitude ${input.longitude} is outside minus 180 to 180.',
      );
    }
    if (config.ephemeris != 'schlyter') {
      throw ArgumentError(
        'Unknown ephemeris "${config.ephemeris}". Only '
        'schlyter is implemented.',
      );
    }
    if (config.zodiacMode != 'sidereal' &&
        config.zodiacMode != 'tropical') {
      throw ArgumentError(
        'Unknown zodiac mode "${config.zodiacMode}".',
      );
    }
    if (config.houseSystem != 'wholeSign') {
      throw ArgumentError(
        'Unknown house system "${config.houseSystem}". Only '
        'wholeSign is implemented.',
      );
    }
    if (config.calculationVersion != kCalculationVersion) {
      throw ArgumentError(
        'Unknown calculation version '
        '"${config.calculationVersion}". Current version is '
        '$kCalculationVersion.',
      );
    }
    final Duration offset;
    if (input.utcOffsetMinutes != null) {
      offset = Duration(minutes: input.utcOffsetMinutes!);
    } else if (input.ianaTimezone == 'Asia/Kolkata') {
      offset = indiaUtcOffset(
        local: input.localTime,
        longitude: input.longitude,
      );
    } else {
      throw ArgumentError(
        'No UTC offset for zone "${input.ianaTimezone}". Pass '
        'utcOffsetMinutes or use Asia/Kolkata.',
      );
    }
    final DateTime utcInstant = input.localTime.subtract(offset).toUtc();
    final double dayNumber = _dayNumberFor(utcInstant);
    final double ayan = ayanamshaFor(config.ayanamsha, dayNumber);
    final AstroPlace place = AstroPlace(
      input.locationId.isEmpty ? 'manual' : input.locationId,
      input.latitude,
      input.longitude,
    );
    final double ascendantTropicalValue =
        ascendantTropical(utc: utcInstant, place: place);
    final double ascendantSidereal =
        _normDegrees(ascendantTropicalValue - ayan);
    final Map<String, double> positions = <String, double>{};
    for (final String name in <String>[
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
    ]) {
      final double tropical = tropicalLongitudeAt(
        planet: name,
        utc: utcInstant,
      );
      positions[name] = config.zodiacMode == 'tropical'
          ? tropical
          : _normDegrees(tropical - ayan);
    }
    final double rahuTropical =
        nodeLongitude(dayNumber, config.nodeMode);
    final double rahu = config.zodiacMode == 'tropical'
        ? rahuTropical
        : _normDegrees(rahuTropical - ayan);
    positions['Rahu'] = rahu;
    positions['Ketu'] = _normDegrees(rahu + 180.0);
    final int lagnaIndex = (ascendantSidereal ~/ 30.0) % 12;
    final Map<int, String> houses = <int, String>{
      for (int bhava = 1; bhava <= 12; bhava++)
        bhava: kRashis[(lagnaIndex + bhava - 1) % 12],
    };
    final Map<String, String> nakshatras = <String, String>{};
    final Map<String, int> padas = <String, int>{};
    for (final MapEntry<String, double> entry in positions.entries) {
      final int index =
          (entry.value ~/ (40.0 / 3.0)) % 27;
      nakshatras[entry.key] = kNakshatras[index];
      padas[entry.key] = nakshatraPada(entry.value);
    }
    final KundliResult kundli = _kundliForResult(
      ascendantSidereal: ascendantSidereal,
      positions: positions,
      place: place,
    );
    return CalculationResult(
      utcInstant: utcInstant,
      julianDayValue: julianDay(utcInstant),
      planetaryPositions: positions,
      ascendant: config.zodiacMode == 'tropical'
          ? ascendantTropicalValue
          : ascendantSidereal,
      houses: houses,
      nakshatras: nakshatras,
      padas: padas,
      aspects: aspectsOf(kundli),
      metadata: <String, String>{
        'engine': 'pure Dart Schlyter',
        'calculationVersion': config.calculationVersion,
        'ayanamsha': config.ayanamsha.name,
        'ayanamshaDegrees': ayan.toStringAsFixed(4),
        'nodeMode': config.nodeMode.name,
        'ephemeris': config.ephemeris,
        'zodiacMode': config.zodiacMode,
        'houseSystem': config.houseSystem,
        'ianaTimezone': input.ianaTimezone,
        'locationId': input.locationId,
      },
    );
  }

  static KundliResult _kundliForResult({
    required double ascendantSidereal,
    required Map<String, double> positions,
    required AstroPlace place,
  }) {
    final int lagnaIndex = (ascendantSidereal ~/ 30.0) % 12;
    final String lagna = kRashis[lagnaIndex];
    final List<PlanetDetail> planets = <PlanetDetail>[
      for (final MapEntry<String, double> entry in positions.entries)
        PlanetDetail(
          name: entry.key,
          rashi: kRashis[(entry.value ~/ 30.0) % 12],
          bhava: 'Bhava ${((entry.value ~/ 30.0) % 12 - lagnaIndex) % 12 + 1}',
          degree: formatDegree(entry.value),
          swami: kRashiLords[(entry.value ~/ 30.0) % 12],
          note: '',
          longitude: entry.value,
        ),
    ];
    final double moon = positions['Moon']!;
    return KundliResult(
      lagna: lagna,
      lagnaDegree: formatDegree(ascendantSidereal),
      moonRashi: kRashis[(moon ~/ 30.0) % 12],
      moonNakshatra: kNakshatras[(moon ~/ (40.0 / 3.0)) % 27],
      tithiAtBirth: '',
      planets: planets,
      place: place,
      placeApproximate: false,
      timeApproximate: false,
    );
  }
}

double _dayNumberFor(DateTime utc) {
  return julianDay(utc) - 2451543.5;
}

double _normDegrees(double degrees) {
  double value = degrees % 360.0;
  if (value < 0) value += 360.0;
  return value;
}
