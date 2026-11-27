/// Consult booking workflow, pure logic with no Firestore call.
/// Availability, conflict prevention, payment gating,
/// cancellation and refund rules, completion and reviews all
/// live here so tests prove them without a live astrologer.
/// There is no astrologer identity and no published slot list
/// yet, so the caller passes the astrologer id it already
/// knows from the astrologers collection, and an empty id is
/// refused. No booking is ever confirmed on a client claim
/// of payment: only verifiedPayment from the trusted backend
/// confirms a paid booking.
enum BookingStatus {
  requested,
  awaitingPayment,
  confirmed,
  cancelledByUser,
  cancelledByAstrologer,
  completed,
  refundPending,
  refunded,
}

enum BookingOutcome {
  confirmed,
  awaitingPayment,
  conflict,
  invalidTime,
  astrologerMissing,
  pastTime,
}

enum CancelOutcome {
  cancelled,
  tooLate,
  alreadyClosed,
}

class ConsultBooking {
  const ConsultBooking({
    required this.id,
    required this.astrologerId,
    required this.userId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.paid,
    this.refundDue = false,
    this.refundReason,
  });

  final String id;
  final String astrologerId;
  final String userId;
  final DateTime startsAt;
  final DateTime endsAt;
  final BookingStatus status;

  /// True only when a verified payment exists for this booking.
  final bool paid;

  /// True when the cancellation earns a refund under the rules.
  final bool refundDue;
  final String? refundReason;

  bool get isActive {
    return status == BookingStatus.requested ||
        status == BookingStatus.awaitingPayment ||
        status == BookingStatus.confirmed;
  }

  ConsultBooking copyWith({
    BookingStatus? status,
    bool? refundDue,
    String? refundReason,
  }) {
    return ConsultBooking(
      id: id,
      astrologerId: astrologerId,
      userId: userId,
      startsAt: startsAt,
      endsAt: endsAt,
      status: status ?? this.status,
      paid: paid,
      refundDue: refundDue ?? this.refundDue,
      refundReason: refundReason ?? this.refundReason,
    );
  }
}

class BookingRequestResult {
  const BookingRequestResult({
    required this.outcome,
    this.booking,
    this.reason,
  });

  final BookingOutcome outcome;
  final ConsultBooking? booking;
  final String? reason;
}

class CancelResult {
  const CancelResult({
    required this.outcome,
    this.booking,
    this.reason,
  });

  final CancelOutcome outcome;
  final ConsultBooking? booking;
  final String? reason;
}

