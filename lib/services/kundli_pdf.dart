import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/kundli.dart';
import 'astro.dart';
import 'kundli_report.dart';

/// Fonts embedded in every report. Roboto Regular and Bold live
/// in assets/fonts, Apache 2.0, see assets/fonts/NOTE.md.
/// Embedded fonts mean the report reads the same on any reader,
/// on web and on native, with no download at open time.
class KundliPdfFonts {
  const KundliPdfFonts({
    required this.regular,
    required this.bold,
  });

  final pw.Font regular;
  final pw.Font bold;

  /// Loads the bundled fonts through the Flutter asset bundle.
  static Future<KundliPdfFonts> load() async {
    final ByteData regularData =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ByteData boldData =
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    return KundliPdfFonts.fromBytes(
      regularData.buffer.asUint8List(),
      boldData.buffer.asUint8List(),
    );
  }

  /// Builds the fonts from raw bytes. Tests load the same files
  /// from disk, so the test build uses the real embedded fonts.
  factory KundliPdfFonts.fromBytes(
    Uint8List regularBytes,
    Uint8List boldBytes,
  ) {
    return KundliPdfFonts(
      regular: pw.Font.ttf(ByteData.sublistView(regularBytes)),
      bold: pw.Font.ttf(ByteData.sublistView(boldBytes)),
    );
  }

  /// One shared font for both weights. Tests use this for the
  /// content check: one font means one subset and one
  /// ToUnicode map, so byte level text checks stay exact.
  /// Two fonts would share glyph ids with different mappings.
  factory KundliPdfFonts.single(Uint8List bytes) {
    final pw.Font font = pw.Font.ttf(ByteData.sublistView(bytes));
    return KundliPdfFonts(regular: font, bold: font);
  }
}

/// Kundli PDF report, built only from KundliReportData.
/// MultiPage flows the content across pages by itself, so long
/// planet lists paginate instead of overflowing. Every page
/// carries the report version and generation date in the footer.
class KundliPdfBuilder {
  KundliPdfBuilder._();

  static const PdfColor _saffron = PdfColor(1.0, 0.51, 0.02);

  /// Bhava number for each chart cell, row by row, left to right.
  /// Same grid as the on screen KundliChart widget: top row
  /// 3, 2, 1, 12, middle rows 4 and 11 then 5 and 10, bottom row
  /// 6, 7, 8, 9. The middle rows share one centre cell.
  static const List<List<int>> _bhavaGrid = <List<int>>[
    <int>[3, 2, 1, 12],
    <int>[4, 11],
    <int>[5, 10],
    <int>[6, 7, 8, 9],
  ];

