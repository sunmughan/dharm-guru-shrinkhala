# Firebase Integration Report

* Status: PASS for the console facts below, NOT_TESTED for live app integration, BLOCKED for emulator tests
* Date: 28 Nov 2026
* Branch: phase1218-ci

## Console facts, PASS

Verified live 28 Nov 2026 00:06 IST by a browser task, signed in as sunmughan@gmail.com:

* Project dharm-guru-shrinkhala, Spark plan kept, no Blaze, no payment method
* Firestore created in production mode, asia-south1
* Rules published from repo firebase/firestore.rules, live version 28 Nov 2026 00:01 IST
* Owner record created: admins collection, admin@gmail.com uid, field role owner
* Sign in providers all enabled: Email and Password, Phone, Google, support email sunmughan@gmail.com
* Remote Config published as Config Version 1, premium_enabled false, live_consult_enabled false
* Admin Android app verified with both SHA 1 fingerprints, Release and Debug
* Main Android app verified the same, no duplicates
* Admin iOS app registered, bundle com.codeair.dharmgurushrinkhala.admin

## Live app integration, NOT_TESTED

* No live run in this phase signed in to the real app and read or
  wrote real Firestore data. Live production data was not touched.
* The in memory Firestore flow tests prove the service logic only:
  test/firestore_flow_test.dart, 3 tests, PASS in CI.
* The phone proof still owed by the user: install the release 10
  APKs, sign in to the admin app, tap publish live.

## Emulator tests, BLOCKED

* No Firestore emulator job exists in CI yet
* No Storage emulator, no Auth emulator, no Functions emulator
* To unblock: add the emulator job described in FIREBASE_SECURITY_REPORT.md

## New in this phase

* firebase/firestore.indexes.json: indexes for horoscopes by status
  and date, notifications by user and date, chats by participants
  and date, messages by date, payments by user and date, panchang
  by date. The file is valid JSON, checked in the CI rules-gate job.
  Live deploy of the indexes is NOT_TESTED.
* firebase/storage.rules: prepared default, deny all, owner only
  published writes. No bucket exists, so live status is NOT_TESTED.
* firebase.json now points at the rules, the indexes and the
  Storage rules files.
* Firestore pagination: FirestoreService.getDocsPaged, limit 25 by
  default, cursor by document id. Covered by PAGE-01 to PAGE-04
  in test/pagination_test.dart, PASS in CI.
* Calculation caching: Kundli and Panchang results are memoised in
  a bounded cache of 64 entries, keyed by inputs only, never by
  personal data. Covered by PERF-03 to PERF-05, PASS in CI.

## Remote Config

* Flags premium_enabled false and live_consult_enabled false are
  published in the console.
* The flags are NOT fully wired into user screens yet. No user
  screen branches on them. That gap is recorded in BASELINE_REPORT.md
  and stays open for the feature phases.
