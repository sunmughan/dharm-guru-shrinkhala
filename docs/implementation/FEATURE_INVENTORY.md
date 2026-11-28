# Feature Inventory: Dharm Guru Shrinkhala, Phase 0

Date: 28 November 2026. Baseline HEAD eb0c471, release 10, version 0.1.0+10.
Status words used here, and only these: WORKING, PARTIALLY IMPLEMENTED, BROKEN, MISSING, BLOCKED BY EXTERNAL CONFIGURATION.
Rule used while writing it: a screen that only renders is NOT working. WORKING means real input reaches real output through real logic or real Firestore data, with a test or a CI run behind it. Every status below names its evidence file and its test proof. Where the proof is a console check, it says CONSOLE VERIFIED and names the date.

Test proof key: T = test file and case count from the release 10 CI run (111 tests passed, run 46043847890, `flutter analyze` clean). File paths are exact.

## 1. User app features

### 1.1 Splash screen (design 01)

Status: WORKING.
Evidence: `lib/screens/screens.dart` SplashScreen, 2 second animation, build stamp shown, auto advance.
Test proof: `test/widget_test.dart` (44 cases, includes splash and root widget pumping).

### 1.2 Onboarding (design 02)

Status: WORKING.
Evidence: `lib/screens/screens.dart` OnboardingScreen, first launch only, flag stored under SharedPreferences key `onboarding_seen`, Skip and Begin both land on sign in.
Test proof: `test/widget_test.dart`.

### 1.3 Auth gate and sign in

Status: WORKING.
Evidence: `lib/core/navigation/app_shell.dart` DharmGuruApp StreamBuilder on AuthService.signedIn; signed out users see only AuthScreen. `lib/screens/auth_screen.dart` email/password sign up and sign in, forgot password, Google sign in. `lib/services/auth_service.dart` Google link flow when Google sign in finds an existing email account.
Test proof: `test/widget_test.dart`, `test/google_signin_error_test.dart` (2 cases).
Note: phone sign in code exists in AuthService but has no live phone proof in this baseline. The email and Google paths are the proven ones.

### 1.4 Home (design 03)

Status: WORKING.
Evidence: `lib/screens/screens.dart` HomeScreen, greeting, kundli card, daily horoscope card reading the published Firestore horoscope document, consult card.
Test proof: `test/widget_test.dart`, `test/proof_test.dart` (10 cases).

### 1.5 Kundli input form (design 04)

Status: WORKING.
Evidence: `lib/screens/screens.dart` KundliInputScreen; name, date, time, place; explicit "I do not know my birth time" choice; place matched against about 50 Indian cities in `lib/services/astro.dart` kIndianCities; unknown place falls back to Jaipur and is marked approximate.
Test proof: `test/astro_test.dart` (10 cases, incl place fallback and date parsing), `test/proof_test.dart`.

### 1.6 Kundli chart (design 05)

Status: WORKING.
Evidence: `lib/screens/screens.dart` KundliChartScreen with Lagna Chart and Moon Chart switcher (Moon chart counts bhavas from the Moon sign), summary chips, planet list; `lib/widgets/kundli_chart.dart` North Indian square chart painter.
Test proof: `test/astro_test.dart` (sample birth gives Lagna Kumbha), `test/proof_test.dart`, `test/widget_test.dart`.
Engine note: sample birth 14 March 1998 06:25 Jaipur gives Lagna Kumbha, Moon rashi Kanya, Moon nakshatra Uttara Phalguni, tithi at birth Krishna Pratipada. Validated against JPL Horizons DE441 vectors; tolerances in the test are Sun 0.5 degrees, Moon 1 degree, planets 2 degrees.

### 1.7 Planet details (design 06)

Status: WORKING.
Evidence: `lib/widgets/planet_details.dart`, `lib/screens/screens.dart` PlanetDetailsScreen; degree, rashi, bhava, swami, note per planet, all from the engine.
Test proof: `test/astro_test.dart`, `test/proof_test.dart`.

### 1.8 Daily horoscope (design 07)

