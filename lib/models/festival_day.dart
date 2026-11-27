/// One festival day found by scanning the Panchang engine.
/// The rule names the tithi rule the day was found by, when
/// the day comes from the named festival engine; plain tithi
/// days carry an empty rule.
class FestivalDay {
  const FestivalDay({
    required this.date,
    required this.tithi,
    required this.observance,
    this.rule = '',
  });

  final DateTime date;
  final String tithi;
  final String observance;
  final String rule;
}
