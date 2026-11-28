import '../models/kundli.dart';
import 'astro.dart';

/// Rule based horoscope periods. The daily horoscope stays
/// published content only. Weekly, monthly and yearly views
/// are built from three real inputs only: the Moon rashi, the
/// current Vimshottari Mahadasha lord, and the Saturn transit
/// rashi. The text says which inputs it used, so it is never
/// mistaken for a published prediction.
class HoroscopePeriods {
  HoroscopePeriods._();

  static const Map<String, String> _lordFocus = <String, String>{
    'Sun': 'authority, father and self respect',
    'Moon': 'mind, emotions and home',
    'Mars': 'energy, courage and property',
    'Mercury': 'speech, learning and trade',
    'Jupiter': 'wisdom, fortune and teachers',
    'Venus': 'love, comfort and beauty',
    'Saturn': 'discipline, patience and service',
    'Rahu': 'ambition and sudden change',
    'Ketu': 'detachment and inner insight',
  };

  static String periodText({
    required String period,
    required String moonRashi,
    required String dashaLord,
    required String saturnRashi,
  }) {
    final String focus = _lordFocus[dashaLord] ?? 'daily duties';
    final String span = switch (period) {
      'weekly' => 'This week',
      'monthly' => 'This month',
      'yearly' => 'This year',
      _ => 'Today',
    };
    return '$span, with Moon rashi $moonRashi and the $dashaLord '
        'Mahadasha running, the focus is $focus. Saturn is '
        'transiting $saturnRashi. This is rule based guidance '
        'from your Moon rashi and current dasha lord, not a '
        'published prediction.';
  }

  /// Period text for a birth chart on [asOf], or an empty
  /// string when the birth date does not parse.
  static String forBirth({
    required String period,
    required DateTime birthLocal,
    required String placeText,
    required DateTime asOf,
  }) {
    final KundliResult kundli = KundliCalculator.calculate(
      birthLocal: birthLocal,
      placeText: placeText,
    );
    final DashaInfo dasha = vimshottariDasha(
      birthLocal: birthLocal,
      asOf: asOf,
    );
    final KundliResult transit = KundliCalculator.calculate(
      birthLocal: DateTime(asOf.year, asOf.month, asOf.day, 12),
      placeText: placeText,
      timeKnown: true,
    );
    String saturn = '';
    for (final PlanetDetail p in transit.planets) {
      if (p.name == 'Saturn') saturn = p.rashi;
    }
    return periodText(
      period: period,
      moonRashi: kundli.moonRashi,
      dashaLord: dasha.lord,
      saturnRashi: saturn,
    );
  }
}
