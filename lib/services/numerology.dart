/// Numerology, pure arithmetic from the name and the date of
/// birth. No prediction is invented: every number is a digit
/// sum, and the short meaning lines are traditional reference
/// text for that number. Master numbers 11, 22 and 33 are
/// kept, never reduced, in the standard way.
class NumerologyResult {
  const NumerologyResult({
    required this.lifePath,
    required this.destiny,
    required this.soulUrge,
    required this.personality,
    required this.birthDay,
    required this.personalYear,
  });

  final int lifePath;
  final int destiny;
  final int soulUrge;
  final int personality;
  final int birthDay;
  final int personalYear;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'lifePath': lifePath,
      'destiny': destiny,
      'soulUrge': soulUrge,
      'personality': personality,
      'birthDay': birthDay,
      'personalYear': personalYear,
    };
  }
}

/// Traditional reference line for one number. Guidance only,
/// it promises no outcome.
const Map<int, String> kNumerologyMeanings = <int, String>{
  1: 'Leadership, independence and new beginnings.',
  2: 'Cooperation, patience and balance in relationships.',
  3: 'Expression, creativity and clear communication.',
  4: 'Order, steady work and strong foundations.',
  5: 'Change, freedom and learning through experience.',
  6: 'Care, family and responsibility at home.',
  7: 'Study, reflection and inner understanding.',
  8: 'Ambition, organisation and material results.',
  9: 'Compassion, completion and service to others.',
  11: 'Insight and inspiration, with high sensitivity.',
  22: 'Building large things step by step, with discipline.',
  33: 'Care and teaching, with service to many people.',
};

class Numerology {
  Numerology._();

  /// Pythagorean letter value: A is 1 through I is 9, then
  /// the cycle repeats, so J is 1 and Z is 8. Non letters
  /// count for nothing.
  static int letterValue(String letter) {
    final int code = letter.toUpperCase().codeUnitAt(0);
    if (code < 65 || code > 90) return 0;
    return (code - 65) % 9 + 1;
  }

  static int _digitSum(int value) {
    int sum = 0;
    int left = value.abs();
    while (left > 0) {
      sum += left % 10;
      left ~/= 10;
    }
    return sum;
  }

  /// Reduces to one digit, keeping master numbers 11, 22
  /// and 33 untouched.
  static int reduce(int value) {
    int current = value;
    while (current > 9 && current != 11 && current != 22 && current != 33) {
      current = _digitSum(current);
    }
    return current;
  }

  /// Life Path from every digit of yyyy-MM-dd added together.
  static int lifePath(String dateOfBirth) {
    int sum = 0;
    for (final String ch in dateOfBirth.split('')) {
      sum += int.tryParse(ch) ?? 0;
    }
    return reduce(sum);
  }

  /// Destiny from every letter of the full name.
  static int destiny(String fullName) {
    int sum = 0;
    for (final String ch in fullName.split('')) {
      sum += letterValue(ch);
    }
    return reduce(sum);
  }

  static bool _isVowel(String ch) =>
      'AEIOU'.contains(ch.toUpperCase());

  /// Soul Urge from the vowels of the full name.
  static int soulUrge(String fullName) {
    int sum = 0;
    for (final String ch in fullName.split('')) {
      if (_isVowel(ch)) sum += letterValue(ch);
    }
    return reduce(sum);
  }

  /// Personality from the consonants of the full name.
  static int personality(String fullName) {
    int sum = 0;
    for (final String ch in fullName.split('')) {
      if (ch.toUpperCase() != ch.toLowerCase() && !_isVowel(ch)) {
        sum += letterValue(ch);
      }
    }
    return reduce(sum);
  }

  /// Birth Day number from the day of the month.
  static int birthDay(String dateOfBirth) {
    final DateTime? date = DateTime.tryParse(dateOfBirth);
    if (date == null) return 0;
    return reduce(date.day);
  }

  /// Personal Year for [asOfYear]: day plus month plus year,
  /// reduced. Example: 15 January in 2026 is 1 + 5 + 1 + 2 + 0 + 2 + 6.
  static int personalYear(String dateOfBirth, int asOfYear) {
    final DateTime? date = DateTime.tryParse(dateOfBirth);
    if (date == null) return 0;
    int sum = _digitSum(date.day) + _digitSum(date.month) + _digitSum(asOfYear);
    return reduce(sum);
  }

  static NumerologyResult calculate({
    required String fullName,
    required String dateOfBirth,
    required DateTime asOf,
  }) {
    return NumerologyResult(
      lifePath: lifePath(dateOfBirth),
      destiny: destiny(fullName),
      soulUrge: soulUrge(fullName),
      personality: personality(fullName),
      birthDay: birthDay(dateOfBirth),
      personalYear: personalYear(dateOfBirth, asOf.year),
    );
  }
}