  /// Builds the report bytes. Pass fonts to embed the bundled
  /// Roboto fonts. Without fonts the standard Helvetica fonts
  /// are used instead, which keeps the content test readable as
  /// plain text. The default build is compressed.
  static Future<Uint8List> build(
    KundliReportData data, {
    KundliPdfFonts? fonts,
    bool compress = true,
  }) async {
    final pw.Font regular = fonts?.regular ?? pw.Font.helvetica();
    final pw.Font bold = fonts?.bold ?? pw.Font.helveticaBold();
    pw.TextStyle titleStyle(double size) =>
        pw.TextStyle(font: bold, fontSize: size, color: _saffron);
    pw.TextStyle headStyle(double size) =>
        pw.TextStyle(font: bold, fontSize: size);
    pw.TextStyle bodyStyle(double size) =>
        pw.TextStyle(font: regular, fontSize: size);

    final pw.Document doc = pw.Document(compress: compress);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'Dharm Guru Shrinkhala',
                style: titleStyle(16),
              ),
              pw.Text(
                'Birth Kundli Report, ${data.chartKind}, '
                'Report v${data.reportVersion}',
                style: bodyStyle(10),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(color: _saffron, thickness: 1),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: <pw.Widget>[
              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'Generated ${data.generatedLabel}, '
                    'Report v${data.reportVersion}',
                    style: bodyStyle(8),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: bodyStyle(8),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Text(data.birth.name, style: titleStyle(20)),
            pw.SizedBox(height: 12),
            _sectionTitle('Birth details', headStyle(13)),
            _kvTable(
              <List<String>>[
                <String>['Name', data.birth.name],
                <String>['Date of birth', data.birth.dateOfBirth],
                <String>['Time of birth', data.timeLabel],
                <String>['Place of birth', data.birth.placeOfBirth],
                <String>['Moon rashi', data.birth.rashi],
                <String>['Nakshatra', data.birth.nakshatra],
                <String>['Tithi at birth', data.birth.tithiAtBirth],
              ],
              bodyStyle(10),
              headStyle(10),
            ),
            pw.SizedBox(height: 14),
            _sectionTitle('Calculation configuration', headStyle(13)),
            _kvTable(data.configRows, bodyStyle(10), headStyle(10)),
            pw.SizedBox(height: 14),
            _sectionTitle(
              'North Indian chart, ${data.chartKind}',
              headStyle(13),
            ),
            pw.SizedBox(height: 6),
            _chart(data, regular, bold),
            pw.SizedBox(height: 14),
            _sectionTitle('Planetary positions', headStyle(13)),
            pw.SizedBox(height: 6),
            _planetTable(data, bodyStyle(9), headStyle(9)),
            pw.SizedBox(height: 14),
            _sectionTitle('Planetary explanations', headStyle(13)),
            pw.SizedBox(height: 6),
            pw.Text(
              'Lagna ${data.kundli.lagna} at ${data.kundli.lagnaDegree}. '
              'Moon in ${data.kundli.moonRashi}, '
              '${data.kundli.moonNakshatra}. '
              'Tithi at birth ${data.kundli.tithiAtBirth}.',
              style: bodyStyle(10),
            ),
            pw.SizedBox(height: 8),
            ...data.planetLines.map(
              (String line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(line, style: bodyStyle(10)),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Calculated from the birth details above. Positions are '
              'sidereal longitudes with the Lahiri ayanamsa.',
              style: bodyStyle(9),
            ),
          ];
        },
      ),
    );
    return doc.save();
  }

  static pw.Widget _sectionTitle(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(text, style: style),
    );
  }

  static pw.Widget _kvTable(
    List<List<String>> rows,
    pw.TextStyle bodyStyle,
    pw.TextStyle headStyle,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: <int, pw.TableColumnWidth>{
        0: const pw.FixedColumnWidth(130),
        1: const pw.FlexColumnWidth(),
      },
      children: rows
          .map(
            (List<String> row) => pw.TableRow(
              children: <pw.Widget>[
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(row[0], style: headStyle),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text(row[1], style: bodyStyle),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  static pw.Widget _chart(
    KundliReportData data,
    pw.Font regular,
    pw.Font bold,
  ) {
    final int lagnaIndex = kRashis.indexOf(data.kundli.lagna);
    final int start = lagnaIndex < 0 ? 11 : lagnaIndex;
    String rashiForBhava(int bhava) {
      return kRashis[(start + bhava - 1) % 12];
    }

    List<String> planetsInBhava(int bhava) {
      final List<String> found = <String>[];
      if (bhava == 1) {
        found.add('As');
      }
      for (final PlanetDetail planet in data.kundli.planets) {
        if (planet.bhava == 'Bhava $bhava') {
          final String? abbr = kPlanetAbbreviations[planet.name];
          if (abbr != null) {
            found.add(abbr);
          }
        }
      }
      return found;
    }

    pw.Widget cell(int bhava) {
      return pw.Expanded(
        child: pw.Container(
          height: 64,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.5),
          ),
          padding: const pw.EdgeInsets.all(4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                rashiForBhava(bhava),
                style: pw.TextStyle(font: bold, fontSize: 9),
              ),
              pw.Text(
                planetsInBhava(bhava).join(' '),
                style: pw.TextStyle(font: regular, fontSize: 9),
              ),
            ],
          ),
        ),
      );
    }

    final pw.Widget centre = pw.Expanded(
      flex: 2,
      child: pw.Container(
        height: 64,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.5),
        ),
        padding: const pw.EdgeInsets.all(4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: <pw.Widget>[
            pw.Text(
              'Lagna ${data.kundli.lagna}',
              style: pw.TextStyle(font: bold, fontSize: 9),
            ),
            pw.Text(
              data.kundli.moonRashi,
              style: pw.TextStyle(font: regular, fontSize: 9),
            ),
            pw.Text(
              data.kundli.moonNakshatra,
              style: pw.TextStyle(font: regular, fontSize: 8),
            ),
          ],
        ),
      ),
    );

    return pw.Column(
      children: <pw.Widget>[
        pw.Row(children: <pw.Widget>[
          cell(_bhavaGrid[0][0]),
          cell(_bhavaGrid[0][1]),
          cell(_bhavaGrid[0][2]),
          cell(_bhavaGrid[0][3]),
        ]),
        pw.Row(children: <pw.Widget>[
          cell(_bhavaGrid[1][0]),
          centre,
          cell(_bhavaGrid[1][1]),
        ]),
        pw.Row(children: <pw.Widget>[
          cell(_bhavaGrid[2][0]),
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              height: 64,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
            ),
          ),
          cell(_bhavaGrid[2][1]),
        ]),
        pw.Row(children: <pw.Widget>[
          cell(_bhavaGrid[3][0]),
          cell(_bhavaGrid[3][1]),
          cell(_bhavaGrid[3][2]),
          cell(_bhavaGrid[3][3]),
        ]),
      ],
    );
  }

  static pw.Widget _planetTable(
    KundliReportData data,
    pw.TextStyle bodyStyle,
    pw.TextStyle headStyle,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: <String>['Planet', 'Rashi', 'Bhava', 'Degree', 'Lord'],
      data: data.kundli.planets
          .map(
            (PlanetDetail p) => <String>[
              p.name,
              p.rashi,
              p.bhava,
              p.degree,
              p.swami,
            ],
          )
          .toList(),
      headerStyle: headStyle,
      cellStyle: bodyStyle,
      border: pw.TableBorder.all(width: 0.5),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
      ),
    );
  }
}