class ConsultReview {
  const ConsultReview({
    required this.bookingId,
    required this.userId,
    required this.astrologerId,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  final String bookingId;
  final String userId;
  final String astrologerId;
  final int rating;
  final String text;
  final DateTime createdAt;
}

class ConsultBookingEngine {
  ConsultBookingEngine._();

  /// Shortest and longest consult, in minutes.
  static const int minDurationMinutes = 15;
  static const int maxDurationMinutes = 180;

  /// Full refund when the user cancels at least this long
  /// before the start. Inside this window the astrologer
  /// already held the slot, so no refund is due.
  static const Duration fullRefundBefore = Duration(hours: 24);

  /// True when the slot is free for this astrologer: no active
  /// booking for the same astrologer overlaps the time.
  static bool isSlotFree({
    required String astrologerId,
    required DateTime startsAt,
    required DateTime endsAt,
    required List<ConsultBooking> existing,
  }) {
    for (final ConsultBooking other in existing) {
      if (other.astrologerId != astrologerId) {
        continue;
      }
      if (!other.isActive) {
        continue;
      }
      if (startsAt.isBefore(other.endsAt) &&
          other.startsAt.isBefore(endsAt)) {
        return false;
      }
    }
    return true;
  }

  /// Requests a booking. The id is built from the inputs so
  /// the same request always builds the same id, which keeps
  /// a retry from creating a second booking for one request.
  static BookingRequestResult requestBooking({
    required String astrologerId,
    required String userId,
    required DateTime startsAt,
    required int durationMinutes,
    required List<ConsultBooking> existing,
    required DateTime now,
    required bool paymentRequired,
    required bool verifiedPayment,
  }) {
    if (astrologerId.isEmpty) {
      return const BookingRequestResult(
        outcome: BookingOutcome.astrologerMissing,
        reason: 'No astrologer is assigned yet.',
      );
    }
    if (userId.isEmpty) {
      return const BookingRequestResult(
        outcome: BookingOutcome.invalidTime,
        reason: 'User id is missing.',
      );
    }
    if (durationMinutes < minDurationMinutes ||
        durationMinutes > maxDurationMinutes) {
      return const BookingRequestResult(
        outcome: BookingOutcome.invalidTime,
        reason: 'Consult length must be 15 to 180 minutes.',
      );
    }
    if (!startsAt.isAfter(now)) {
      return const BookingRequestResult(
        outcome: BookingOutcome.pastTime,
        reason: 'The consult must start in the future.',
      );
    }
    final DateTime endsAt =
        startsAt.add(Duration(minutes: durationMinutes));
    if (!isSlotFree(
      astrologerId: astrologerId,
      startsAt: startsAt,
      endsAt: endsAt,
      existing: existing,
    )) {
      return const BookingRequestResult(
        outcome: BookingOutcome.conflict,
        reason: 'The astrologer is already booked at that time.',
      );
    }
    final String id =
        'booking_${astrologerId}_${userId}_${startsAt.millisecondsSinceEpoch}';
    if (paymentRequired && !verifiedPayment) {
      return BookingRequestResult(
        outcome: BookingOutcome.awaitingPayment,
        booking: ConsultBooking(
          id: id,
          astrologerId: astrologerId,
          userId: userId,
          startsAt: startsAt,
          endsAt: endsAt,
          status: BookingStatus.awaitingPayment,
          paid: false,
        ),
        reason: 'Payment is required before this booking confirms.',
      );
    }
    return BookingRequestResult(
      outcome: BookingOutcome.confirmed,
      booking: ConsultBooking(
        id: id,
        astrologerId: astrologerId,
        userId: userId,
        startsAt: startsAt,
        endsAt: endsAt,
        status: BookingStatus.confirmed,
        paid: verifiedPayment,
      ),
    );
  }

  /// Cancels a booking. Cancelling after the start is refused.
  /// Cancelling at least 24 hours before earns a full refund
  /// when a payment was taken. Inside 24 hours no refund is
  /// due. When no payment was taken there is nothing to refund.
  static CancelResult cancelBooking(
    ConsultBooking booking, {
    required DateTime now,
    required bool byAstrologer,
  }) {
    if (!booking.isActive) {
      return const CancelResult(
        outcome: CancelOutcome.alreadyClosed,
        reason: 'This booking is already closed.',
      );
    }
    if (!now.isBefore(booking.startsAt)) {
      return const CancelResult(
        outcome: CancelOutcome.tooLate,
        reason: 'The consult has already started.',
      );
    }
    final BookingStatus status = byAstrologer
        ? BookingStatus.cancelledByAstrologer
        : BookingStatus.cancelledByUser;
    final bool earlyEnough =
        booking.startsAt.difference(now) >= fullRefundBefore;
    if (!booking.paid) {
      return CancelResult(
        outcome: CancelOutcome.cancelled,
        booking: booking.copyWith(
          status: status,
          refundDue: false,
          refundReason: 'No payment was taken, nothing to refund.',
        ),
      );
    }
    if (earlyEnough) {
      return CancelResult(
        outcome: CancelOutcome.cancelled,
        booking: booking.copyWith(
          status: status,
          refundDue: true,
          refundReason: 'Cancelled at least 24 hours before, full refund due.',
        ),
      );
    }
    return CancelResult(
      outcome: CancelOutcome.cancelled,
      booking: booking.copyWith(
        status: status,
        refundDue: false,
        refundReason:
            'Cancelled inside 24 hours, no refund under the 24 hour rule.',
      ),
    );
  }

  /// Marks a booking refunded after the refund was paid out.
  /// Only a cancelled booking with a refund due can move here.
  static ConsultBooking markRefunded(ConsultBooking booking) {
    if (!booking.refundDue) {
      throw StateError('No refund is due for booking ${booking.id}');
    }
    if (booking.status != BookingStatus.cancelledByUser &&
        booking.status != BookingStatus.cancelledByAstrologer) {
      throw StateError('Only a cancelled booking can be refunded');
    }
    return booking.copyWith(status: BookingStatus.refunded);
  }

  /// Completes a booking. Only a confirmed booking that has
  /// already ended can complete.
  static ConsultBooking completeBooking(
    ConsultBooking booking, {
    required DateTime now,
  }) {
    if (booking.status != BookingStatus.confirmed) {
      throw StateError('Only a confirmed booking can complete');
    }
    if (now.isBefore(booking.endsAt)) {
      throw StateError('The consult has not ended yet');
    }
    return booking.copyWith(status: BookingStatus.completed);
  }

  /// Adds a review. Only a completed booking can be reviewed,
  /// rating is 1 to 5, and one booking holds one review.
  static ConsultReview addReview({
    required ConsultBooking booking,
    required int rating,
    required String text,
    required bool alreadyReviewed,
    DateTime? createdAt,
  }) {
    if (booking.status != BookingStatus.completed) {
      throw StateError('Only a completed consult can be reviewed');
    }
    if (alreadyReviewed) {
      throw StateError('This booking already has a review');
    }
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be 1 to 5');
    }
    return ConsultReview(
      bookingId: booking.id,
      userId: booking.userId,
      astrologerId: booking.astrologerId,
      rating: rating,
      text: text.trim(),
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