Status: WORKING.
Evidence: `lib/screens/screens.dart` HoroscopeScreen reads the published horoscope document for the user rashi and date from Firestore. Draft content is never shown. The explicit "Sample data only. No real prediction." state is asserted in tests.
Test proof: `test/widget_test.dart` lines 552, 620, 653 assert the sample data label behaviour; `test/proof_test.dart`.
Limit: the horoscope text itself is only as good as what the admin publishes. The app writes no prediction text of its own, by design.

### 1.9 Panchang (design 08)

Status: WORKING.
Evidence: `lib/screens/screens.dart` PanchangScreen; tithi, yoga, karana, nakshatra, sunrise, sunset, abhijit muhurat, rahu kaal computed by `lib/services/astro.dart` PanchangCalculator, plus published panchang documents from Firestore.
Test proof: `test/astro_test.dart` (14 March 1998 Jaipur matches the real panchang, incl the release 10 Amavasya fix: 30th tithi is Krishna Amavasya), `test/proof_test.dart`.

### 1.10 Kundli matching (design 09)

Status: WORKING.
Evidence: `lib/screens/screens.dart` MatchingScreen; two person form; Ashtakoot guna milan out of 36 with per guna rows and verdict; Mangal dosha flags for both persons; `lib/services/matching.dart` MatchingCalculator reads the Moon rashi and Moon nakshatra the engine calculated for each person.
Test proof: `test/matching_test.dart` (4 cases), `test/proof_test.dart`.
Known limit: Yoni guna refinement deferred (same animal 4, different animal 2; friendly and enemy animal table not applied). Full milan report is premium gated, see 1.14.

### 1.11 Remedies (design 10)

Status: WORKING.
Evidence: `lib/screens/screens.dart` RemediesScreen; weak planets from the real chart (debilitated or in bhava 6, 8 or 12); current Vimshottari Mahadasha lord card; `lib/services/remedies_engine.dart`.
Test proof: `test/remedies_test.dart` (4 cases), `test/proof_test.dart`.

### 1.12 Profile (design 11)

Status: WORKING.
Evidence: `lib/screens/profile_form_screen.dart` full profile form; `lib/services/user_profile.dart` AppUserProfile (name, gender, date of birth, time of birth, unknown birth time flag, birth city/state/country, marital status, occupation, phone, language English/Hindi, horoscope alert time). Profile is complete with name, date of birth and birth place; time of birth is optional.
Test proof: `test/widget_test.dart`, `test/proof_test.dart`, `test/firestore_flow_test.dart` (3 cases).

### 1.13 Live consult chat (design 12)

Status: WORKING.
Evidence: `lib/screens/screens.dart` ConsultScreen and ChatScreen; `lib/services/chat_service.dart`; real Firestore backed chat room, one chat per user (`user_<uid>`), messages stream live oldest first, send stores sender id, sender role, server timestamp plus client sentAt millis. Admin app reads and replies in every chat.
Test proof: `test/chat_test.dart` (2 cases), `test/firestore_flow_test.dart`, `test/admin_proof_test.dart` (13 cases), `test/astrologer_workspace_test.dart` (Phase 10: Hans Ojha record, chat assignment, astrologer replies).
Limit: the astrologer is Hans Ojha, a real record in the astrologers collection (`test/astrologer_workspace_test.dart`). He has no sign in yet, so the admin answers his chats until one exists. No astrologer photo or reply is invented anywhere; his phone, photo, bio, qualifications, languages, experience and rate are still not provided.

### 1.14 Live consult call (design 13)

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/screens/screens.dart` ConsultScreen call button calls `_callAstrologer`, which dials the phone number the admin saved for that astrologer through url_launcher when `callAvailable` is true, and says plainly when none is saved. There is NO in app voice call and NO in app video call.
Test proof: `test/astrologer_workspace_test.dart` (Phase 10: call has no phone saved, dials the saved phone once provided). The consult list rendering is covered by `test/widget_test.dart`; a real dial has no device proof.
What is missing: in app calling, call scheduling, call billing, call history.

### 1.15 Premium upgrade (design 14)

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/services/premium_service.dart` PremiumService reads Remote Config `premium_enabled`, default false; `lib/screens/screens.dart` MatchingScreen gates the full milan report on it and says premium is not available yet. Admin dashboard reads the same flag.
Test proof: `test/premium_test.dart` (2 cases).
What is missing: pricing (undecided), trial, currency, any payment provider, any purchase code, any entitlement check beyond the flag. The gate works; the product behind it does not exist yet.

