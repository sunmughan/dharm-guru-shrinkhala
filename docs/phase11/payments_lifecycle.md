# Payments lifecycle design, Phase 11

Status: DESIGN ONLY. No payment provider is integrated, no
payment can be taken, and no price exists. This document and
`lib/services/payment_lifecycle.dart` are the design and the
state machine. Nothing here calls a provider.

## Trusted backend flow

The client never decides that a payment succeeded. The flow
is:

1. Trusted backend creates the order and the payment request.
   The order carries an idempotency key, set once, so a retry
   never creates a second order for one purchase.
2. Provider response is verified on the backend. The client
   only displays what the backend confirms.
3. Webhook signature is validated on the backend, with the
   provider webhook secret. A bad signature fails the order
   at once and nothing is granted.
4. Transaction is verified on the server side: the backend
   reads the transaction from the provider with the provider
   reference and checks amount, currency, order id and status
   against the stored order.
5. Entitlement is applied exactly once: the backend applies
   it inside a transaction guarded by the order state, and a
   second application throws. `applyEntitlement` in code
   enforces this.
6. Transaction record is stored in the payments collection.
   The Firestore rules already allow only the owner to read
   and write payments, which is correct for backend writes.
   The client must never write to payments.
7. Duplicate webhooks are ignored by idempotency key: the
   backend keeps the applied event ids per order, and a
   repeated event id returns duplicateIgnored with the order
   unchanged. `applyWebhook` in code proves this.
8. Cancellation, refund and reconciliation run on the backend,
   see below.

## Cancellation

Cancel is allowed before entitlement. When the provider
refuses the cancellation, the order stays as it was. It is
never marked cancelled on a failed cancel call. The caller
retries or escalates to manual review. After entitlement the
cancel path is closed and the refund path must be used.

## Refund

Only a completed order holds money that can be refunded.
`requestRefund` then `completeRefund` move the order to
refunded. The refund itself is executed by the backend
against the provider, with the provider refund reference
stored on the transaction record. A refund for a consult
booking follows the booking rules in
`lib/services/consult_booking.dart`: full refund when the
user cancels at least 24 hours before the start, no refund
inside 24 hours, and no refund when no payment was taken.

## Reconciliation

A daily backend job compares three lists: the provider
settlement report, the payments collection, and the
entitlements granted. Every mismatch goes to manual review.
Nothing is auto fixed, and no entitlement is granted by
reconciliation alone: a missing entitlement is granted only
after the transaction is verified again on the server side.

## What is BLOCKED, exact config needed

1. Provider not chosen. No merchant account exists, no
   provider SDK is added, and no decision is recorded.
2. No credentials. No API keys and no webhook secret exist
   anywhere, and none may be put in chat or in files.
3. No price. Remote Config `premium_enabled` is false and no
   plan price is decided, so `amountMinor` has no real value
   to carry. No amount is invented in code.
4. No trusted backend. No Cloud Function is deployed. The
   Blaze plan is not confirmed, and Cloud Functions 2nd gen
   needs it for a deployed backend.
5. No webhook endpoint. No URL is registered with any
   provider, so no webhook can arrive.
6. No reconciliation job. It needs items 1, 4 and 5 first.

Until every item above is done by the owner, payments stay
in the designed state and the premium gate stays off.
