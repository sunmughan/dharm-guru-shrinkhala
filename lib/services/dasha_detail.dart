import 'astro.dart';

/// Phase 6 Vimshottari sub dashas: Antardasha,
/// Pratyantardasha and Sookshma Dasha.
///
/// A sub dasha splits its parent span in proportion to the
/// Vimshottari years: a sub lord with Y years takes Y / 120
/// of the parent span, in the same cycle order as the
/// Mahadasha (Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter,
/// Saturn, Mercury). The split starts with the parent lord,
/// so the first Antardasha of a Mahadasha is the lord own
/// Antardasha. Source: the Vimshottari proportional rule in
/// Brihat Parashara Hora Shastra. The Mahadasha spans come
/// from the engine in astro.dart, so the sub dashas use the
/// same Moon nakshatra math as the timeline.
///
/// shortcut: spans are cut in whole days, so a sub dasha
/// boundary can sit up to a day from a span computed in
/// fractional years. The Mahadasha itself is rounded the
/// same way in the engine, so the parts always add up to
/// the whole within one day.

/// One sub dasha span.
class SubDashaSpan {
  const SubDashaSpan({
    required this.lord,
    required this.start,
    required this.end,
    required this.level,
  });

  final String lord;
  final DateTime start;
  final DateTime end;

  /// Mahadasha, Antardasha, Pratyantardasha or Sookshma.
  final String level;
}

/// Splits [span] into its nine sub spans in cycle order,
/// starting with [startLord]. The parts cover the span
/// exactly: the last part ends where the span ends.
List<SubDashaSpan> splitDasha(
  DashaInfo span,
  String startLord,
  String level,
) {
  final int totalDays = span.end.difference(span.start).inDays;
  final int startIndex = kDashaOrder.indexOf(startLord);
  final List<SubDashaSpan> out = <SubDashaSpan>[];
  DateTime cursor = span.start;
  for (int i = 0; i < kDashaOrder.length; i++) {
    final String lord =
        kDashaOrder[(startIndex + i) % kDashaOrder.length];
    final int days = i == kDashaOrder.length - 1
        ? span.end.difference(cursor).inDays
        : (totalDays * kDashaYears[lord]! / 120.0).round();
    final DateTime end = i == kDashaOrder.length - 1
        ? span.end
        : cursor.add(Duration(days: days));
    out.add(
      SubDashaSpan(lord: lord, start: cursor, end: end, level: level),
    );
    cursor = end;
  }
  return out;
}

/// The Antardashas of the Mahadasha running on [asOf].
List<SubDashaSpan> antardashas({
  required DateTime birthLocal,
  required DateTime asOf,
}) {
  final DashaInfo maha =
      vimshottariDasha(birthLocal: birthLocal, asOf: asOf);
  return splitDasha(maha, maha.lord, 'Antardasha');
}

/// The current Mahadasha, Antardasha, Pratyantardasha and
/// Sookshma Dasha on [asOf], each with its dates.
class DashaDetail {
  const DashaDetail({
    required this.mahadasha,
    required this.antardasha,
    required this.pratyantardasha,
    required this.sookshma,
  });

  final DashaInfo mahadasha;
  final SubDashaSpan antardasha;
  final SubDashaSpan pratyantardasha;
  final SubDashaSpan sookshma;
}

SubDashaSpan _containing(
  List<SubDashaSpan> spans,
  DateTime asOf,
) =>
    spans.firstWhere(
      (SubDashaSpan s) =>
          !asOf.isBefore(s.start) && !asOf.isAfter(s.end),
      orElse: () => spans.last,
    );

DashaDetail dashaDetail({
  required DateTime birthLocal,
  required DateTime asOf,
}) {
  final DashaInfo maha =
      vimshottariDasha(birthLocal: birthLocal, asOf: asOf);
  final List<SubDashaSpan> antars =
      splitDasha(maha, maha.lord, 'Antardasha');
  final SubDashaSpan antar = _containing(antars, asOf);
  final List<SubDashaSpan> pratyantars = splitDasha(
    DashaInfo(lord: antar.lord, start: antar.start, end: antar.end),
    antar.lord,
    'Pratyantardasha',
  );
  final SubDashaSpan pratyantar = _containing(pratyantars, asOf);
  final List<SubDashaSpan> sookshmas = splitDasha(
    DashaInfo(
      lord: pratyantar.lord,
      start: pratyantar.start,
      end: pratyantar.end,
    ),
    pratyantar.lord,
    'Sookshma',
  );
  return DashaDetail(
    mahadasha: maha,
    antardasha: antar,
    pratyantardasha: pratyantar,
    sookshma: _containing(sookshmas, asOf),
  );
}
