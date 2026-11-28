/// Complete user profile, modelled on what a top astrology app
/// collects (Astrotalk reference): full name, gender, date of
/// birth, time of birth with an explicit "I do not know my birth
/// time" choice, place of birth, marital status, occupation,
/// phone, language, and the daily horoscope alert time.
/// Dates are yyyy-MM-dd strings and times are HH:mm strings in
/// Firestore, so no Timestamp parsing is needed anywhere.
class AppUserProfile {
  const AppUserProfile({
    required this.name,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.birthTimeUnknown = false,
    this.birthCity,
    this.birthState,
    this.birthCountry,
    this.maritalStatus,
    this.occupation,
    this.phoneNumber,
    this.language,
    this.horoscopeAlertTime,
  });

  final String name;
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final bool birthTimeUnknown;
  final String? birthCity;
  final String? birthState;
  final String? birthCountry;
  final String? maritalStatus;
  final String? occupation;
  final String? phoneNumber;
  final String? language;
  final String? horoscopeAlertTime;

  static const List<String> genders = <String>[
    'Male',
    'Female',
    'Other',
  ];

  static const List<String> maritalStatuses = <String>[
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  static const List<String> languages = <String>[
    'English',
    'Hindi',
  ];

  /// A profile counts as complete when the kundli needs are met:
  /// a name, a date of birth and a birth place. Time of birth is
  /// optional because many users do not know it.
  bool get isComplete =>
      name.trim().isNotEmpty &&
      (dateOfBirth ?? '').isNotEmpty &&
      (birthCity ?? '').trim().isNotEmpty;

  /// One line for the profile header, for example
  /// "15 January 2000, 07:30 AM, Delhi, Delhi, India".
  String get birthLine {
    final List<String> parts = <String>[];
    if ((dateOfBirth ?? '').isNotEmpty) {
      parts.add(displayDate(dateOfBirth!));
    }
    if (!birthTimeUnknown && (timeOfBirth ?? '').isNotEmpty) {
      parts.add(displayTime(timeOfBirth!));
    }
    final String place = placeLine;
    if (place.isNotEmpty) {
      parts.add(place);
    }
    return parts.join(', ');
  }

  String get placeLine {
    final List<String> parts = <String>[];
    if ((birthCity ?? '').trim().isNotEmpty) parts.add(birthCity!.trim());
    if ((birthState ?? '').trim().isNotEmpty) parts.add(birthState!.trim());
    if ((birthCountry ?? '').trim().isNotEmpty) {
      parts.add(birthCountry!.trim());
    }
    return parts.join(', ');
  }

  /// "2000-01-15" becomes "15 January 2000". Older stored
  /// values "15/01/2000" and "15-01-2000" become the same.
  /// Falls back to the stored string when it does not parse.
  static String displayDate(String stored) {
    final String text = stored.trim();
    final List<String> slash = text.split(RegExp(r'[/-]'));
    if (slash.length == 3) {
      final int? first = int.tryParse(slash[0]);
      final int? second = int.tryParse(slash[1]);
      final int? third = int.tryParse(slash[2]);
      if (first != null && second != null && third != null) {
        const List<String> months = <String>[
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December',
        ];
        if (slash[0].length == 4) {
          if (second >= 1 && second <= 12) {
            return '$third ${months[second - 1]} $first';
          }
        } else if (second >= 1 && second <= 12) {
          return '$first ${months[second - 1]} $third';
        }
      }
    }
    return stored;
  }

  /// "07:30" becomes "07:30 AM". Falls back to the stored string.
  static String displayTime(String stored) {
    final List<String> bits = stored.split(':');
    if (bits.length != 2) return stored;
    final int? hour = int.tryParse(bits[0]);
    final int? minute = int.tryParse(bits[1]);
    if (hour == null || minute == null) return stored;
    final String suffix = hour >= 12 ? 'PM' : 'AM';
    final int shown = hour % 12 == 0 ? 12 : hour % 12;
    return '${shown.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix';
  }

  /// "15 January 2000" becomes "2000-01-15" for storage.
  /// "15/01/2000", "15-01-2000" and "2000-01-15" become the
  /// same. Returns null when the text does not parse, so the
  /// form can reject it.
  static String? storeDate(String text) {
    final String trimmed = text.trim();
    final List<String> slash = trimmed.split(RegExp(r'[/-]'));
    if (slash.length == 3) {
      final int? first = int.tryParse(slash[0]);
      final int? second = int.tryParse(slash[1]);
      final int? third = int.tryParse(slash[2]);
      if (first != null && second != null && third != null) {
        if (slash[0].length == 4 && second >= 1 && second <= 12) {
          return '$first-${second.toString().padLeft(2, '0')}-${third.toString().padLeft(2, '0')}';
        }
        if (slash[2].length == 4 && second >= 1 && second <= 12) {
          return '$third-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}';
        }
      }
    }
    final List<String> bits = trimmed.split(' ');
    if (bits.length != 3) return null;
    const Map<String, String> months = <String, String>{
      'January': '01', 'February': '02', 'March': '03', 'April': '04',
      'May': '05', 'June': '06', 'July': '07', 'August': '08',
      'September': '09', 'October': '10', 'November': '11',
      'December': '12',
    };
    final String? month = months[bits[1]];
    final int? day = int.tryParse(bits[0]);
    final int? year = int.tryParse(bits[2]);
    if (month == null || day == null || year == null) return null;
    return '$year-$month-${day.toString().padLeft(2, '0')}';
  }

  factory AppUserProfile.fromMap(Map<String, dynamic> map) {
    String? text(String key) {
      final Object? value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      return null;
    }

    return AppUserProfile(
      name: text('name') ?? '',
      gender: text('gender'),
      dateOfBirth: text('dateOfBirth'),
      timeOfBirth: text('timeOfBirth'),
      birthTimeUnknown: map['birthTimeUnknown'] == true,
      birthCity: text('birthCity'),
      birthState: text('birthState'),
      birthCountry: text('birthCountry'),
      maritalStatus: text('maritalStatus'),
      occupation: text('occupation'),
      phoneNumber: text('phoneNumber'),
      language: text('language'),
      horoscopeAlertTime: text('horoscopeAlertTime'),
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'name': name.trim(),
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'timeOfBirth': birthTimeUnknown ? null : timeOfBirth,
      'birthTimeUnknown': birthTimeUnknown,
      'birthCity': birthCity,
      'birthState': birthState,
      'birthCountry': birthCountry,
      'maritalStatus': maritalStatus,
      'occupation': occupation,
      'phoneNumber': phoneNumber,
      'language': language,
      'horoscopeAlertTime': horoscopeAlertTime,
    };
  }
}
