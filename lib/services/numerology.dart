/// Numerology from birth date and name, deterministic
/// arithmetic only, no prediction and no AI. Two letter
/// systems are supported and the caller picks one, so
/// the same name can show both sums side by side.
///
/// Pythagorean: A to Z cycle 1 to 9 in order, A J S are 1,
/// B K T are 2, C L U are 3, D M V are 4, E N W are 5,
/// F O X are 6, G P Y are 7, H Q Z are 8, I R are 9.
/// Chaldean: A I J Q Y are 1, B K R are 2, C G L S are 3,
/// D M T are 4, E H N X are 5, U V W are 6, O Z are 7,
/// F P are 8, no letter is 9.
///
/// Birth number, also called Mulank, is the day of birth
/// reduced to one digit. Life path number is the full
/// date reduced, month plus day plus year each reduced
/// first, then added and reduced. Destiny number, also
/// called expression number, is the full name reduced.
/// Bhagyank is the same full date sum as life path, so
/// life path and bhagyank are one value here, shown
/// under both names in the result.
///
/// Lo Shu uses only the digits of the birth date, zeros
/// left out, placed in the 3 by 3 magic square
/// 4 9 2 / 3 5 7 / 8 1 6, every line sums to 15.
/// Number compatibility reuses the planet friendship
/// table from Graha Maitri, with each number ruled by
/// its Indian planet: 1 Sun, 2 Moon, 3 Jupiter, 4 Rahu,
/// 5 Mercury, 6 Venus, 7 Ketu, 8 Saturn, 9 Mars.
enum NumerologySystem { pythagorean, chaldean }

/// Options for a numerology calculation. The default
/// system is Chaldean, the system Indian practice uses
/// for name numbers. Master numbers are reduced to one
/// digit by default, the Indian practice.
class NumerologyOptions {
  const NumerologyOptions({
    this.system = NumerologySystem.chaldean,
    this.keepMasterNumbers = false,
  });

  final NumerologySystem system;
  final bool keepMasterNumbers;
}

const Map<String, int> _pythagoreanValues = <String, int>{
  'A': 1, 'J': 1, 'S': 1,
  'B': 2, 'K': 2, 'T': 2,
  'C': 3, 'L': 3, 'U': 3,
  'D': 4, 'M': 4, 'V': 4,
  'E': 5, 'N': 5, 'W': 5,
  'F': 6, 'O': 6, 'X': 6,
  'G': 7, 'P': 7, 'Y': 7,
  'H': 8, 'Q': 8, 'Z': 8,
  'I': 9, 'R': 9,
};

const Map<String, int> _chaldeanValues = <String, int>{
  'A': 1, 'I': 1, 'J': 1, 'Q': 1, 'Y': 1,
  'B': 2, 'K': 2, 'R': 2,
  'C': 3, 'G': 3, 'L': 3, 'S': 3,
  'D': 4, 'M': 4, 'T': 4,
  'E': 5, 'H': 5, 'N': 5, 'X': 5,
  'U': 6, 'V': 6, 'W': 6,
  'O': 7, 'Z': 7,
  'F': 8, 'P': 8,
};

/// Planet ruling each number 1 to 9, Indian system.
const Map<int, String> kNumberPlanets = <int, String>{
  1: 'Sun',
  2: 'Moon',
  3: 'Jupiter',
  4: 'Rahu',
  5: 'Mercury',
  6: 'Venus',
  7: 'Ketu',
  8: 'Saturn',
  9: 'Mars',
};

const Map<String, Set<String>> _planetFriends =
    <String, Set<String>>{
  'Sun': <String>{'Moon', 'Mars', 'Jupiter'},
  'Moon': <String>{'Sun', 'Mercury'},
  'Mars': <String>{'Sun', 'Moon', 'Jupiter'},
  'Mercury': <String>{'Sun', 'Venus'},
  'Jupiter': <String>{'Sun', 'Moon', 'Mars'},
  'Venus': <String>{'Mercury', 'Saturn'},
  'Saturn': <String>{'Mercury', 'Venus'},
};

