/// Consult booking and review payloads. A booking is a
/// request, never a confirmed slot: no astrologer identity is
/// decided yet, so the admin confirms it. The payload builder
/// is pure so tests can check validation without Firestore.
class ConsultBooking {
  ConsultBooking._();

  /// First problem found, or null when the booking is valid.
  /// Date must be yyyy-MM-dd, today or later. Mode is chat
  /// or call.
  static String? validate({
    required String date,
    required String time,
    required String mode,
  }) {
    if (mode != 'chat' && mode != 'call') {
      return 'Choose chat or call.';
    }
    final DateTime? day = DateTime.tryParse(date);
    if (day == null) return 'Enter the date as yyyy-MM-dd.';
    final DateTime today = DateTime.now();
    if (day.isBefore(DateTime(today.year, today.month, today.day))) {
      return 'Booking date cannot be in the past.';
    }
    final List<String> bits = time.split(':');
    final int? hour = bits.isNotEmpty ? int.tryParse(bits[0]) : null;
    final int? minute = bits.length > 1 ? int.tryParse(bits[1]) : null;
    if (bits.length != 2 || hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return 'Enter the time as HH:mm, for example 10:00.';
    }
    return null;
  }

  static Map<String, Object?> payload({
    required String userId,
    required String astrologerId,
    required String astrologerName,
    required String mode,
    required String date,
    required String time,
    String? note,
  }) {
    return <String, Object?>{
      'userId': userId,
      'astrologerId': astrologerId,
      'astrologerName': astrologerName,
      'mode': mode,
      'date': date,
      'time': time,
      'note': note ?? '',
      'status': 'requested',
      'requestedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Only a requested or confirmed booking can be cancelled.
  static bool canCancel(String status) =>
      status == 'requested' || status == 'confirmed';

  /// First problem with a review, or null when it is valid.
  static String? validateReview({required int rating, required String text}) {
    if (rating < 1 || rating > 5) return 'Choose a rating from 1 to 5.';
    if (text.trim().isEmpty) return 'Write a short review.';
    if (text.trim().length > 500) return 'Review must be under 500 characters.';
    return null;
  }

  static Map<String, Object?> reviewPayload({
    required String userId,
    required String astrologerId,
    required int rating,
    required String text,
  }) {
    return <String, Object?>{
      'userId': userId,
      'astrologerId': astrologerId,
      'rating': rating,
      'text': text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
