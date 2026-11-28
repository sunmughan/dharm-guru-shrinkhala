import '../models/kundli.dart';
import 'astro.dart';

/// Navamsa, the D9 divisional chart. Each rashi is split into
/// nine parts of 3 degrees 20 minutes. The starting rashi of
/// the nine depends on the sign type: movable signs start at
/// the sign itself, fixed signs start nine signs ahead, dual
/// signs start five signs ahead. Only D9 is computed here.
/// The other fifteen divisional charts are not computed yet
/// and are not shown as if they were.
class Divisional {
  Divisional._();

  /// Degrees inside the rashi, parsed from the engine degree
  /// text "DD° MM′". Returns 0 when the text does not parse.
  static double degreesWithinRashi(String degreeText) {
    final RegExpMatch? match =
        RegExp(r'(\d+)\D+(\d+)').firstMatch(degreeText);
    if (match == null) return 0;
    final int deg = int.tryParse(match.group(1)!) ?? 0;
    final int min = int.tryParse(match.group(2)!) ?? 0;
    return deg + min / 60.0;
  }

  /// Absolute sidereal longitude 0 to 360 for one planet.
  static double longitudeOf(PlanetDetail planet) {
    final int sign = kRashis.indexOf(planet.rashi);
    if (sign < 0) return 0;
    return sign * 30.0 + degreesWithinRashi(planet.degree);
  }

  /// Navamsa rashi for one absolute longitude.
  static String navamsaRashi(double longitude) {
    final double lon = longitude % 360.0;
    final int sign = (lon ~/ 30.0) % 12;
    final double within = lon % 30.0;
    final int part = (within ~/ (30.0 / 9.0)).clamp(0, 8);
    final int start = switch (sign % 3) {
      // Movable: Mesha, Karka, Tula, Makara start at the sign.
      0 => 0,
      // Fixed: Vrishabha, Simha, Vrishchika, Kumbha start 9th.
      1 => 8,
      // Dual: Mithuna, Kanya, Dhanu, Meena start 5th.
      _ => 4,
    };
    return kRashis[(sign + start + part) % 12];
  }

  /// Navamsa lagna rashi for a kundli, from the lagna degree.
  static String navamsaLagna(KundliResult kundli) {
    final int sign = kRashis.indexOf(kundli.lagna);
    if (sign < 0) return kundli.lagna;
    final double lon =
        sign * 30.0 + degreesWithinRashi(kundli.lagnaDegree);
    return navamsaRashi(lon);
  }

  /// Full D9 chart: every planet moved to its navamsa rashi,
  /// with bhavas counted from the navamsa lagna.
  static KundliResult navamsaChart(KundliResult kundli) {
    final String lagna = navamsaLagna(kundli);
    final int lagnaIndex = kRashis.indexOf(lagna);
    final List<PlanetDetail> moved = kundli.planets.map((PlanetDetail p) {
      final String rashi = navamsaRashi(longitudeOf(p));
      final int sign = kRashis.indexOf(rashi);
      final int bhava = ((sign - lagnaIndex) % 12 + 12) % 12 + 1;
      return PlanetDetail(
        name: p.name,
        rashi: rashi,
        bhava: 'Bhava $bhava',
        degree: p.degree,
        swami: p.swami,
        note: '${p.name} in navamsa $rashi, Bhava $bhava.',
      );
    }).toList();
    return KundliResult(
      lagna: lagna,
      lagnaDegree: kundli.lagnaDegree,
      moonRashi: navamsaRashi(longitudeOf(
        kundli.planets.firstWhere(
          (PlanetDetail p) => p.name == 'Moon',
          orElse: () => kundli.planets.first,
        ),
      )),
      moonNakshatra: kundli.moonNakshatra,
      tithiAtBirth: kundli.tithiAtBirth,
      planets: moved,
      place: kundli.place,
      placeApproximate: kundli.placeApproximate,
      timeApproximate: kundli.timeApproximate,
    );
  }
}
