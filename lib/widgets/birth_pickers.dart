import 'package:material_ui/material_ui.dart';

import '../services/user_profile.dart';

/// Date and time pickers shared by every birth form in the
/// app. A picker writes the exact display text the parsers
/// already accept ("29 July 1995", "12:05 AM", "07:30"), so
/// a picked value can never fail validation the way typed
/// text did: typing "29071995" was rejected everywhere.
const List<String> _monthNames = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String birthPickerDateText(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

String birthPickerTimeText(TimeOfDay time) {
  final String suffix = time.hour >= 12 ? 'PM' : 'AM';
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $suffix';
}

String birthPickerTime24Text(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

DateTime? _dateFromText(String text) {
  final String trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final DateTime? iso = DateTime.tryParse(trimmed);
  if (iso != null) return iso;
  final String? stored = AppUserProfile.storeDate(trimmed);
  if (stored == null) return null;
  return DateTime.tryParse(stored);
}

TimeOfDay? _time12FromText(String text) {
  final List<String> bits = text.trim().split(' ');
  if (bits.length != 2) return null;
  final List<String> hm = bits[0].split(':');
  if (hm.length != 2) return null;
  final int? hour12 = int.tryParse(hm[0]);
  final int? minute = int.tryParse(hm[1]);
  if (hour12 == null || minute == null) return null;
  final String suffix = bits[1].toUpperCase();
  if (suffix != 'AM' && suffix != 'PM') return null;
  if (hour12 < 1 || hour12 > 12 || minute < 0 || minute > 59) return null;
  int hour = hour12 % 12;
  if (suffix == 'PM') hour += 12;
  return TimeOfDay(hour: hour, minute: minute);
}

TimeOfDay? _time24FromText(String text) {
  final List<String> hm = text.trim().split(':');
  if (hm.length != 2) return null;
  final int? hour = int.tryParse(hm[0]);
  final int? minute = int.tryParse(hm[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

/// Date of birth picker: 1900 to today, initial date from
/// the field when it already holds a valid date.
Future<void> pickBirthDate(
  BuildContext context,
  TextEditingController controller,
) async {
  final DateTime now = DateTime.now();
  final DateTime initial = _dateFromText(controller.text) ??
      DateTime(now.year - 25, now.month, now.day);
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(1900),
    lastDate: now,
  );
  if (picked == null) return;
  controller.text = birthPickerDateText(picked);
}

/// Future date picker, for bookings: today to a year out,
/// initial date from the field when it already holds one.
Future<void> pickFutureDate(
  BuildContext context,
  TextEditingController controller,
) async {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime last = today.add(const Duration(days: 365));
  DateTime initial = _dateFromText(controller.text) ?? today;
  if (initial.isBefore(today)) initial = today;
  if (initial.isAfter(last)) initial = last;
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: today,
    lastDate: last,
  );
  if (picked == null) return;
  controller.text = birthPickerDateText(picked);
}

/// Time of birth picker with AM/PM, writes "12:05 AM".
Future<void> pickBirthTime(
  BuildContext context,
  TextEditingController controller,
) async {
  final TimeOfDay initial = _time12FromText(controller.text) ??
      _time24FromText(controller.text) ??
      const TimeOfDay(hour: 12, minute: 0);
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initial,
  );
  if (picked == null) return;
  controller.text = birthPickerTimeText(picked);
}

/// 24 hour time picker, writes "07:30" for the forms whose
/// validation expects HH:mm.
Future<void> pickTime24(
  BuildContext context,
  TextEditingController controller,
) async {
  final TimeOfDay initial = _time24FromText(controller.text) ??
      _time12FromText(controller.text) ??
      const TimeOfDay(hour: 10, minute: 0);
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initial,
  );
  if (picked == null) return;
  controller.text = birthPickerTime24Text(picked);
}