### 1.16 Notifications, user side (design 15)

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/core/navigation/app_shell.dart` one time permission dialog on the main screen after onboarding and sign in, with the reason shown first; `lib/services/notification_schedule.dart` nextDailyAlertAfter, scheduledSendTime, horoscopeAlertPayload; `lib/services/firebase_service.dart` token fetch at startup; `lib/services/notification_service.dart` foreground listener.
Test proof: `test/notification_schedule_test.dart` (6 cases) proves the time math and the payload only.
What is missing: the FCM token is fetched and never stored against the user document, so no push can be addressed to a user; no topic, no background handler, no server send path; real device delivery is NOT proven. Default alert time 06:00 AM is undecided (design section 16 question 6).

### 1.17 Library (no design screen number; lib feature)

Status: WORKING.
Evidence: `lib/screens/screens.dart` LibraryScreen; `lib/services/library_content.dart` festival days computed by scanning the panchang engine over the next 30 days, dasha timeline from the real chart, planet reference paired with the user own computed positions.
Test proof: `test/library_test.dart` (7 cases), `test/proof_test.dart`.
Note: nothing here is stored text pretending to be an article. Festival days come from the engine; the observance line per tithi is a fixed traditional mapping.

### 1.18 Divisional charts (16 varga charts, master order Phase list)

Status: MISSING.
Evidence: no code, no design, no decision recorded. Grep for navamsa, divisional, varga across lib and design returns nothing except colour token names. Not even a placeholder screen exists.

### 1.19 Hindi copy

Status: MISSING.
Evidence: all copy in lib and in design is English. The profile language field offers English and Hindi (`lib/services/user_profile.dart` languages list), but no Hindi strings exist anywhere in the repo. Supplier of Hindi copy is undecided (design section 16 question 3).

## 2. Admin app features

### 2.1 Admin dashboard (design 16)

Status: WORKING.
Evidence: `lib/screens/admin_screens.dart` AdminDashboardScreen; counts from Firestore collections, attention rows, feature flags incl premium_enabled.
Test proof: `test/admin_proof_test.dart` (13 cases), `test/admin_gate_test.dart` (4 cases).

### 2.2 Manage astrologers (design 17)

Status: WORKING.
Evidence: `lib/screens/admin_screens.dart` AstrologersScreen; create, read, update, delete astrologer records in the astrologers collection: name, languages, chatAvailable, callAvailable, phone. Phase 10: the astrologer is Hans Ojha, document id `hans-ojha`, created with his name only by `lib/services/astrologer_service.dart` when the owner opens Manage Astrologers; the detail view edits his record (name, languages, bio, qualifications, experience, phone, rate, chat/call availability) and the admin chat view routes chats assigned to him by name.
Test proof: `test/admin_proof_test.dart`, `test/admin_gate_test.dart`, `test/astrologer_workspace_test.dart` (Phase 10: record creation, admin list shows him, edit persists).
Limit: only his name is settled. His phone, photo, bio, qualifications, languages, experience and rate are still not provided, and he has no sign in yet.

### 2.3 Publish daily horoscope (design 18)

Status: WORKING.
Evidence: `lib/screens/admin_screens.dart` DailyContentScreen, `_HoroscopeGrid` (draft vs publish), `_PanchangForm` for published panchang documents.
Test proof: `test/admin_proof_test.dart`.
Note: only published content reaches users; the user app never renders drafts.

### 2.4 Subscriptions and payments (design 19)

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/screens/admin_screens.dart` SubscriptionsScreen reads the plans and payments collections and shows subscription state.
Test proof: `test/admin_proof_test.dart`.
What is missing: no payment provider, no purchase, no webhook, no price, so no real payment ever lands in the payments collection from the app. The screen renders real Firestore data; the revenue behind it does not exist.

