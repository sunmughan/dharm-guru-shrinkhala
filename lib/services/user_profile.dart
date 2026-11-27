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
  /// "14 March 1998, 06:25 AM, Jaipur, Rajasthan, India".
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

  /// "1998-03-14" becomes "14 March 1998". Falls back to the
  /// stored string when it does not parse.
  static String displayDate(String stored) {
    final List<String> bits = stored.split('-');
    if (bits.length != 3) return stored;
    const List<String> months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final int? month = int.tryParse(bits[1]);
    final int? day = int.tryParse(bits[2]);
    if (month == null || day == null || month < 1 || month > 12) {
      return stored;
    }
    return '$day ${months[month - 1]} ${bits[0]}';
  }

  /// "06:25" becomes "06:25 AM". Falls back to the stored string.
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

  /// "14 March 1998" becomes "1998-03-14" for storage. Returns
  /// null when the text does not parse, so the form can reject it.
  static String? storeDate(String text) {
    final List<String> bits = text.trim().split(' ');
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
