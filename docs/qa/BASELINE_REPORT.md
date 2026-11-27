# Baseline Report

* Status: PASS for the baseline facts below, NOT_TESTED for everything this phase has not run yet
* Date: 28 Nov 2026
* Branch: phase1218-ci
* Baseline commit: eb0c471, release 10, version 0.1.0+10

## What release 10 proved

Release 10 was verified by the parent firsthand on HEAD eb0c471:
CI run 46043847890 green, all 3 jobs green, 111 tests, flutter analyze clean.

* Real Kundli, Panchang, Daily Horoscope draft versus publish, Matching 11/36 Low Match
* Remedies with Current Mahadasha Rahu, Consult Chat end to end
* Notifications scheduling, Profile save, Premium gated by Remote Config false
* Library with dasha timeline and festivals, all 8 admin screens
* Engine bug fixed: 30th tithi now Krishna Amavasya, was wrongly Krishna Purnima
* All sample and dummy data deleted from lib
* User APK 56,607,226 bytes, SHA 256 b168212d303d9428bd359909f418efddaa38b2a120aa4de48a79ab5a017eaa46
* Admin APK 55,508,558 bytes, SHA 256 1e83f8b8efb5c27006b1470c5c15476117b1a6e83c8d16a65170f76743736970
* Both signed with the permanent release key, SHA 1 D9:1A:02:84:0D:FE:F5:82:D3:3E:3E:9C:21:5A:77:D2:73:D7:89:A3

## What release 10 did not prove

* No live phone proof of install, sign in, publish live flow from the user
* No browser test run against the web builds
* No Firebase emulator rules test
* No Cloud Functions, because functions/ does not exist in the repo
* No PDF generation and no payment flow in code
* No performance numbers from a device

## Firebase console state at baseline

Verified live 28 Nov 2026 00:06 IST by a browser task, signed in as sunmughan@gmail.com:

* Firestore rules published from repo firebase/firestore.rules, live version 28 Nov 2026 00:01 IST
* Owner record created: admins collection, admin@gmail.com uid, field role owner
* Admin Android app verified with both SHA 1 fingerprints, Release and Debug
* Main Android app verified the same, no duplicates
* Admin iOS app registered: bundle com.codeair.dharmgurushrinkhala.admin, App ID 1:987289079284:ios:2bce40df3197896e143da1
* Rules Playground verified: owner write allowed, non owner write denied
* GoogleService Info plist download NOT done

## What changed in this phase

* Phase 12 quality helpers, calculation caching, pagination, validation, retry, redacted logging
* Phase 18 new automated tests, see REGRESSION_REPORT.md
* Phase 19 this docs/qa structure
* Phase 21 CI workflow update with format, coverage, rules gate, web builds, browser smoke, Cloud Functions job and release gate
* No feature code, no live production data touched, no live deploy

## Open baseline gaps carried forward

* Astrologer identity, pricing, Hindi copy, payment provider, Cloud Functions Blaze plan, Storage and FCM and App Check status to verify in Phase 0
* Default admin seed admin@gmail.com with admin123 is still in code and still ordered for removal after secure owner provisioning is proven
* Remote Config flags premium_enabled and live_consult_enabled are NOT fully wired into user screens yet