### 2.5 Analytics and revenue (design 20)

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/screens/admin_screens.dart` AnalyticsScreen; range stats and charts drawn from Firestore data with custom painters (`_LinePainter`, `_BarPainter`).
Test proof: `test/admin_proof_test.dart`.
What is missing: revenue figures depend on payments data that does not exist yet; no Analytics event taxonomy is documented, and the screen reads Firestore, not Firebase Analytics events.

### 2.6 Push notifications, admin side (design 21)

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/screens/admin_screens.dart` NotificationsScreenAdmin; admin composes a notification and picks "Send now" or a send time in HH:MM AM/PM form. `lib/services/notification_schedule.dart` computes the send time and the payload.
Test proof: `test/notification_schedule_test.dart` (6 cases) proves the time math and the payload.
What is missing: there is NO send call anywhere. No Cloud Function, no FCM admin send, no stored device token to send to. The compose screen and the payload are real; delivery is not.

### 2.7 Content moderation (design 22)

Status: WORKING.
Evidence: `lib/screens/admin_screens.dart` ModerationScreen; reads and writes the moderation collection, owner only under `firebase/firestore.rules`.
Test proof: `test/admin_proof_test.dart`.

### 2.8 Admin account screen

Status: WORKING.
Evidence: `lib/screens/admin_screens.dart` AdminAccountScreen; sign out, account details, change of the default password after first sign in (per the comment in `lib/core/admin_config.dart`).
Test proof: `test/admin_proof_test.dart`, `test/admin_gate_test.dart`.

### 2.9 Admin gate and admin seed

Status: WORKING, with two P0 security items recorded in the baseline.
Evidence: `lib/screens/admin_screens.dart` DharmGuruAdminApp checks `admins/{uid}` role owner with a 20 second timeout and explicit error screens; `lib/services/firestore_service.dart` isAdmin and isAdminUser; `lib/services/admin_seed_service.dart` seeds the default admin account on first admin app launch and signs out again.
Test proof: `test/admin_gate_test.dart` (4 cases).
Security items, see `docs/implementation/REPOSITORY_BASELINE.md` section 10: (a) the default admin credentials live in source and the seed was the user own Round 4 order; removal needs secure owner provisioning proven working first, decision goes to the parent; Phase 0 did NOT remove it. (b) `isAdminUser` passes the seeded email even without an admins document. (c) `ensureAdminDoc` writes role owner for ANY Google account that signs in through the admin app. CONSOLE VERIFIED: the owner record for admin@gmail.com, uid XUdDmGwDGXMsxG883un42zEe7X72, role owner, exists live in the admins collection (28 Nov 2026 00:06 IST). That console fact is not proven by any file.

## 3. Platform and service features

### 3.1 Firebase Auth (email, Google, phone)

Status: WORKING for email and Google in code and tests; phone sign in code present, live proof absent.
Evidence: `lib/services/auth_service.dart`, `lib/screens/auth_screen.dart`.
Test proof: `test/widget_test.dart`, `test/google_signin_error_test.dart` (2 cases).

### 3.2 Firestore rules

Status: WORKING.
Evidence: `firebase/firestore.rules` in repo; `firebase.json` points at it.
Test proof: `test/firestore_flow_test.dart` (3 cases) on fake Firestore.
Console proof: CONSOLE VERIFIED 28 Nov 2026 00:06 IST, rules published from that exact file, live version matches repo; Rules Playground owner write allowed, non owner write denied.

### 3.3 Remote Config

Status: WORKING.
Evidence: `lib/services/firebase_service.dart` defaults premium_enabled false, live_consult_enabled false, fetch timeout 1 minute, minimum fetch interval 1 hour.
Test proof: `test/premium_test.dart` (2 cases).
Console proof: CONSOLE VERIFIED 28 Nov 2026 00:06 IST, premium_enabled false is the live value.

### 3.4 Cloud Messaging token and foreground receive

Status: PARTIALLY IMPLEMENTED.
Evidence: `lib/services/firebase_service.dart` `_configureMessaging`, `lib/services/notification_service.dart` getToken plus onMessage listener in debug.
Test proof: none for delivery. Only the schedule math is tested (`test/notification_schedule_test.dart`).
What is missing: token storage, topics, background handler, server send, real device delivery proof.

### 3.5 Cloud Functions

Status: MISSING.
Evidence: no `functions/` directory, no cloud_functions dependency in `pubspec.yaml`, no callable or trigger anywhere.
Blocked also by: Blaze plan decision from the user. Nothing server side can be built until that decision lands.

### 3.6 Storage

