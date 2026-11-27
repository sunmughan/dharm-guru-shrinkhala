# Feature Inventory and Coverage Matrix

* Date: 28 Nov 2026
* Branch: phase1218-ci
* Baseline: release 10, HEAD eb0c471

Every feature maps to implementation files, backend integration,
automated tests, browser test IDs and final status. Status words
are PASS, FAIL, BLOCKED and NOT_TESTED only.

## User app

| Feature | Implementation files | Backend integration | Automated tests | Browser test IDs | Final status |
| Auth email and password, sign up, sign in, forgot password, hard auth gate | lib/screens/auth_screen.dart, lib/services/auth_service.dart | Firebase Auth, Email and Password provider | test/google_signin_error_test.dart, test/admin_gate_test.dart | BT-USER-02, BT-USER-03, BT-USER-05, BT-USER-06 | NOT_TESTED in browser, logic PASS in CI |
| Auth Google sign in | lib/services/auth_service.dart | Firebase Auth, Google provider | test/admin_gate_test.dart | BT-USER-04 | NOT_TESTED in browser, logic PASS in CI |
| Auth Phone OTP | lib/services/auth_service.dart | Firebase Auth, Phone provider | None | None | NOT_TESTED |
| Kundli input form | lib/screens/profile_form_screen.dart | None, local input | test/input_validation_test.dart VAL-05 to VAL-09 | BT-USER-07, BT-USER-08 | NOT_TESTED in browser, validation PASS in CI |
| Kundli calculation and chart | lib/services/astro.dart, lib/widgets/kundli_chart.dart, lib/models/kundli.dart | None, pure calculation | test/astro_test.dart, test/proof_test.dart, test/performance_cache_test.dart PERF-01, PERF-03, PERF-04 | BT-USER-07 | NOT_TESTED in browser, calculation PASS in CI |
| Planet details | lib/widgets/planet_details.dart, lib/models/kundli.dart | None | test/proof_test.dart, test/model_serialization_test.dart SER-02 | BT-USER-09 | NOT_TESTED in browser, logic PASS in CI |
| Daily Horoscope | lib/screens/screens.dart, lib/models/panchang.dart | Firestore horoscopes, draft versus published | test/firestore_flow_test.dart, test/model_serialization_test.dart SER-04 | BT-USER-10, BT-USER-11 | NOT_TESTED in browser, logic PASS in CI |
| Panchang | lib/services/astro.dart, lib/models/panchang.dart | Firestore panchang, admin published | test/astro_test.dart, test/performance_cache_test.dart PERF-02, PERF-05, test/model_serialization_test.dart SER-03 | BT-USER-12 | NOT_TESTED in browser, calculation PASS in CI |
| Kundli Matching | lib/services/matching.dart | None, pure calculation | test/matching_test.dart, 11/36 Low Match | BT-USER-13 | NOT_TESTED in browser, logic PASS in CI |
| Remedies and Mahadasha | lib/services/remedies_engine.dart, lib/services/astro.dart, lib/models/remedies.dart | None, derived from computed chart | test/remedies_test.dart, test/model_serialization_test.dart SER-06 | BT-USER-14 | NOT_TESTED in browser, logic PASS in CI |
| Consult Chat | lib/services/chat_service.dart, lib/screens/screens.dart | Firestore chats and messages subcollection | test/chat_test.dart, test/proof_test.dart | BT-USER-17, BT-ASTRO-03, BT-ASTRO-04 | NOT_TESTED in browser, logic PASS in CI |
| Notifications scheduling | lib/services/notification_schedule.dart, lib/services/notification_service.dart | Firebase Messaging, Firestore notifications | test/notification_schedule_test.dart | None | NOT_TESTED live, logic PASS in CI |
| Profile save | lib/services/firestore_service.dart, lib/services/user_profile.dart | Firestore users/{uid} | test/firestore_flow_test.dart, test/model_serialization_test.dart SER-05 | BT-USER-15 | NOT_TESTED in browser, logic PASS in CI |
| Premium gating | lib/services/premium_service.dart, lib/services/firebase_service.dart | Remote Config premium_enabled false | test/premium_test.dart | BT-USER-18 | NOT_TESTED in browser, logic PASS in CI, flag NOT fully wired into screens |
| Library, dasha timeline, festivals | lib/services/library_content.dart | None, local content | test/library_test.dart | BT-USER-16 | NOT_TESTED in browser, logic PASS in CI |
| Home, splash, onboarding | lib/core/navigation/app_shell.dart, lib/screens/screens.dart | None | test/widget_test.dart | BT-USER-01 | NOT_TESTED in browser, widget PASS in CI |

## Admin app

