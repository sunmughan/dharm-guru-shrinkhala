# PDF and Payment Test Report

* Status: NOT_TESTED, because neither feature exists in code
* Date: 28 Nov 2026
* Branch: phase1218-ci

## PDF generation

* No PDF library is in pubspec.yaml
* No PDF generation code exists in lib/
* No PDF test exists in test/
* No PDF artifact is produced by CI
* Status: NOT_TESTED, and the feature itself is NOT_IMPLEMENTED
* To test it later: add the PDF feature, then record generation
  time for a Kundli PDF and a report PDF, file size, and a visual
  check of the output on one phone and one desktop browser

## Payments

* No payment library is in pubspec.yaml. No Razorpay, Cashfree,
  Stripe, PhonePe or PayU integration exists in code.
* No payment test exists in test/
* Premium is gated only by the Remote Config flag premium_enabled,
  currently false, and the flag is not fully wired into user screens
* No price is decided and no price is stored in code
* Status: NOT_TESTED, and the feature itself is NOT_IMPLEMENTED
* To test it later: decide the provider and the price first, then
  record a real test payment, a refund, and a failed payment, with
  the receipt and the Firestore payment record for each

## What is NOT claimed here

* No PDF time, no payment success and no checkout proof is claimed
* The PERFORMANCE_REPORT.md lists PDF generation time as a metric
  to measure, with the value NOT_TESTED until the feature exists
* This report stays NOT_TESTED until the features land and a test
  run records real results