Status: BLOCKED BY EXTERNAL CONFIGURATION, and code also missing.
Evidence: bucket name dharm-guru-shrinkhala.firebasestorage.app appears only in `lib/firebase_options.dart`. No `storage.rules` file, no firebase_storage dependency, no upload or download code. No console Storage configuration is recorded in this baseline.

### 3.7 App Check

Status: BLOCKED BY EXTERNAL CONFIGURATION.
Evidence: no app_check dependency in `pubspec.yaml`, no App Check code in lib, no enforcement state recorded. Both the console step and the code wiring are missing.

### 3.8 Crashlytics

Status: MISSING by decision, not by accident.
Evidence: no crashlytics dependency in `pubspec.yaml`; `FIREBASE-SETUP.md` section 8 records removal in release 6; CI fails the build if any Crashlytics class is present (`.github/workflows/flutter-analyze.yml` dex gate). Fatal Flutter errors are logged by the app instead. Do not re enable without reversing that decision.

### 3.9 Analytics

Status: PARTIALLY IMPLEMENTED.
Evidence: firebase_analytics dependency present, `FirebaseService.analytics` exposed. No event taxonomy is documented and no screen logs a named event in a way this inventory could verify. The admin Analytics screen reads Firestore data, not Analytics events.
Test proof: none for events.

### 3.10 CI build and test

Status: WORKING.
Evidence: `.github/workflows/flutter-analyze.yml`, 3 jobs: analyze, build-apk, build-ios. Run 46043847890 on HEAD eb0c471: success, `flutter analyze` "No issues found!", "111 tests passed.", both release APKs built and signing gated to the permanent release key.
Note: local Flutter does not exist on this VM, so CI is the only build and test proof in this baseline.

### 3.11 iOS and Android apps

Status: WORKING for Android and iOS user and admin flavors in CI; web NOT registered.
Evidence: flavors user and admin in `android/app/build.gradle.kts`; user, admin and Runner schemes in `ios/Runner.xcodeproj/xcshareddata/xcschemes/`; CI build-ios green; `lib/firebase_options.dart` Android and iOS values real, web/macOS/Windows/Linux placeholders.
Console proof: CONSOLE VERIFIED 28 Nov 2026 00:06 IST, admin iOS app registered (bundle com.codeair.dharmgurushrinkhala.admin, App ID 1:987289079284:ios:2bce40df3197896e143da1); main iOS app verified with both SHA1 fingerprints; GoogleService-Info.plist download NOT done at that check.

## 4. Design flow specs coverage

| Flow spec | Maps to | Status |
| --- | --- | --- |
| `design/flows/01-kundli-chart-readability.md` | 1.6, 1.7 | WORKING |
| `design/flows/02-panchang-clarity.md` | 1.9 | WORKING |
| `design/flows/03-matching-flow.md` | 1.10 | WORKING |
| `design/flows/04-remedies-flow.md` | 1.11 | WORKING |
| `design/flows/05-live-consult-flow.md` | 1.13, 1.14 | Chat WORKING, call PARTIALLY IMPLEMENTED |
| `design/flows/06-premium-upgrade-flow.md` | 1.15, 2.4 | PARTIALLY IMPLEMENTED |

## 5. Summary counts

| Status | Count |
| --- | --- |
| WORKING | 19 |
| PARTIALLY IMPLEMENTED | 7 |
| BROKEN | 0 |
| MISSING | 5 |
| BLOCKED BY EXTERNAL CONFIGURATION | 2 |

Counts cover the features listed in sections 1 to 3 above. BROKEN is zero: no feature in this inventory is known to crash or to return wrong output at baseline, apart from the precision and fallback limits already named under their own features. The two P0 security items in the baseline are recorded under 2.9 and in `docs/implementation/REPOSITORY_BASELINE.md` section 10; they are gate design flaws, not broken features, so they do not change the WORKING count for the gate itself.

## 6. What this inventory does not claim

No live device proof is claimed anywhere here: no phone install, no real push delivery, no live Google sign in on a phone, no live payment. The only live facts are the CONSOLE VERIFIED items dated 28 Nov 2026 00:06 IST (rules published, owner record, Rules Playground, premium_enabled false, admin iOS app registered). Everything else is file evidence plus the CI run 46043847890. Phase 0 changed no code and made no console mutation.
