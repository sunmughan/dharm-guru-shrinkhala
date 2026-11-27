import '../models/kundli.dart';
import '../models/panchang.dart';
import 'astro.dart';
import 'library_content.dart';
import 'matching.dart';
import 'numerology.dart';

/// Plain text reports the user can save, view again and share
/// from the app. There is no PDF yet: no PDF library is in
/// pubspec, so the report is text saved in Firestore under
/// users/{uid}/reports, with a history list. A PDF export is
/// remaining work, not a hidden fake. Every report is built
/// only from inputs the user already has: a computed kundli,
/// a matching result, a panchang, or a numerology result.
class ReportBuilder {
  ReportBuilder._();

  static String kundli({
    required String name,
    required String birthLine,
    required KundliResult kundli,
    required DateTime birthLocal,
    required DateTime asOf,
  }) {
    final DashaInfo dasha = vimshottariDasha(
      birthLocal: birthLocal,
      asOf: asOf,
    );
    final List<String> lines = <String>[
      'Dharm Guru Shrinkhala: Kundli Report',
      'Name: $name',
      'Birth: $birthLine',
      'Lagna: ${kundli.lagna} (${kundli.lagnaDegree})',
      'Moon rashi: ${kundli.moonRashi}',
      'Moon nakshatra: ${kundli.moonNakshatra}',
      'Tithi at birth: ${kundli.tithiAtBirth}',
      '',
      'Planets:',
    ];
    for (final PlanetDetail p in kundli.planets) {
      lines.add('${p.name}: ${p.rashi}, ${p.bhava}, ${p.degree}.');
    }
    lines.add('');
    lines.add(
      'Current Mahadasha: ${dasha.lord}, '
      '${formatDay(dasha.start)} to ${formatDay(dasha.end)}.',
    );
    if (kundli.timeApproximate) {
      lines.add('Note: birth time was not known, so noon was used and the lagna is approximate.');
    }
    if (kundli.placeApproximate) {
      lines.add('Note: birth place matched no city, so Jaipur coordinates were used.');
    }
    return lines.join('\n');
  }

  static String matching({
    required String firstName,
    required String secondName,
    required MatchingResult result,
  }) {
    final List<String> lines = <String>[
      'Dharm Guru Shrinkhala: Kundli Matching Report',
      'First person: $firstName',
      'Second person: $secondName',
      'Guna Milan score: ${result.totalText}',
      'Verdict: ${result.verdict}',
      '',
      'Kootas:',
    ];
    for (final GunaScore row in result.rows) {
      lines.add('${row.label}: ${gunaScoreText(row)}. ${row.note}');
    }
    lines.add('');
    lines.add('Mangal Dosha $firstName: ${result.mangalFirst ? 'Present' : 'None'}.');
    lines.add('Mangal Dosha $secondName: ${result.mangalSecond ? 'Present' : 'None'}.');
    return lines.join('\n');
  }

  static String panchang({
    required DateTime date,
    required Panchang panchang,
    required List<FestivalDay> festivals,
  }) {
    final List<String> lines = <String>[
      'Dharm Guru Shrinkhala: Panchang Report',
      'Date: ${formatDay(date)}',
      'City: ${panchang.city}',
      'Tithi: ${panchang.tithi}',
      'Vaar: ${panchang.vaar}',
      'Nakshatra: ${panchang.nakshatra}',
      'Yoga: ${panchang.yoga}',
      'Karana: ${panchang.karana}',
      'Sunrise: ${panchang.sunrise}',
      'Sunset: ${panchang.sunset}',
      'Shubh Muhurat: ${panchang.shubhMuhurat}',
      'Rahu Kaal: ${panchang.rahuKaal}',
    ];
    if (festivals.isNotEmpty) {
      lines.add('');
      lines.add('Festival days in the next 30 days:');
      for (final FestivalDay f in festivals) {
        lines.add('${formatDay(f.date)}: ${f.tithi}, ${f.observance}.');
      }
    }
    return lines.join('\n');
  }

  static String numerology({
    required String fullName,
    required String dateOfBirth,
    required NumerologyResult result,
  }) {
    final List<String> lines = <String>[
      'Dharm Guru Shrinkhala: Numerology Report',
      'Name: $fullName',
      'Date of birth: $dateOfBirth',
      'Life Path: ${result.lifePath}',
      'Destiny: ${result.destiny}',
      'Soul Urge: ${result.soulUrge}',
      'Personality: ${result.personality}',
      'Birth Day: ${result.birthDay}',
      'Personal Year: ${result.personalYear}',
      '',
    ];
    for (final MapEntry<String, int> entry in <String, int>{
      'Life Path': result.lifePath,
      'Destiny': result.destiny,
      'Soul Urge': result.soulUrge,
      'Personality': result.personality,
      'Birth Day': result.birthDay,
      'Personal Year': result.personalYear,
    }.entries) {
      lines.add('${entry.key} ${entry.value}: ${kNumerologyMeanings[entry.value] ?? ''}');
    }
    lines.add('');
    lines.add('Numerology numbers are digit sums from the name and date of birth. They are reference guidance only.');
    return lines.join('\n');
  }
}
