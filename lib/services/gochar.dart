import '../models/kundli.dart';
import 'astro.dart';

/// Current transits (Gochar) and Sade Sati, computed from the
/// real engine for today. Transits are the planets as they
/// stand today at noon at the birth place. Sade Sati is the
/// standard rule: Saturn transiting the rashi before, in, or
/// after the Moon rashi. No transit is presented as a
/// prediction; the screen shows positions and the Sade Sati
/// phase only.
class GocharReading {
  const GocharReading({
    required this.asOf,
    required this.transit,
    required this.saturnRashi,
    required this.jupiterRashi,
    required this.sadeSatiActive,
    required this.sadeSatiPhase,
  });

  final DateTime asOf;
  final KundliResult transit;
  final String saturnRashi;
  final String jupiterRashi;
  final bool sadeSatiActive;

  /// Rising, Peak, Setting, or empty when not active.
  final String sadeSatiPhase;
}

class Gochar {
  Gochar._();

  static String _planetRashi(KundliResult chart, String name) {
    for (final PlanetDetail p in chart.planets) {
      if (p.name == name) return p.rashi;
    }
    return '';
  }

  /// Sade Sati phase for a Moon rashi and a Saturn rashi.
  /// Saturn one sign before the Moon is Rising, in the Moon
  /// sign is Peak, one sign after is Setting, anything else
  /// is not Sade Sati.
  static String sadeSatiPhase({
    required String moonRashi,
    required String saturnRashi,
  }) {
    final int moon = kRashis.indexOf(moonRashi);
    final int saturn = kRashis.indexOf(saturnRashi);
    if (moon < 0 || saturn < 0) return '';
    final int diff = (saturn - moon + 12) % 12;
    return switch (diff) {
      11 => 'Rising',
      0 => 'Peak',
      1 => 'Setting',
      _ => '',
    };
  }

  /// Transit bhava of a transit rashi counted from the natal
  /// lagna, 1 to 12.
  static int transitBhava({
    required String transitRashi,
    required String natalLagna,
  }) {
    final int transit = kRashis.indexOf(transitRashi);
    final int lagna = kRashis.indexOf(natalLagna);
    if (transit < 0 || lagna < 0) return 0;
    return ((transit - lagna) % 12 + 12) % 12 + 1;
  }

  static GocharReading forDate({
    required KundliResult natal,
    required DateTime asOf,
  }) {
    final KundliResult transit = KundliCalculator.calculate(
      birthLocal: DateTime(asOf.year, asOf.month, asOf.day, 12),
      placeText: natal.place.name,
      timeKnown: true,
    );
    final String saturn = _planetRashi(transit, 'Saturn');
    final String jupiter = _planetRashi(transit, 'Jupiter');
    final String phase = sadeSatiPhase(
      moonRashi: natal.moonRashi,
      saturnRashi: saturn,
    );
    return GocharReading(
      asOf: asOf,
      transit: transit,
      saturnRashi: saturn,
      jupiterRashi: jupiter,
      sadeSatiActive: phase.isNotEmpty,
      sadeSatiPhase: phase,
    );
  }
}
