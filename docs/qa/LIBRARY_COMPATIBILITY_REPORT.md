# Library Compatibility Report

* Status: PASS for the inventory below, NOT_TESTED for live device and web runtime behaviour
* Date: 28 Nov 2026
* Branch: phase1218-ci
* Source: pubspec.yaml, version 0.1.0+10, Dart SDK ^3.13.0, Flutter >=3.47.0

## Dependencies in use

| Library | Version | Use |
| material_ui | ^1.11.1 | UI components, replaces material.dart |
| firebase_core | ^3.8.0 | Firebase init |
| firebase_auth | ^5.3.1 | Email, Google and phone auth |
| cloud_firestore | ^5.4.4 | Firestore data |
| firebase_messaging | ^15.1.3 | Push notifications |
| firebase_remote_config | ^5.1.5 | premium_enabled and live_consult_enabled flags |
| firebase_analytics | ^11.3.3 | Analytics |
| google_sign_in | ^6.2.1 | Google sign in |
| shared_preferences | ^2.5.0 | Local flags, notification prompt shown |
| url_launcher | ^6.3.1 | Open links |
| cupertino_icons | ^1.0.8 | iOS style icons |
| flutter_lints | ^4.0.0 | Lint rules, dev only |
| fake_cloud_firestore | ^3.1.0 | In memory Firestore for tests, dev only |

## License verification

* Status: NOT_TESTED
* No license audit was run in this phase. Every dependency above is
  a public pub.dev package, but no license text was collected and no
  compatibility check was recorded.
* To complete: run a license report on CI, collect the license of
  every direct and transitive dependency, and record any copyleft
  or attribution requirement here.

## Compatibility notes

* This phase added no new dependency. Calculation caching, pagination,
  validation, retry and redacted logging use only Dart and Flutter
  SDK code plus the dependencies already in pubspec.yaml.
* firebase_storage is NOT a dependency. Storage rules exist in
  firebase/storage.rules, but the app cannot use Storage until the
  dependency and a console bucket are added by another phase.
* No PDF library is a dependency. PDF generation does not exist in
  code, see PDF_AND_PAYMENT_TEST_REPORT.md.
* No payment library is a dependency. No payment flow exists in code.
* No flutter_secure_storage dependency exists. Secure Storage rules
  are therefore NOT implemented, see PERFORMANCE_REPORT.md.
* CI uses subosito/flutter-action@v2 with channel stable, unpinned.
  The exact Flutter version on the runner is whatever stable resolves
  to on the run date. Pinning the version is a P3 follow up, because
  an unpinned channel can move under a release build.

## What was checked

* pubspec.yaml parses, version 0.1.0+10
* No new dependency was added by this phase, verified by git diff
* flutter pub get runs in CI in every job that needs it
