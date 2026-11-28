import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/dasha_detail.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 6 sub dasha tests, on the sample birth used across
/// the suite: 14 March 1998, 06:25 AM IST, Jaipur. The
/// Mahadasha opens with Sun, per the library test.

void main() {
  final DateTime birth = DateTime(1998, 3, 14, 6, 25);

  group('splitDasha', () {
    test('Antardashas cover the Mahadasha exactly, in order', () {
      final DateTime asOf = DateTime(2026, 11, 27);
      final DashaInfo maha =
          vimshottariDasha(birthLocal: birth, asOf: asOf);
      final List<SubDashaSpan> antars =
          splitDasha(maha, maha.lord, 'Antardasha');
      expect(antars.length, 9);
      expect(antars.first.lord, maha.lord);
      expect(antars.first.start, maha.start);
      expect(antars.last.end, maha.end);
      for (int i = 1; i < antars.length; i++) {
        expect(antars[i].start, antars[i - 1].end);
        final int prevOrder = kDashaOrder.indexOf(antars[i - 1].lord);
        expect(
          antars[i].lord,
          kDashaOrder[(prevOrder + 1) % kDashaOrder.length],
        );
      }
      final int totalDays = antars.fold(
        0,
        (int sum, SubDashaSpan s) => sum + s.end.difference(s.start).inDays,
      );
      expect(totalDays, maha.end.difference(maha.start).inDays);
    });

    test('the first Antardasha is the longest for a Venus Mahadasha', () {
      final DashaInfo span = DashaInfo(
        lord: 'Venus',
        start: DateTime(2030, 1, 1),
        end: DateTime(2050, 1, 1),
      );
      final List<SubDashaSpan> parts =
          splitDasha(span, 'Venus', 'Antardasha');
      expect(parts.first.lord, 'Venus');
      final int venusDays =
          parts.first.end.difference(parts.first.start).inDays;
      final int totalDays = span.end.difference(span.start).inDays;
      expect(venusDays / totalDays, closeTo(20 / 120, 0.01));
    });
  });

  group('dashaDetail', () {
    test('current levels nest inside each other and hold the date', () {
      final DateTime asOf = DateTime(2026, 11, 27);
      final DashaDetail detail =
          dashaDetail(birthLocal: birth, asOf: asOf);
      expect(detail.mahadasha.lord, isNotEmpty);
      expect(detail.antardasha.level, 'Antardasha');
      expect(detail.pratyantardasha.level, 'Pratyantardasha');
      expect(detail.sookshma.level, 'Sookshma');
      for (final SubDashaSpan span in <SubDashaSpan>[
        detail.antardasha,
        detail.pratyantardasha,
        detail.sookshma,
      ]) {
        expect(!asOf.isBefore(span.start), isTrue);
        expect(!asOf.isAfter(span.end), isTrue);
      }
      expect(
        !detail.antardasha.start.isBefore(detail.mahadasha.start),
        isTrue,
      );
      expect(
        !detail.antardasha.end.isAfter(detail.mahadasha.end),
        isTrue,
      );
      expect(
        !detail.pratyantardasha.start.isBefore(detail.antardasha.start),
        isTrue,
      );
      expect(
        !detail.pratyantardasha.end.isAfter(detail.antardasha.end),
        isTrue,
      );
      expect(
        !detail.sookshma.start.isBefore(detail.pratyantardasha.start),
        isTrue,
      );
      expect(
        !detail.sookshma.end.isAfter(detail.pratyantardasha.end),
        isTrue,
      );
    });

    test('Pratyantardashas of the current Antar cover it exactly', () {
      final DateTime asOf = DateTime(2026, 11, 27);
      final DashaDetail detail =
          dashaDetail(birthLocal: birth, asOf: asOf);
      final List<SubDashaSpan> parts = splitDasha(
        DashaInfo(
          lord: detail.antardasha.lord,
          start: detail.antardasha.start,
          end: detail.antardasha.end,
        ),
        detail.antardasha.lord,
        'Pratyantardasha',
      );
      expect(parts.length, 9);
      expect(parts.first.start, detail.antardasha.start);
      expect(parts.last.end, detail.antardasha.end);
      final int totalDays = parts.fold(
        0,
        (int sum, SubDashaSpan s) => sum + s.end.difference(s.start).inDays,
      );
      expect(
        totalDays,
        detail.antardasha.end.difference(detail.antardasha.start).inDays,
      );
    });
  });
}
