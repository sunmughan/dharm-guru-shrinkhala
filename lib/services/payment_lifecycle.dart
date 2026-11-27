/// Payment lifecycle, pure logic with no provider call.
/// No provider is configured and no price exists, so this file
/// is the design and the state machine only. It never talks to
/// a payment provider, and it never marks a payment successful
/// from a client value. The only path to paid runs through
/// recordProviderResponse with a valid signature, then
/// markVerified, and both of those calls belong to the trusted
/// backend only. See docs/phase11/payments_lifecycle.md for
/// the full flow and the exact config blockers.
enum PaymentState {
  created,
  providerRequested,
  providerResponded,
  verified,
  entitlementApplied,
  completed,
  failed,
  cancelled,
  refundRequested,
  refunded,
}

/// What a provider webhook can say. The backend maps the real
/// provider event to one of these after it checks the webhook
/// signature. An unknown provider event maps to nothing here.
enum PaymentWebhookKind {
  paymentCaptured,
  paymentFailed,
  paymentCancelled,
  refundCompleted,
}

/// What happened when a webhook was applied.
enum WebhookOutcome {
  applied,
  duplicateIgnored,
  rejected,
}

/// One payment order. Amount is in the smallest currency unit,
/// for example paise for INR or cents for USD, and currency is
/// the three letter code. The idempotency key is set once at
/// creation and is what makes a retry safe: the same key must
/// never create a second order for the same purchase.
class PaymentOrder {
  const PaymentOrder({
    required this.orderId,
    required this.userId,
    required this.amountMinor,
    required this.currency,
    required this.idempotencyKey,
    required this.state,
    this.providerReference,
  });

  final String orderId;
  final String userId;
  final int amountMinor;
  final String currency;
  final String idempotencyKey;
  final PaymentState state;
  final String? providerReference;

  PaymentOrder copyWith({
    PaymentState? state,
    String? providerReference,
  }) {
    return PaymentOrder(
      orderId: orderId,
      userId: userId,
      amountMinor: amountMinor,
      currency: currency,
      idempotencyKey: idempotencyKey,
      state: state ?? this.state,
      providerReference: providerReference ?? this.providerReference,
    );
  }

  /// True only after the trusted backend verified the payment.
  /// A client value can never make this true.
  bool get isPaid {
    return state == PaymentState.verified ||
        state == PaymentState.entitlementApplied ||
        state == PaymentState.completed;
  }

  bool get isTerminal {
    return state == PaymentState.completed ||
        state == PaymentState.failed ||
        state == PaymentState.cancelled ||
        state == PaymentState.refunded;
  }
}

/// The lifecycle steps, in order, as the design documents them.
/// Tests assert this list stays complete, so the doc and the
/// code cannot drift apart silently.
const List<String> kPaymentLifecycleSteps = <String>[
  'Trusted backend creates the order and the payment request',
  'Provider response is verified on the backend',
  'Webhook signature is validated on the backend',
  'Transaction is verified on the server side',
  'Entitlement is applied exactly once',
  'Transaction record is stored',
  'Duplicate webhooks are ignored by idempotency key',
  'Cancellation, refund and reconciliation run on the backend',
];

class PaymentLifecycle {
  PaymentLifecycle._();

