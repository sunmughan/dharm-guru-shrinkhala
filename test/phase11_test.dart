import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dharm_guru_shrinkhala/models/kundli.dart';
import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/consult_booking.dart';
import 'package:dharm_guru_shrinkhala/services/firestore_service.dart';
import 'package:dharm_guru_shrinkhala/services/kundli_pdf.dart';
import 'package:dharm_guru_shrinkhala/services/kundli_report.dart';
import 'package:dharm_guru_shrinkhala/services/notification_deep_link.dart';
import 'package:dharm_guru_shrinkhala/services/notification_preferences.dart';
import 'package:dharm_guru_shrinkhala/services/notification_service.dart';
import 'package:dharm_guru_shrinkhala/services/payment_lifecycle.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 11 proof: PDF report, payment lifecycle, consult
/// booking, notification preferences and deep links. Every
/// test feeds one concrete real input and asserts the real
/// output. No fake payment success and no dummy data anywhere.
void main() {
  const BirthDetails birth = BirthDetails(
    name: 'Test User',
    dateOfBirth: '14/03/1998',
    timeOfBirth: '06:25 AM',
    placeOfBirth: 'Jaipur, Rajasthan',
    rashi: 'Kanya',
    nakshatra: 'Uttara Phalguni',
    tithiAtBirth: 'Krishna Pratipada',
  );

  KundliResult realKundli() {
    return KundliCalculator.calculate(
      birthLocal: DateTime(1998, 3, 14, 6, 25),
      placeText: 'Jaipur, Rajasthan',
    );
  }

  KundliReportData realReport() {
    return buildKundliReportData(
      birth: birth,
      kundli: realKundli(),
      chartKind: 'Lagna Chart',
      generatedAt: DateTime(2026, 11, 28, 1, 15),
    );
  }

  group('Kundli report data', () {
    test('real birth gives the real chart values', () {
      final KundliReportData data = realReport();
      expect(data.kundli.lagna, 'Kumbha');
      expect(data.kundli.moonRashi, 'Kanya');
      expect(data.kundli.planets.length, 9);
      expect(data.reportVersion, '1.0');
      expect(data.generatedLabel, '28 Nov 2026 01:15');
      expect(data.timeLabel, '06:25 AM');
      expect(data.planetLines.length, 9);
      expect(data.planetLines.first, contains('Sun'));
    });

    test('config rows name the real place and ayanamsa', () {
      final KundliReportData data = realReport();
      final String config =
          data.configRows.map((List<String> r) => r.join(' ')).join(' ');
      expect(config, contains('Jaipur'));
      expect(config, contains('26.9124'));
      expect(config, contains('Lahiri'));
      expect(config, contains('Lagna Chart'));
    });

    test('unknown time is marked approximate in the report', () {
      final KundliResult kundli = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Jaipur, Rajasthan',
        timeKnown: false,
      );
      const BirthDetails unknownTime = BirthDetails(
        name: 'Test User',
        dateOfBirth: '14/03/1998',
        timeOfBirth: '',
        placeOfBirth: 'Jaipur, Rajasthan',
        rashi: 'Kanya',
        nakshatra: 'Uttara Phalguni',
        tithiAtBirth: 'Krishna Pratipada',
      );
      final KundliReportData data = buildKundliReportData(
        birth: unknownTime,
        kundli: kundli,
        chartKind: 'Lagna Chart',
      );
      expect(data.timeLabel, 'Not known, noon used');
      expect(data.kundli.timeApproximate, isTrue);
      final String config =
          data.configRows.map((List<String> r) => r.join(' ')).join(' ');
      expect(config, contains('Time note'));
    });

    test('unknown place is marked approximate in the report', () {
      final KundliResult kundli = KundliCalculator.calculate(
        birthLocal: DateTime(1998, 3, 14, 6, 25),
        placeText: 'Nowhere City',
      );
      final KundliReportData data = buildKundliReportData(
        birth: birth,
        kundli: kundli,
        chartKind: 'Lagna Chart',
      );
      expect(data.kundli.placeApproximate, isTrue);
      final String config =
          data.configRows.map((List<String> r) => r.join(' ')).join(' ');
      expect(config, contains('Place note'));
    });

    test('moon chart report uses the moon lagna', () {
      final KundliReportData data = buildKundliReportData(
        birth: birth,
        kundli: realKundli().moonChart,
        chartKind: 'Moon Chart',
      );
      expect(data.kundli.lagna, 'Kanya');
      expect(data.chartKind, 'Moon Chart');
    });
  });

  group('Kundli PDF', () {
    Future<Uint8List> realPdfBytes() async {
      final Uint8List regular =
          await File('assets/fonts/Roboto-Regular.ttf').readAsBytes();
      final Uint8List bold =
          await File('assets/fonts/Roboto-Bold.ttf').readAsBytes();
      final KundliPdfFonts fonts = KundliPdfFonts.fromBytes(regular, bold);
      return KundliPdfBuilder.build(
        realReport(),
        fonts: fonts,
        compress: false,
      );
    }

    /// Plain text of a PDF built with embedded TrueType fonts.
    /// The content streams hold subset glyph ids, not Unicode,
    /// so this first reads the ToUnicode CMap of each font,
    /// which maps every glyph id to its Unicode value, and
    /// then decodes the content hex strings through that map.
    /// Standard Helvetica has no Unicode support and writes
    /// no readable text, which is why the report always
    /// builds with the embedded fonts.
    String pdfText(Uint8List bytes) {
      final String raw = latin1.decode(bytes);
      final Map<String, int> glyphToUnicode = <String, int>{};
      void addPair(String glyphHex, String unicodeHex) {
        glyphToUnicode[glyphHex.toUpperCase()] =
            int.parse(unicodeHex, radix: 16);
      }

      for (final RegExpMatch block in RegExp(
        r'beginbfchar(.*?)endbfchar',
        dotAll: true,
      ).allMatches(raw)) {
        for (final RegExpMatch pair in RegExp(
          r'<([0-9A-Fa-f]{4})>\s*<([0-9A-Fa-f]{4,6})>',
        ).allMatches(block.group(1)!)) {
          addPair(pair.group(1)!, pair.group(2)!);
        }
      }
      for (final RegExpMatch block in RegExp(
        r'beginbfrange(.*?)endbfrange',
        dotAll: true,
      ).allMatches(raw)) {
        for (final RegExpMatch range in RegExp(
          r'<([0-9A-Fa-f]{4})>\s*<([0-9A-Fa-f]{4})>\s*<([0-9A-Fa-f]{4,6})>',
        ).allMatches(block.group(1)!)) {
          int glyph = int.parse(range.group(1)!, radix: 16);
          final int end = int.parse(range.group(2)!, radix: 16);
          int unicode = int.parse(range.group(3)!, radix: 16);
          while (glyph <= end) {
            addPair(
              glyph.toRadixString(16).padLeft(4, '0'),
              unicode.toRadixString(16),
            );
            glyph++;
            unicode++;
          }
        }
      }
      final StringBuffer out = StringBuffer();
      for (final RegExpMatch match
          in RegExp(r'<([0-9A-Fa-f\s]+)>').allMatches(raw)) {
        final String hex =
            match.group(1)!.replaceAll(RegExp(r'\s'), '');
        for (int i = 0; i + 4 <= hex.length; i += 4) {
          final int? unicode =
              glyphToUnicode[hex.substring(i, i + 4).toUpperCase()];
          if (unicode != null) {
            out.writeCharCode(unicode);
          }
        }
      }
      return out.toString();
    }

    test('embedded font build is a real PDF with 2 or more pages', () async {
      final Uint8List bytes = await realPdfBytes();
      // ignore: avoid_print
      print('PDF bytes ${bytes.length}');
      expect(bytes.sublist(0, 4), <int>[0x25, 0x50, 0x44, 0x46]);
      expect(bytes.length, greaterThan(10000));
      final String text = latin1.decode(bytes);
      final int pages = RegExp(r'/Type\s*/Page[^s]').allMatches(text).length;
      expect(pages, greaterThanOrEqualTo(2));
    });

    test('embedded font build carries the real content as text', () async {
      final Uint8List bytes = await realPdfBytes();
      final String text = pdfText(bytes);
      expect(text, contains('Test User'));
      expect(text, contains('Kumbha'));
      expect(text, contains('Report v1.0'));
      expect(text, contains('28 Nov 2026'));
      expect(text, contains('Planetary positions'));
      expect(text, contains('Planetary explanations'));
      expect(text, contains('Sun'));
      expect(text, contains('Saturn'));
      expect(text, contains('Page 1 of'));
    });
  });

  group('Payment lifecycle', () {
    PaymentOrder paidOrder() {
      PaymentOrder order = PaymentLifecycle.create(
        orderId: 'order_1',
        userId: 'user_1',
        amountMinor: 49900,
        currency: 'INR',
        idempotencyKey: 'key_1',
      );
      order = PaymentLifecycle.requestProvider(order);
      final ({PaymentOrder order, WebhookOutcome outcome, Set<String> seenEventIds}) applied =
          PaymentLifecycle.applyWebhook(
        order: order,
        eventId: 'evt_1',
        seenEventIds: <String>{},
        kind: PaymentWebhookKind.paymentCaptured,
        providerReference: 'pay_1',
        signatureValid: true,
      );
      expect(applied.outcome, WebhookOutcome.applied);
      expect(applied.order.isPaid, isTrue);
      return applied.order;
    }

    test('full path ends refunded after a completed order', () {
      PaymentOrder order = paidOrder();
      order = PaymentLifecycle.applyEntitlement(order);
      order = PaymentLifecycle.complete(order);
      expect(order.state, PaymentState.completed);
      order = PaymentLifecycle.requestRefund(order);
      order = PaymentLifecycle.completeRefund(order);
      expect(order.state, PaymentState.refunded);
      expect(order.isTerminal, isTrue);
    });

    test('client values can never mark an order paid', () {
      final PaymentOrder created = PaymentLifecycle.create(
        orderId: 'order_2',
        userId: 'user_1',
        amountMinor: 49900,
        currency: 'INR',
        idempotencyKey: 'key_2',
      );
      expect(created.isPaid, isFalse);
      final PaymentOrder requested =
          PaymentLifecycle.requestProvider(created);
      expect(requested.isPaid, isFalse);
      final PaymentOrder responded =
          PaymentLifecycle.recordProviderResponse(
        requested,
        providerReference: 'pay_2',
        signatureValid: true,
      );
      expect(responded.isPaid, isFalse);
      final PaymentOrder badSignature =
          PaymentLifecycle.recordProviderResponse(
        PaymentLifecycle.requestProvider(
          PaymentLifecycle.create(
            orderId: 'order_3',
            userId: 'user_1',
            amountMinor: 49900,
            currency: 'INR',
            idempotencyKey: 'key_3',
          ),
        ),
        providerReference: 'pay_3',
        signatureValid: false,
      );
      expect(badSignature.state, PaymentState.failed);
      expect(badSignature.isPaid, isFalse);
    });

    test('duplicate webhook is ignored and the order is unchanged', () {
      PaymentOrder order = PaymentLifecycle.create(
        orderId: 'order_4',
        userId: 'user_1',
        amountMinor: 49900,
        currency: 'INR',
        idempotencyKey: 'key_4',
      );
      order = PaymentLifecycle.requestProvider(order);
      final ({PaymentOrder order, WebhookOutcome outcome, Set<String> seenEventIds}) first =
          PaymentLifecycle.applyWebhook(
        order: order,
        eventId: 'evt_9',
        seenEventIds: <String>{},
        kind: PaymentWebhookKind.paymentCaptured,
        providerReference: 'pay_9',
        signatureValid: true,
      );
      expect(first.outcome, WebhookOutcome.applied);
      final ({PaymentOrder order, WebhookOutcome outcome, Set<String> seenEventIds}) second =
          PaymentLifecycle.applyWebhook(
        order: first.order,
        eventId: 'evt_9',
        seenEventIds: first.seenEventIds,
        kind: PaymentWebhookKind.paymentCaptured,
        providerReference: 'pay_9',
        signatureValid: true,
      );
      expect(second.outcome, WebhookOutcome.duplicateIgnored);
      expect(second.order.state, first.order.state);
      expect(second.seenEventIds.length, 1);
    });

    test('webhook that does not fit the state is rejected', () {
      final PaymentOrder order = PaymentLifecycle.create(
        orderId: 'order_5',
        userId: 'user_1',
        amountMinor: 49900,
        currency: 'INR',
        idempotencyKey: 'key_5',
      );
      final ({PaymentOrder order, WebhookOutcome outcome, Set<String> seenEventIds}) result =
          PaymentLifecycle.applyWebhook(
        order: order,
        eventId: 'evt_10',
        seenEventIds: <String>{},
        kind: PaymentWebhookKind.refundCompleted,
      );
      expect(result.outcome, WebhookOutcome.rejected);
      expect(result.order.state, PaymentState.created);
      expect(result.seenEventIds, isEmpty);
      final ({PaymentOrder order, WebhookOutcome outcome, Set<String> seenEventIds}) emptyId =
          PaymentLifecycle.applyWebhook(
        order: order,
        eventId: '',
        seenEventIds: <String>{},
        kind: PaymentWebhookKind.paymentFailed,
      );
      expect(emptyId.outcome, WebhookOutcome.rejected);
    });

    test('bad order input is rejected at creation', () {
      expect(
        () => PaymentLifecycle.create(
          orderId: 'order_6',
          userId: 'user_1',
          amountMinor: 0,
          currency: 'INR',
          idempotencyKey: 'key_6',
        ),
        throwsArgumentError,
      );
      expect(
        () => PaymentLifecycle.create(
          orderId: 'order_6',
          userId: 'user_1',
          amountMinor: 100,
          currency: 'inr',
          idempotencyKey: 'key_6',
        ),
        throwsArgumentError,
      );
      expect(
        () => PaymentLifecycle.create(
          orderId: '',
          userId: 'user_1',
          amountMinor: 100,
          currency: 'INR',
          idempotencyKey: 'key_6',
        ),
        throwsArgumentError,
      );
      expect(
        () => PaymentLifecycle.create(
          orderId: 'order_6',
          userId: 'user_1',
          amountMinor: 100,
          currency: 'INR',
          idempotencyKey: '',
        ),
        throwsArgumentError,
      );
    });

    test('entitlement applies exactly once', () {
      final PaymentOrder order = paidOrder();
      final PaymentOrder applied =
          PaymentLifecycle.applyEntitlement(order);
      expect(applied.state, PaymentState.entitlementApplied);
      expect(
        () => PaymentLifecycle.applyEntitlement(applied),
        throwsStateError,
      );
    });

    test('cancel works before entitlement and never after completion', () {
      final PaymentOrder open = PaymentLifecycle.requestProvider(
        PaymentLifecycle.create(
          orderId: 'order_7',
          userId: 'user_1',
          amountMinor: 100,
          currency: 'INR',
          idempotencyKey: 'key_7',
        ),
      );
      expect(
        PaymentLifecycle.cancel(open).state,
        PaymentState.cancelled,
      );
      PaymentOrder done = paidOrder();
      done = PaymentLifecycle.applyEntitlement(done);
      done = PaymentLifecycle.complete(done);
      expect(() => PaymentLifecycle.cancel(done), throwsStateError);
      expect(() => PaymentLifecycle.fail(done), throwsStateError);
    });

    test('lifecycle steps stay complete and in order', () {
      expect(kPaymentLifecycleSteps.length, 8);
      expect(
        kPaymentLifecycleSteps.first,
        contains('Trusted backend'),
      );
      expect(
        kPaymentLifecycleSteps,
        contains('Entitlement is applied exactly once'),
      );
      expect(kPaymentLifecycleSteps.last, contains('reconciliation'));
    });
  });

  group('Consult booking', () {
    final DateTime now = DateTime(2026, 11, 28, 9, 0);

    BookingRequestResult book({
      String astrologerId = 'astro_1',
      DateTime? startsAt,
      int duration = 30,
      List<ConsultBooking> existing = const <ConsultBooking>[],
      bool paymentRequired = false,
      bool verifiedPayment = false,
    }) {
      return ConsultBookingEngine.requestBooking(
        astrologerId: astrologerId,
        userId: 'user_1',
        startsAt: startsAt ?? DateTime(2026, 12, 5, 10, 0),
        durationMinutes: duration,
        existing: existing,
        now: now,
        paymentRequired: paymentRequired,
        verifiedPayment: verifiedPayment,
      );
    }

    test('free slot confirms with the right end time', () {
      final BookingRequestResult result = book();
      expect(result.outcome, BookingOutcome.confirmed);
      expect(result.booking, isNotNull);
      expect(result.booking!.endsAt, DateTime(2026, 12, 5, 10, 30));
      expect(result.booking!.status, BookingStatus.confirmed);
    });

    test('overlapping booking conflicts, adjacent slot is free', () {
      final ConsultBooking first = book().booking!;
      final BookingRequestResult overlap = book(
        startsAt: DateTime(2026, 12, 5, 10, 15),
        existing: <ConsultBooking>[first],
      );
      expect(overlap.outcome, BookingOutcome.conflict);
      final BookingRequestResult adjacent = book(
        startsAt: DateTime(2026, 12, 5, 10, 30),
        existing: <ConsultBooking>[first],
      );
      expect(adjacent.outcome, BookingOutcome.confirmed);
      final BookingRequestResult otherAstrologer = book(
        astrologerId: 'astro_2',
        startsAt: DateTime(2026, 12, 5, 10, 15),
        existing: <ConsultBooking>[first],
      );
      expect(otherAstrologer.outcome, BookingOutcome.confirmed);
    });

    test('past time, bad length and missing astrologer are refused', () {
      expect(
        book(startsAt: DateTime(2026, 11, 28, 8, 0)).outcome,
        BookingOutcome.pastTime,
      );
      expect(
        book(duration: 10).outcome,
        BookingOutcome.invalidTime,
      );
      expect(
        book(duration: 200).outcome,
        BookingOutcome.invalidTime,
      );
      expect(
        book(astrologerId: '').outcome,
        BookingOutcome.astrologerMissing,
      );
    });

    test('payment required booking waits, verified payment confirms', () {
      final BookingRequestResult waiting = book(
        paymentRequired: true,
        verifiedPayment: false,
      );
      expect(waiting.outcome, BookingOutcome.awaitingPayment);
      expect(waiting.booking!.status, BookingStatus.awaitingPayment);
      expect(waiting.booking!.paid, isFalse);
      final BookingRequestResult paid = book(
        paymentRequired: true,
        verifiedPayment: true,
      );
      expect(paid.outcome, BookingOutcome.confirmed);
      expect(paid.booking!.paid, isTrue);
    });

    test('cancel early earns a refund, cancel late earns none', () {
      final ConsultBooking paidEarly = book(
        paymentRequired: true,
        verifiedPayment: true,
      ).booking!;
      final CancelResult early = ConsultBookingEngine.cancelBooking(
        paidEarly,
        now: DateTime(2026, 12, 3, 10, 0),
        byAstrologer: false,
      );
      expect(early.outcome, CancelOutcome.cancelled);
      expect(early.booking!.refundDue, isTrue);
      expect(early.booking!.status, BookingStatus.cancelledByUser);
      final ConsultBooking paidLate = book(
        startsAt: DateTime(2026, 12, 5, 10, 0),
        paymentRequired: true,
        verifiedPayment: true,
      ).booking!;
      final CancelResult late = ConsultBookingEngine.cancelBooking(
        paidLate,
        now: DateTime(2026, 12, 4, 12, 0),
        byAstrologer: false,
      );
      expect(late.outcome, CancelOutcome.cancelled);
      expect(late.booking!.refundDue, isFalse);
      final ConsultBooking unpaid = book().booking!;
      final CancelResult unpaidCancel =
          ConsultBookingEngine.cancelBooking(
        unpaid,
        now: DateTime(2026, 12, 3, 10, 0),
        byAstrologer: false,
      );
      expect(unpaidCancel.booking!.refundDue, isFalse);
      expect(
        unpaidCancel.booking!.refundReason,
        contains('No payment was taken'),
      );
      final CancelResult refunded =
          ConsultBookingEngine.cancelBooking(
        early.booking!,
        now: DateTime(2026, 12, 3, 11, 0),
        byAstrologer: false,
      );
      expect(refunded.outcome, CancelOutcome.alreadyClosed);
      final ConsultBooking refundDone =
          ConsultBookingEngine.markRefunded(early.booking!);
      expect(refundDone.status, BookingStatus.refunded);
      expect(
        () => ConsultBookingEngine.markRefunded(late.booking!),
        throwsStateError,
      );
    });

    test('cancel after the start is refused', () {
      final ConsultBooking booking = book().booking!;
      final CancelResult result = ConsultBookingEngine.cancelBooking(
        booking,
        now: DateTime(2026, 12, 5, 10, 5),
        byAstrologer: false,
      );
      expect(result.outcome, CancelOutcome.tooLate);
    });

    test('completion and reviews need a finished consult', () {
      final ConsultBooking booking = book().booking!;
      expect(
        () => ConsultBookingEngine.completeBooking(
          booking,
          now: DateTime(2026, 12, 5, 10, 15),
        ),
        throwsStateError,
      );
      final ConsultBooking done = ConsultBookingEngine.completeBooking(
        booking,
        now: DateTime(2026, 12, 5, 10, 31),
      );
      expect(done.status, BookingStatus.completed);
      expect(
        () => ConsultBookingEngine.addReview(
          booking: booking,
          rating: 5,
          text: 'Good consult',
          alreadyReviewed: false,
        ),
        throwsStateError,
      );
      expect(
        () => ConsultBookingEngine.addReview(
          booking: done,
          rating: 6,
          text: 'Too high',
          alreadyReviewed: false,
        ),
        throwsArgumentError,
      );
      final ConsultReview review = ConsultBookingEngine.addReview(
        booking: done,
        rating: 5,
        text: 'Good consult',
        alreadyReviewed: false,
      );
      expect(review.rating, 5);
      expect(review.astrologerId, 'astro_1');
      expect(
        () => ConsultBookingEngine.addReview(
          booking: done,
          rating: 4,
          text: 'Again',
          alreadyReviewed: true,
        ),
        throwsStateError,
      );
    });
  });

  group('Notification preferences', () {
    test('defaults are on with a 06:00 alert', () {
      const NotificationPreferences prefs = NotificationPreferences();
      expect(prefs.dailyHoroscope, isTrue);
      expect(prefs.consultReplies, isTrue);
      expect(prefs.adminAnnouncements, isTrue);
      expect(prefs.alertTime, '06:00');
      expect(
        prefs.toMap(),
        <String, Object?>{
          'dailyHoroscope': true,
          'consultReplies': true,
          'adminAnnouncements': true,
          'alertTime': '06:00',
        },
      );
    });

    test('stored map round trips and bad values throw', () {
      final NotificationPreferences prefs =
          NotificationPreferences.fromMap(<String, dynamic>{
        'dailyHoroscope': false,
        'alertTime': '07:30',
      });
      expect(prefs.dailyHoroscope, isFalse);
      expect(prefs.consultReplies, isTrue);
      expect(prefs.alertTime, '07:30');
      expect(
        () => NotificationPreferences.fromMap(<String, dynamic>{
          'alertTime': '25:00',
        }),
        throwsFormatException,
      );
      expect(
        () => NotificationPreferences.fromMap(<String, dynamic>{
          'dailyHoroscope': 'yes',
        }),
        throwsFormatException,
      );
    });

    test('next alert follows the schedule or is null when off', () {
      const NotificationPreferences on = NotificationPreferences();
      expect(
        on.nextDailyAlertAfter(DateTime(2026, 11, 28, 5, 0)),
        DateTime(2026, 11, 28, 6, 0),
      );
      const NotificationPreferences off = NotificationPreferences(
        dailyHoroscope: false,
      );
      expect(off.nextDailyAlertAfter(DateTime(2026, 11, 28, 5, 0)), isNull);
    });
  });

  group('Notification deep links', () {
    test('every known target parses', () {
      expect(
        NotificationDeepLink.parse(
          <String, String>{'target': 'Daily Horoscope'},
        ).target,
        NotificationTarget.horoscope,
      );
      expect(
        NotificationDeepLink.parse(
          <String, String>{'openScreen': 'Panchang'},
        ).target,
        NotificationTarget.panchang,
      );
      expect(
        NotificationDeepLink.parse(
          <String, String>{'openScreen': 'Consult'},
        ).target,
        NotificationTarget.consult,
      );
      final NotificationDeepLink chat = NotificationDeepLink.parse(
        <String, String>{
          'target': 'chat',
          'chatId': 'chat_astro_1_user_1',
        },
      );
      expect(chat.target, NotificationTarget.chat);
      expect(chat.chatId, 'chat_astro_1_user_1');
    });

    test('chat without a chat id and unknown targets fall back', () {
      expect(
        NotificationDeepLink.parse(
          <String, String>{'target': 'chat'},
        ).target,
        NotificationTarget.consult,
      );
      expect(
        NotificationDeepLink.parse(
          <String, String>{'target': 'SomethingElse'},
        ).target,
        NotificationTarget.home,
      );
      expect(
        NotificationDeepLink.parse(<String, String>{}).target,
        NotificationTarget.home,
      );
    });
  });

  group('FCM token storage', () {
    test('token is stored and removed on the user document', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await NotificationService.storeToken(
        uid: 'user_1',
        token: 'token_abc',
        firestore: service,
      );
      Map<String, dynamic>? doc = await service.getUserProfile('user_1');
      expect(doc, isNotNull);
      expect(doc!['fcmTokens'], <Object?>['token_abc']);
      await NotificationService.storeToken(
        uid: 'user_1',
        token: 'token_abc',
        firestore: service,
      );
      doc = await service.getUserProfile('user_1');
      expect(doc!['fcmTokens'], <Object?>['token_abc']);
      await NotificationService.removeToken(
        uid: 'user_1',
        token: 'token_abc',
        firestore: service,
      );
      doc = await service.getUserProfile('user_1');
      expect(doc!['fcmTokens'], <Object?>[]);
    });

    test('empty token stores nothing', () async {
      final FakeFirebaseFirestore fake = FakeFirebaseFirestore();
      final FirestoreService service = FirestoreService(firestore: fake);
      await NotificationService.storeToken(
        uid: 'user_1',
        token: '',
        firestore: service,
      );
      expect(await service.getUserProfile('user_1'), isNull);
    });
  });
}