const Map<String, Set<String>> _planetEnemies =
    <String, Set<String>>{
  'Sun': <String>{'Venus', 'Saturn'},
  'Moon': <String>{},
  'Mars': <String>{'Mercury'},
  'Mercury': <String>{'Moon'},
  'Jupiter': <String>{'Mercury', 'Venus'},
  'Venus': <String>{'Sun', 'Moon'},
  'Saturn': <String>{'Sun', 'Moon', 'Mars'},
};

/// The Lo Shu lines, rows, columns and diagonals.
const List<List<int>> kLoShuLines = <List<int>>[
  <int>[4, 9, 2],
  <int>[3, 5, 7],
  <int>[8, 1, 6],
  <int>[4, 3, 8],
  <int>[9, 5, 1],
  <int>[2, 7, 6],
  <int>[4, 5, 6],
  <int>[2, 5, 8],
];

class NumerologyResult {
  const NumerologyResult({
    required this.birthNumber,
    required this.birthSteps,
    required this.lifePathNumber,
    required this.lifePathSteps,
    required this.destinyNumber,
    required this.destinySteps,
    required this.soulUrgeNumber,
    required this.personalityNumber,
    required this.system,
    required this.loShuCounts,
    required this.loShuMissing,
    required this.loShuCompleteLines,
    required this.name,
    required this.birthDate,
  });

  /// Mulank, day of birth reduced.
  final int birthNumber;
  final String birthSteps;

  /// Full date reduced, also the Bhagyank.
  final int lifePathNumber;
  final String lifePathSteps;

  /// Full name reduced under [system].
  final int destinyNumber;
  final String destinySteps;

  /// Vowels of the name reduced, 0 when the name has
  /// no vowel.
  final int soulUrgeNumber;

  /// Consonants of the name reduced, 0 when the name
  /// has no consonant.
  final int personalityNumber;

  final NumerologySystem system;

  /// Count of each digit 1 to 9 in the birth date.
  final Map<int, int> loShuCounts;

  /// Digits 1 to 9 absent from the birth date.
  final List<int> loShuMissing;

  /// Lo Shu lines fully present, as digit lists.
  final List<List<int>> loShuCompleteLines;

  final String name;
  final DateTime birthDate;

  /// Bhagyank, same value as life path by definition.
  int get bhagyank => lifePathNumber;

  String planetFor(int number) => kNumberPlanets[number] ?? '';
}

int _digitSum(int value) {
  int sum = 0;
  int rest = value.abs();
  while (rest > 0) {
    sum += rest % 10;
    rest ~/= 10;
  }
  return sum;
}

int _reduce(int value, bool keepMasterNumbers) {
  int current = value;
  while (current > 9) {
    if (keepMasterNumbers &&
        (current == 11 || current == 22 || current == 33)) {
      return current;
    }
    current = _digitSum(current);
  }
  return current;
}

bool _isVowel(String letter) =>
    'AEIOU'.contains(letter);

class NumerologyCalculator {
  NumerologyCalculator._();

  static int letterValue(
    String letter,
    NumerologySystem system,
  ) {
    final Map<String, int> table =
        system == NumerologySystem.pythagorean
            ? _pythagoreanValues
            : _chaldeanValues;
    return table[letter.toUpperCase()] ?? 0;
  }

  static int reduceNumber(
    int value, {
    bool keepMasterNumbers = false,
  }) =>
      _reduce(value, keepMasterNumbers);