  /// Creates an order. Rejects bad input at once: empty ids,
  /// zero or negative amount, or a currency that is not three
  /// uppercase letters.
  static PaymentOrder create({
    required String orderId,
    required String userId,
    required int amountMinor,
    required String currency,
    required String idempotencyKey,
  }) {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId must not be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('userId must not be empty');
    }
    if (amountMinor <= 0) {
      throw ArgumentError('amountMinor must be above zero');
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw ArgumentError('currency must be three uppercase letters');
    }
    if (idempotencyKey.isEmpty) {
      throw ArgumentError('idempotencyKey must not be empty');
    }
    return PaymentOrder(
      orderId: orderId,
      userId: userId,
      amountMinor: amountMinor,
      currency: currency,
      idempotencyKey: idempotencyKey,
      state: PaymentState.created,
    );
  }

  static PaymentOrder requestProvider(PaymentOrder order) {
    _require(order, <PaymentState>{PaymentState.created});
    return order.copyWith(state: PaymentState.providerRequested);
  }

  /// Records the provider response. signatureValid is the
  /// result of the backend webhook signature check, never a
  /// client claim. A bad signature fails the order at once.
  static PaymentOrder recordProviderResponse(
    PaymentOrder order, {
    required String providerReference,
    required bool signatureValid,
  }) {
    _require(order, <PaymentState>{PaymentState.providerRequested});
    if (providerReference.isEmpty) {
      throw ArgumentError('providerReference must not be empty');
    }
    if (!signatureValid) {
      return order.copyWith(
        state: PaymentState.failed,
        providerReference: providerReference,
      );
    }
    return order.copyWith(
      state: PaymentState.providerResponded,
      providerReference: providerReference,
    );
  }

  /// Server side verification passed. This is the only step
  /// that makes isPaid true, and only the backend calls it.
  static PaymentOrder markVerified(PaymentOrder order) {
    _require(order, <PaymentState>{PaymentState.providerResponded});
    return order.copyWith(state: PaymentState.verified);
  }

  /// Applies the entitlement, for example premium access.
  /// Calling it twice throws, so a retried webhook or a
  /// retried job can never grant the entitlement twice.
  static PaymentOrder applyEntitlement(PaymentOrder order) {
    _require(order, <PaymentState>{PaymentState.verified});
    return order.copyWith(state: PaymentState.entitlementApplied);
  }

  static PaymentOrder complete(PaymentOrder order) {
    _require(order, <PaymentState>{PaymentState.entitlementApplied});
    return order.copyWith(state: PaymentState.completed);
  }

  /// Fails the order from any state before entitlement.
  /// After entitlement the refund path must be used instead.
  static PaymentOrder fail(PaymentOrder order) {
    _require(order, <PaymentState>{
      PaymentState.created,
      PaymentState.providerRequested,
      PaymentState.providerResponded,
      PaymentState.verified,
    });
    return order.copyWith(state: PaymentState.failed);
  }

  /// Cancels the order before entitlement. When the provider
  /// refuses the cancellation the order stays as it was and
  /// the caller retries or escalates to manual review, it is
  /// never marked cancelled on a failed cancel call.
  static PaymentOrder cancel(PaymentOrder order) {
    _require(order, <PaymentState>{
      PaymentState.created,
      PaymentState.providerRequested,
      PaymentState.providerResponded,
      PaymentState.verified,
    });
    return order.copyWith(state: PaymentState.cancelled);
  }

  /// Starts a refund. Only a completed order holds money that
  /// can be refunded.
  static PaymentOrder requestRefund(PaymentOrder order) {
    _require(order, <PaymentState>{PaymentState.completed});
    return order.copyWith(state: PaymentState.refundRequested);
  }

  static PaymentOrder completeRefund(PaymentOrder order) {
    _require(order, <PaymentState>{PaymentState.refundRequested});
    return order.copyWith(state: PaymentState.refunded);
  }

  /// Applies one webhook event. seenEventIds holds the event
  /// ids already applied for this order. A repeated event id
  /// is ignored and the order is returned unchanged, so a
  /// provider retry can never move the order twice. An event
  /// that does not fit the current state is rejected and the
  /// order is returned unchanged. Returns the new order, the
  /// outcome, and the updated seen set.
  static ({
    PaymentOrder order,
    WebhookOutcome outcome,
    Set<String> seenEventIds,
  }) applyWebhook({
    required PaymentOrder order,
    required String eventId,
    required Set<String> seenEventIds,
    required PaymentWebhookKind kind,
    String? providerReference,
    bool signatureValid = false,
  }) {
    if (eventId.isEmpty) {
      return (
        order: order,
        outcome: WebhookOutcome.rejected,
        seenEventIds: seenEventIds,
      );
    }
    if (seenEventIds.contains(eventId)) {
      return (
        order: order,
        outcome: WebhookOutcome.duplicateIgnored,
        seenEventIds: seenEventIds,
      );
    }
    final Set<String> seen = <String>{...seenEventIds};
    try {
      late final PaymentOrder next;
      switch (kind) {
        case PaymentWebhookKind.paymentCaptured:
          if (providerReference == null || providerReference.isEmpty) {
            return (
              order: order,
              outcome: WebhookOutcome.rejected,
              seenEventIds: seenEventIds,
            );
          }
          final PaymentOrder responded = recordProviderResponse(
            order,
            providerReference: providerReference,
            signatureValid: signatureValid,
          );
          next = signatureValid ? markVerified(responded) : responded;
        case PaymentWebhookKind.paymentFailed:
          next = fail(order);
        case PaymentWebhookKind.paymentCancelled:
          next = cancel(order);
        case PaymentWebhookKind.refundCompleted:
          next = completeRefund(order);
      }
      seen.add(eventId);
      return (order: next, outcome: WebhookOutcome.applied, seenEventIds: seen);
    } on StateError {
      return (
        order: order,
        outcome: WebhookOutcome.rejected,
        seenEventIds: seenEventIds,
      );
    }
  }

  static void _require(PaymentOrder order, Set<PaymentState> allowed) {
    if (!allowed.contains(order.state)) {
      throw StateError(
        'Payment ${order.orderId} in state ${order.state} '
        'cannot move from ${allowed.join(', ')}',
      );
    }
  }
}
