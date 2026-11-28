import 'astro.dart';

/// Phase 6 other systems evaluation: Jaimini, KP, Lal
/// Kitab and Western, kept as separate modules. The rule is
/// simple: no system borrows rules from another without
/// saying so. Each entry states what the system needs, what
/// this app already computes that it can use, what is still
/// missing, and the verdict. Only the Western tropical
/// signs are computed here, because they need nothing more
/// than the tropical longitudes the engine already
/// produces; the other three are evaluated, not
/// implemented, and their gaps name the work a future
/// phase would have to do.

/// Evaluation of one other system.
class SystemEvaluation {
  const SystemEvaluation({
    required this.name,
    required this.status,
    required this.needs,
    required this.available,
    required this.gaps,
    required this.verdict,
  });

  final String name;

  /// Evaluated only, or Partially available.
  final String status;

  /// What the system needs to work.
  final String needs;

  /// What this app already computes that it can use.
  final String available;

  /// What is still missing.
  final String gaps;

  final String verdict;
}

/// Evaluations for Jaimini, KP, Lal Kitab and Western.
List<SystemEvaluation> evaluateOtherSystems() =>
    const <SystemEvaluation>[
      SystemEvaluation(
        name: 'Jaimini',
        status: 'Evaluated only',
        needs:
            'Chara karakas from planet degrees, rashi dasha (Chara dasha), '
            'pada and argala rules, all in the Jaimini system.',
        available:
            'Sidereal planet longitudes and the lagna from the engine.',
        gaps:
            'Chara karaka order, rashi dasha sequence, pada computation and '
            'argala are not implemented. Jaimini dasha is sign based, not '
            'the Vimshottari nakshatra balance used here.',
        verdict:
            'Separate module. Do not mix Jaimini dasha with Vimshottari; '
            'build it on its own rashi dasha rules when the astrologer '
            'confirms the Jaimini school to follow.',
      ),
      SystemEvaluation(
        name: 'KP',
        status: 'Evaluated only',
        needs:
            'Placidus house cusps, star lords and sub lords for every '
            'cusp and planet, KP ayanamsa, and the KP significator rules.',
        available:
            'Sidereal planet longitudes from the engine; the whole sign '
            'houses used here are not Placidus cusps.',
        gaps:
            'Placidus cusp computation, sub lord tables, KP ayanamsa '
            'choice, and significator logic are not implemented.',
        verdict:
            'Separate module. Do not present whole sign houses as KP '
            'cusps; build the Placidus and sub lord computation first.',
      ),
      SystemEvaluation(
        name: 'Lal Kitab',
        status: 'Evaluated only',
        needs:
            'Lal Kitab own house and planet rules, its debt and remedy '
            'system, and the Varshphal annual chart.',
        available:
            'Sidereal planet longitudes and houses from the engine.',
        gaps:
            'Lal Kitab reads the same houses by different rules, so its '
            'house meanings, its blind planet rules and Varshphal are not '
            'implemented.',
        verdict:
            'Separate module. Do not reuse the Parashari house meanings '
            'for Lal Kitab; build it on the Lal Kitab text rules.',
      ),
      SystemEvaluation(
        name: 'Western',
        status: 'Partially available',
        needs:
            'Tropical longitudes, tropical houses, and aspects; the '
            'Western reading of signs and houses.',
        available:
            'Tropical longitudes of the seven visible planets and the '
            'tropical ascendant, from the same engine.',
        gaps:
            'Tropical houses, aspects and Western interpretation are not '
            'implemented. Only the tropical signs are shown.',
        verdict:
            'Tropical signs only, clearly labelled Western. No Western '
            'house or aspect reading is mixed into the Vedic chart.',
      ),
    ];

/// Western tropical signs, Aries first.
const List<String> kWesternSigns = <String>[
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

/// Western tropical sign of each visible planet at a UTC
/// moment, plus the tropical ascendant sign for a place.
Map<String, String> westernSigns(
  DateTime utc,
  AstroPlace place,
) {
  final Map<String, double> longs = tropicalLongitudes(utc);
  final Map<String, String> out = <String, String>{
    for (final MapEntry<String, double> e in longs.entries)
      e.key: kWesternSigns[(e.value ~/ 30.0) % 12],
  };
  final double asc = tropicalAscendant(utc, place);
  out['Ascendant'] = kWesternSigns[(asc ~/ 30.0) % 12];
  return out;
}
