/// Input validation at trust boundaries. Pure functions, no
/// network, no storage. Every message here is shown to the user
/// as it is, so it names the field and the fix, never a code.
class InputValidation {
  InputValidation._();

  static final RegExp _email = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );
  static final RegExp _date = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp _time = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

  /// Null means the email is usable.
  static String? email(String value) {
    final String v = value.trim();
    if (v.isEmpty) return 'Enter your email address.';
    if (!_email.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  /// Null means the password is usable. Minimum 8 characters.
  static String? password(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  /// Null means the display name is usable.
  static String? displayName(String value) {
    final String v = value.trim();
    if (v.isEmpty) return 'Enter your name.';
    if (v.length > 80) return 'Name must be 80 characters or less.';
    return null;
  }

  /// Null means the birth date is usable. Format YYYY-MM-DD,
  /// year 1900 or later, never in the future.
  static String? birthDate(String value, {DateTime? today}) {
    final String v = value.trim();
    if (!_date.hasMatch(v)) {
      return 'Enter the birth date as YYYY-MM-DD.';
    }
    final DateTime? parsed = DateTime.tryParse(v);
    if (parsed == null) return 'Enter a real birth date.';
    final DateTime now = today ?? DateTime.now();
    final DateTime day = DateTime(now.year, now.month, now.day);
    if (parsed.isAfter(day)) {
      return 'Birth date cannot be in the future.';
    }
    if (parsed.year < 1900) {
      return 'Birth year must be 1900 or later.';
    }
    return null;
  }

  /// Null means the birth time is usable. Format HH:MM, 24 hour.
  static String? birthTime(String value) {
    if (!_time.hasMatch(value.trim())) {
      return 'Enter the birth time as HH:MM.';
    }
    return null;
  }

  /// Null means the birth place is usable.
  static String? birthPlace(String value) {
    if (value.trim().isEmpty) return 'Enter the place of birth.';
    if (value.trim().length > 120) {
      return 'Place of birth must be 120 characters or less.';
    }
    return null;
  }
}
