import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/muhurat.dart';
import 'package:dharm_guru_shrinkhala/services/panchang_extra.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 5 muhurat engine tests. Every window must carry
/// its applied rules and its inputs, must not overlap an
/// inauspicious window, and must sit on a day whose tithi
/// the purpose allows.

void main() {
  group('findMuhurat', () {
    test('marriage windows carry rules, inputs and clean times', () {
      final List<MuhuratWindow> windows = findMuhurat(
        purpose: MuhuratPurpose.marriage,
        from: DateTime(2026, 11, 28),
        days: 60,
      );
      expect(windows, isNotEmpty);
      for (final MuhuratWindow window in windows) {
        expect(window.rulesApplied, isNotEmpty);
        expect(window.inputs, contains('Jaipur'));
        expect(window.inputs, contains('tithi'));
        expect(window.inputs, contains('Lahiri ayanamsa'));
        expect(window.startHours, lessThan(window.endHours));
        final int tithi =
            tithiNumberAtNoon(window.date);
        expect(<int>{4, 9, 14, 30}.contains(tithi), isFalse);
        final DailyTimings timings =
            dailyTimings(window.date, kDefaultPlace);
        final TimeWindow found = TimeWindow(
          label: 'found',
          startHours: window.startHours,
          endHours: window.endHours,
        );
        expect(found.overlaps(timings.rahuKaal), isFalse);
        expect(found.overlaps(timings.yamaganda), isFalse);
        expect(found.overlaps(timings.gulika), isFalse);
      }
    });

    test('Griha Pravesh windows all fall in Shukla paksha', () {
      final List<MuhuratWindow> windows = findMuhurat(
        purpose: MuhuratPurpose.grihaPravesh,
        from: DateTime(2026, 11, 28),
        days: 90,
      );
      expect(windows, isNotEmpty);
      for (final MuhuratWindow window in windows) {
        expect(pakshaFor(window.date), 'Shukla Paksha');
      }
    });

    test('every purpose finds a window within 90 days', () {
      for (final MuhuratPurpose purpose in MuhuratPurpose.values) {
        final List<MuhuratWindow> windows = findMuhurat(
          purpose: purpose,
          from: DateTime(2026, 11, 28),
          days: 90,
        );
        expect(windows, isNotEmpty, reason: purpose.name);
        expect(windows.length, lessThanOrEqualTo(10));
        for (int i = 1; i < windows.length; i++) {
          expect(
            !windows[i].date.isBefore(windows[i - 1].date),
            isTrue,
          );
        }
      }
    });
  });
}