  static NumerologyResult calculate({
    required String name,
    required DateTime birthDate,
    NumerologyOptions options = const NumerologyOptions(),
  }) {
    final int birthNumber = _reduce(
      _digitSum(birthDate.day),
      options.keepMasterNumbers,
    );
    final String birthSteps =
        '${birthDate.day} = ${_digitSum(birthDate.day)}'
        '${birthNumber == _digitSum(birthDate.day) ? '' : ' = $birthNumber'}';
    final int monthPart = _reduce(
      _digitSum(birthDate.month),
      options.keepMasterNumbers,
    );
    final int dayPart = _reduce(
      _digitSum(birthDate.day),
      options.keepMasterNumbers,
    );
    final int yearPart = _reduce(
      _digitSum(birthDate.year),
      options.keepMasterNumbers,
    );
    final int lifePath = _reduce(
      monthPart + dayPart + yearPart,
      options.keepMasterNumbers,
    );
    final String lifePathSteps =
        '$monthPart + $dayPart + $yearPart = '
        '${monthPart + dayPart + yearPart} = $lifePath';

    final Map<String, int> table =
        options.system == NumerologySystem.pythagorean
            ? _pythagoreanValues
            : _chaldeanValues;
    int nameTotal = 0;
    int vowelTotal = 0;
    int consonantTotal = 0;
    for (final String letter in name.toUpperCase().split('')) {
      final int value = table[letter] ?? 0;
      if (value == 0) continue;
      nameTotal += value;
      if (_isVowel(letter)) {
        vowelTotal += value;
      } else {
        consonantTotal += value;
      }
    }
    final int destiny = nameTotal == 0
        ? 0
        : _reduce(nameTotal, options.keepMasterNumbers);
    final String destinySteps = nameTotal == 0
        ? 'No letters with a value in the name.'
        : '$nameTotal = $destiny';
    final int soulUrge = vowelTotal == 0
        ? 0
        : _reduce(vowelTotal, options.keepMasterNumbers);
    final int personality = consonantTotal == 0
        ? 0
        : _reduce(consonantTotal, options.keepMasterNumbers);

    final Map<int, int> counts = <int, int>{
      for (int n = 1; n <= 9; n++) n: 0,
    };
    final String digits =
        '${birthDate.day}${birthDate.month}${birthDate.year}';
    for (final String ch in digits.split('')) {
      final int? digit = int.tryParse(ch);
      if (digit != null && digit >= 1 && digit <= 9) {
        counts[digit] = (counts[digit] ?? 0) + 1;
      }
    }
    final List<int> missing = <int>[
      for (int n = 1; n <= 9; n++)
        if ((counts[n] ?? 0) == 0) n,
    ];
    final List<List<int>> completeLines = <List<int>>[
      for (final List<int> line in kLoShuLines)
        if (line.every((int n) => (counts[n] ?? 0) > 0)) line,
    ];
    return NumerologyResult(
      birthNumber: birthNumber,
      birthSteps: birthSteps,
      lifePathNumber: lifePath,
      lifePathSteps: lifePathSteps,
      destinyNumber: destiny,
      destinySteps: destinySteps,
      soulUrgeNumber: soulUrge,
      personalityNumber: personality,
      system: options.system,
      loShuCounts: counts,
      loShuMissing: missing,
      loShuCompleteLines: completeLines,
      name: name,
      birthDate: birthDate,
    );
  }

  /// Compatibility of two numbers by their ruling
  /// planets: Compatible when either planet counts the
  /// other a friend and neither counts the other an
  /// enemy, Challenging when either counts the other
  /// an enemy, Neutral otherwise.
  static String compatibility(int first, int second) {
    final String planetA = kNumberPlanets[first] ?? '';
    final String planetB = kNumberPlanets[second] ?? '';
    if (planetA.isEmpty || planetB.isEmpty) return 'Neutral';
    final bool enemy = (_planetEnemies[planetA]?.contains(planetB) ??
            false) ||
        (_planetEnemies[planetB]?.contains(planetA) ?? false);
    if (enemy) return 'Challenging';
    final bool friend =
        (_planetFriends[planetA]?.contains(planetB) ?? false) ||
            (_planetFriends[planetB]?.contains(planetA) ?? false);
    return friend ? 'Compatible' : 'Neutral';
  }

  /// Compatibility of two life path numbers.
  static String lifePathCompatibility(
    NumerologyResult first,
    NumerologyResult second,
  ) =>
      compatibility(first.lifePathNumber, second.lifePathNumber);
}