| Feature | Implementation files | Backend integration | Automated tests | Browser test IDs | Final status |
| Admin dashboard | lib/screens/admin_screens.dart | Firestore users, astrologers, horoscopes, payments | test/admin_proof_test.dart | BT-ADMIN-01, BT-ADMIN-03 | NOT_TESTED in browser, logic PASS in CI |
| Manage Astrologers | lib/screens/admin_screens.dart | Firestore astrologers | test/admin_proof_test.dart | BT-ADMIN-04 | NOT_TESTED in browser, logic PASS in CI |
| Publish Daily Horoscope | lib/screens/admin_screens.dart | Firestore horoscopes, status draft and published | test/firestore_flow_test.dart | BT-ADMIN-05, BT-ADMIN-06 | NOT_TESTED in browser, logic PASS in CI |
| Subscriptions and Payments | lib/screens/admin_screens.dart | Firestore plans, payments | test/admin_proof_test.dart | BT-ADMIN-08 | NOT_TESTED in browser, logic PASS in CI |
| Analytics and Revenue | lib/screens/admin_screens.dart | Firestore payments, users | test/admin_proof_test.dart | BT-ADMIN-09 | NOT_TESTED in browser, logic PASS in CI |
| Push Notifications | lib/screens/admin_screens.dart | Firestore notifications, Firebase Messaging | test/notification_schedule_test.dart | BT-ADMIN-10 | NOT_TESTED in browser, logic PASS in CI |
| Content Moderation | lib/screens/admin_screens.dart | Firestore moderation | test/admin_proof_test.dart | BT-ADMIN-11 | NOT_TESTED in browser, logic PASS in CI |
| Admin gate and owner check | lib/screens/admin_screens.dart, lib/services/firestore_service.dart | Firestore admins/{uid} role owner | test/admin_gate_test.dart, test/negative_admin_test.dart NEG-01 to NEG-05 | BT-ADMIN-02, BT-ADMIN-12, BT-ADMIN-13, BT-ADMIN-14 | FAIL, P1 bypass open, see FIREBASE_SECURITY_REPORT.md |

## Backend and platform

| Feature | Implementation files | Backend integration | Automated tests | Browser test IDs | Final status |
| Firestore rules owner only | firebase/firestore.rules | Firestore rules, live version 28 Nov 2026 00:01 IST | test/security_rules_test.dart RULES-01 to RULES-06 | None | PASS static audit, BLOCKED emulator |
| Storage rules | firebase/storage.rules | None, no bucket yet | test/security_rules_test.dart RULES-07, RULES-08 | None | NOT_TESTED live |
| Firestore indexes | firebase/firestore.indexes.json | None, not deployed yet | CI rules-gate JSON check | None | NOT_TESTED live |
| Firestore pagination | lib/services/firestore_service.dart getDocsPaged | Firestore orderBy and limit | test/pagination_test.dart PAGE-01 to PAGE-04 | None | PASS in CI, no screen uses it yet |
| Calculation caching | lib/services/astro.dart, lib/core/performance.dart | None, local memo cache | test/performance_cache_test.dart PERF-03 to PERF-05, test/retry_test.dart CACHE-01 to CACHE-04 | None | PASS in CI |
| Input validation | lib/core/input_validation.dart | None | test/input_validation_test.dart VAL-01 to VAL-09 | BT-USER-08 | PASS in CI |
| BackoffRetry | lib/core/performance.dart | None | test/retry_test.dart RET-01 to RET-05 | None | PASS in CI |
| Redacted logging | lib/core/app_logger.dart | None | test/app_logger_test.dart LOG-01 to LOG-04 | None | PASS in CI |
| Model serialisation | lib/models/kundli.dart, lib/models/panchang.dart, lib/models/remedies.dart | Firestore maps | test/model_serialization_test.dart SER-01 to SER-07 | None | PASS in CI |
| Cloud Functions | None, functions/ does not exist | None | None | None | BLOCKED |
| PDF generation | None, no PDF library | None | None | None | NOT_IMPLEMENTED |
| Payments | None, no payment library | None | None | None | NOT_IMPLEMENTED |
| Data export | None | None | None | None | NOT_IMPLEMENTED |
| Account deletion | None | None | None | None | NOT_IMPLEMENTED |
| Audit history | None | None | None | None | NOT_IMPLEMENTED |
| Secure Storage | None, no flutter_secure_storage | None | None | None | NOT_IMPLEMENTED |
| Offline saved Kundli | None | None | None | None | NOT_IMPLEMENTED |
| Privacy settings | None | None | None | None | NOT_IMPLEMENTED |
| Rate limiting | None | None | None | None | NOT_IMPLEMENTED |
| Accessibility audit | None | None | None | None | NOT_TESTED |
| Responsive web layouts | None | None | None | None | NOT_TESTED |
| CI release gate | .github/workflows/flutter-analyze.yml | GitHub Actions | CI run on this branch | None | BLOCKED until Cloud Functions land |

## How other agents integrate here

* A phase that lands a feature adds one row to the table above,
  with the real files, the real tests and the real browser IDs.
* A phase that lands a report replaces the matching NOT_TESTED
  rows with PASS, FAIL or BLOCKED plus the evidence path.
* No row is ever marked PASS without a named test run, a named
  CI run, or a named browser log.
