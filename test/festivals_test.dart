import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/festivals.dart';
import 'package:dharm_guru_shrinkhala/services/library_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 5 festival engine tests. Dates are checked within
/// one day of the published 2026 dates: the engine reads
/// each tithi at one fixed observance moment, and a tithi
/// that starts minutes after that moment can move a
/// festival by a day against a published panchang. Makar
/// Sankranti is solar and is checked exactly.

DateTime? _named(List<FestivalDay> days, String name) {
  for (final FestivalDay d in days) {
    if (d.observance == name) return d.date;
  }
  return null;
}

bool _within(DateTime? got, DateTime want) {
  if (got == null) return false;
  return (got.difference(want).inDays).abs() <= 1;
}

void main() {
  group('namedFestivals 2026', () {
    late List<FestivalDay> days;

    setUpAll(() {
      days = namedFestivals(year: 2026, place: kDefaultPlace);
    });

    test('Diwali, Holi and the other tithi festivals land on their dates', () {
      expect(_within(_named(days, 'Diwali'), DateTime(2026, 11, 8)), isTrue);
      expect(_within(_named(days, 'Holi'), DateTime(2026, 3, 3)), isTrue);
      expect(
        _within(_named(days, 'Maha Shivratri'), DateTime(2026, 2, 15)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Ram Navami'), DateTime(2026, 3, 26)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Raksha Bandhan'), DateTime(2026, 8, 28)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Ganesh Chaturthi'), DateTime(2026, 9, 14)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Dussehra'), DateTime(2026, 10, 20)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Janmashtami'), DateTime(2026, 9, 3)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Hanuman Jayanti'), DateTime(2026, 4, 2)),
        isTrue,
      );
      expect(
        _within(_named(days, 'Chaitra Navratri begins'), DateTime(2026, 3, 19)),
        isTrue,
      );
      expect(
        _within(
          _named(days, 'Shardiya Navratri begins'),
          DateTime(2026, 10, 11),
        ),
        isTrue,
      );
    });

    test('Makar Sankranti is exactly 14 January 2026', () {
      expect(_named(days, 'Makar Sankranti'), DateTime(2026, 1, 14));
    });

    test('every named festival carries its rule and source', () {
      for (final FestivalDay day in days) {
        expect(day.rule, isNotEmpty, reason: day.observance);
        expect(day.tithi, isNotEmpty, reason: day.observance);
      }
    });

    test('each festival appears once and the list is sorted', () {
      final Set<String> names =
          days.map((FestivalDay d) => d.observance).toSet();
      expect(names.length, days.length);
      for (int i = 1; i < days.length; i++) {
        expect(days[i].date.isAfter(days[i - 1].date), isTrue);
      }
    });
  });

  test('festival dates are computed, not stored: Diwali moves in 2027', () {
    final List<FestivalDay> days2026 = namedFestivals(year: 2026);
    final List<FestivalDay> days2027 = namedFestivals(year: 2027);
    expect(_named(days2026, 'Diwali'), isNotNull);
    expect(_named(days2027, 'Diwali'), isNotNull);
    expect(_named(days2026, 'Diwali'), isNot(_named(days2027, 'Diwali')));
    expect(
      _within(_named(days2027, 'Diwali'), DateTime(2027, 10, 29)),
      isTrue,
    );
  });

  test('festivalDays merges named festivals into the window', () {
    final List<FestivalDay> days = festivalDays(
      from: DateTime(2026, 11, 1),
      days: 10,
    );
    final FestivalDay diwali = days.firstWhere(
      (FestivalDay d) => d.observance == 'Diwali',
    );
    expect(diwali.date, DateTime(2026, 11, 8));
    expect(diwali.rule, contains('Kartika Krishna Amavasya'));
    for (int i = 1; i < days.length; i++) {
      expect(days[i].date.isAfter(days[i - 1].date), isTrue);
    }
  });
}
