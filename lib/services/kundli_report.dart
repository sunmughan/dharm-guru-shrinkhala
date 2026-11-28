import '../models/kundli.dart';
import 'astro.dart';

/// Report format version, printed on every page of the PDF.
/// This is the report format, not the app version, so it only
/// changes when the report layout or content changes.
const String kKundliReportVersion = '1.0';

/// Everything the PDF builder needs, built from the real
/// calculation only. No value here is invented: birth details
/// come from the user, planets and lagna come from
/// KundliCalculator, and the date is the generation time.
class KundliReportData {
  const KundliReportData({
    required this.birth,
    required this.kundli,
    required this.chartKind,
    required this.generatedAt,
    this.reportVersion = kKundliReportVersion,
  });

  final BirthDetails birth;
  final KundliResult kundli;

  /// 'Lagna Chart' or 'Moon Chart', whichever the user had open.
  final String chartKind;
  final DateTime generatedAt;
  final String reportVersion;

  /// Generation date as plain text, for example 28 Nov 2026 01:15.
  /// Month names are spelled out so the label never needs a
  /// separator character.
  String get generatedLabel {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final String day = generatedAt.day.toString().padLeft(2, '0');
    final String hour = generatedAt.hour.toString().padLeft(2, '0');
    final String minute = generatedAt.minute.toString().padLeft(2, '0');
    return '$day ${months[generatedAt.month - 1]} '
        '${generatedAt.year} $hour:$minute';
  }

  /// Birth time as shown in the report. An empty time means the
  /// user did not know it, so the report says so plainly.
  String get timeLabel {
    if (birth.timeOfBirth.isEmpty) {
      return 'Not known, noon used';
    }
    return birth.timeOfBirth;
  }

  /// Calculation configuration lines, from the real engine inputs.
  /// The engine uses the Lahiri ayanamsa and sidereal longitudes,
  /// see lib/services/astro.dart.
  List<List<String>> get configRows {
    final List<List<String>> rows = <List<String>>[
      <String>[
        'Place used',
        '${kundli.place.name} '
            '(${kundli.place.latitude}, ${kundli.place.longitude})',
      ],
      <String>['Ayanamsa', 'Lahiri, sidereal longitudes'],
      <String>['Chart', chartKind],
      <String>['Lagna', '${kundli.lagna} at ${kundli.lagnaDegree}'],
      <String>['Moon rashi', kundli.moonRashi],
      <String>['Nakshatra', kundli.moonNakshatra],
      <String>['Tithi at birth', kundli.tithiAtBirth],
    ];
    if (kundli.placeApproximate) {
      rows.add(<String>[
        'Place note',
        'Place not found in the city list, Jaipur coordinates used, '
            'so the result is approximate.',
      ]);
    }
    if (kundli.timeApproximate) {
      rows.add(<String>[
        'Time note',
        'Birth time not known, noon used, so the lagna is approximate.',
      ]);
    }
    return rows;
  }

  /// One factual line per planet, from the engine output.
  /// These are positions, not predictions.
  List<String> get planetLines {
    return kundli.planets.map((PlanetDetail p) => p.note).toList();
  }
}

/// Builds report data from the birth details the user entered
/// and the kundli the engine calculated for them.
KundliReportData buildKundliReportData({
  required BirthDetails birth,
  required KundliResult kundli,
  required String chartKind,
  DateTime? generatedAt,
}) {
  return KundliReportData(
    birth: birth,
    kundli: kundli,
    chartKind: chartKind,
    generatedAt: generatedAt ?? DateTime.now(),
  );
}
