# Repository Baseline: Dharm Guru Shrinkhala, Phase 0

Date: 28 November 2026.
Purpose: this file records the exact state of the repo at the start of the master implementation, so later phases can prove what changed and what was already true.
Rule used while writing it: a fact is marked FILE EVIDENCE when a file in this repo proves it, and CONSOLE VERIFIED when it was verified in the Firebase console on 28 November 2026 at 00:06 IST by a live browser task and no file in this repo can prove it. Nothing here claims file proof for a console fact.

## 1. Baseline commands record

All commands below were run on this VM on 28 November 2026 during Phase 0.

| Command | Result |
| --- | --- |
| `git status` | On branch main, up to date with origin/main. Tree clean except untracked `pubspec.lock`. Nothing added, nothing staged. |
| `git branch --show-current` | main |
| `git rev-parse HEAD` | eb0c471d8f28335d3e03e1c934351f1eb8631ea3 |
| `git log -1` | eb0c471, 2026-11-27 17:41:40 UTC, "Release 10 proof pass: Library, Amavasya fix, admin proof tests" |
| `git log --oneline -5` | eb0c471 Release 10 proof pass; eaadffc Release 10 follow up: unknown birth time and notification chat auth; 27800e9 Release 10: every feature runs on real logic and real data; c4c7c6e Release 9: admin gate never hangs, real kundli and panchang; 67916e3 Fix sign in links |
| `gh run view 46043847890` | Completed, conclusion success, headSha eb0c471d8f28335d3e03e1c934351f1eb8631ea3, created 2026-11-27T17:41:48Z. Jobs: build-apk green in 7m5s, analyze green in 1m24s, build-ios green in 14m11s. |
| `gh run view 46043847890 --log` (grep) | `flutter analyze`: "No issues found! (ran in 9.9s)". `flutter test`: "111 tests passed." |
| `gh run list --limit 5` | Last 5 runs on main all success: 46043847890, 46038321553, 46037201744, 46025895923, 46014648557. |
| `git remote -v` | origin https://github.com/sunmughan/dharm-guru-shrinkhala.git (fetch and push). Repo is PUBLIC. |
| Local Flutter | NOT installed on this VM. No local `flutter` command was run, and no local Flutter version is recorded anywhere in this baseline, because none exists here. All build and test proof comes from GitHub Actions CI. |

Untracked file left alone per the Phase 0 brief: `pubspec.lock` (25,589 bytes) is untracked and was NOT deleted and NOT committed. Config files present in the working tree but NOT tracked in git: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`. `git ls-files` returns nothing for those three paths, so they live only on machines that ran the setup steps, plus CI secrets.

## 2. Project identity

| Item | Value | Evidence |
| --- | --- | --- |
| App name | Dharm Guru Shrinkhala | FILE EVIDENCE: `pubspec.yaml`, `lib/core/navigation/app_shell.dart` |
| Package | dharm_guru_shrinkhala, Android applicationId com.codeair.dharm_guru_shrinkhala, admin flavor suffix .admin | FILE EVIDENCE: `pubspec.yaml`, `android/app/build.gradle.kts` |
| iOS bundle | com.codeair.dharmgurushrinkhala (user), admin scheme exists | FILE EVIDENCE: `lib/firebase_options.dart`, `ios/Runner.xcodeproj/xcshareddata/xcschemes/` (Runner, user, admin schemes) |
| Version | 0.1.0+10 (versionCode 10) | FILE EVIDENCE: `pubspec.yaml` |
| SDK | Dart ^3.13.0, Flutter ">=3.47.0" | FILE EVIDENCE: `pubspec.yaml` |
| Architecture | Flutter app direct to Firebase, no backend, no server code in repo | FILE EVIDENCE: `lib/main.dart` comment, `README.md`, absence of any `functions/` directory |
| Design source | `design/DESIGN-SYSTEM.md` v1.0 dated 26 November 2026, tokens from the presentation artifact | FILE EVIDENCE: `design/DESIGN-SYSTEM.md` |
| Design docs | 22 screen specs in `design/screens/`, 6 flow specs in `design/flows/` | FILE EVIDENCE: file listing |

## 3. File tree and size

Total Dart in `lib/`: 12,608 lines across 27 files. Tests: 2,736 lines across 13 files (sum of test files listed below, widget_test alone 1,333 lines). Total repo Dart plus tests: 15,344 lines.

### 3.1 lib

| File | Lines | Role |
| --- | --- | --- |
| `lib/main.dart` | 23 | User app entry point, Firebase bootstrap, setup screen on init failure |
| `lib/main_admin.dart` | 33 | Admin app entry point, Firebase bootstrap plus admin seed on first launch |
| `lib/firebase_options.dart` | 85 | Firebase options. Android and iOS real values, web/macOS/Windows/Linux placeholders |
| `lib/core/admin_config.dart` | 7 | Default admin email and password constants (see section 10, P0) |
| `lib/core/build_info.dart` | 7 | BUILD_STAMP dart define, default "dev build" |
| `lib/core/navigation/app_shell.dart` | 345 | Root widget, splash, onboarding, auth gate, 5 tab shell, notification prompt |
| `lib/core/theme/design_tokens.dart` | (see note) | Colour, type, spacing tokens from DESIGN-SYSTEM.md |
| `lib/models/kundli.dart` | 54 | BirthDetails, PlanetDetail, planet abbreviations |
| `lib/models/panchang.dart` | 60 | Panchang, HoroscopeEntry, UserProfile models |
| `lib/models/remedies.dart` | 19 | Remedy model |
| `lib/services/astro.dart` | 953 | Real Vedic engine: planets, lagna, panchang, dasha |
| `lib/services/matching.dart` | 365 | Ashtakoot guna milan, 36 point total |
| `lib/services/remedies_engine.dart` | 123 | Weak planet detection and standard upay text |
| `lib/services/library_content.dart` | 162 | Festival days from panchang engine, dasha timeline, planet reference |
| `lib/services/auth_service.dart` | 369 | Email/password, phone, Google sign in, Google link flow |
| `lib/services/firebase_service.dart` | 118 | Firebase init, Remote Config, Messaging token, one time permission prompt |
| `lib/services/firestore_service.dart` | 193 | All Firestore collection access, admin gate checks |
| `lib/services/chat_service.dart` | 120 | Consult chat over Firestore |
| `lib/services/notification_service.dart` | 25 | FCM token fetch and foreground message listener |
| `lib/services/notification_schedule.dart` | 59 | Pure scheduling logic: next daily alert, admin send time, alert payload |
| `lib/services/premium_service.dart` | 16 | Premium gate reading Remote Config `premium_enabled` |
| `lib/services/user_profile.dart` | 180 | AppUserProfile model, incl unknown birth time flag |
| `lib/services/admin_seed_service.dart` | 72 | First launch seed of the default admin account |
| `lib/screens/screens.dart` | 3,898 | All user screens and widgets |
| `lib/screens/admin_screens.dart` | 3,850 | Admin app: shell, dashboard, all 8 admin sections, account |
| `lib/screens/auth_screen.dart` | 329 | Sign in, sign up, forgot password, Google sign in |
| `lib/screens/profile_form_screen.dart` | 431 | Full profile form |
| `lib/widgets/kundli_chart.dart` | 380 | North Indian square chart painter |
| `lib/widgets/planet_details.dart` | 244 | Planet details table |
| `lib/widgets/brand_mark.dart` | 88 | Sun mark and rays ring |

Note: `lib/core/theme/design_tokens.dart` line count was not captured separately in the Phase 0 listing; the file exists and is imported by the screens. Its tokens are the exact values from `design/DESIGN-SYSTEM.md` section 2.

### 3.2 Other top level areas

| Area | Contents |
| --- | --- |
| `test/` | 13 test files (section 8) |
| `firebase/` | Only `firebase/firestore.rules`. No `firestore.indexes.json`, no `storage.rules`, no `functions/` directory. `firebase.json` at repo root contains only `{"firestore": {"rules": "firebase/firestore.rules"}}`. |
| `.github/workflows/` | One workflow: `flutter-analyze.yml` with 3 jobs: analyze (analyze plus test), build-apk (user plus admin release APKs, keystore restore, signing fingerprint gate, package name gate, Firebase dex class gate), build-ios |
| `design/` | `DESIGN-SYSTEM.md`, `README.md`, `flows/` 01 to 06, `screens/` 01 to 22 |
| `android/` | Flavors user and admin, `google-services.json` present locally but untracked, release keystore restored in CI from secret, never committed |
| `ios/` | Runner plus user and admin schemes, `GoogleService-Info.plist` present locally but untracked |
| `web/` | `index.html`, `manifest.json`, icons. Firebase web options are placeholders (section 5) |
| `assets/brand/` | Logo PNG, SVG, foreground PNG, README |
| `FIREBASE-SETUP.md` | 11,936 bytes, console setup steps incl Remote Config params and Crashlytics removal note |
| `README.md` | STALE (see section 9, P1). It still describes Phase 1 sample data state and says no real kundli, no admin panel, no live consult. All three are false at release 10. |

## 4. User app functionality

Entry: `lib/main.dart` calls `FirebaseService.initialise()`, then `DharmGuruApp`. Flow: splash (2 seconds, build stamp shown) to onboarding (first launch only, stored in SharedPreferences key `onboarding_seen`) to auth gate (StreamBuilder on `AuthService.signedIn`) to the 5 tab shell. Signed out users see only the sign in screen; no kundli, matching, remedies or any other screen opens without a signed in user. That gate is stated in `lib/core/navigation/app_shell.dart` and covered by widget tests.

Tabs in fixed order: Home, Kundli, Panchang, Consult, Profile. Navigation is an IndexedStack with a BottomNavigationBar. There are NO named routes in the app; inner screens open with Navigator push from tab screens.

| Area | What it does at release 10 | Evidence |
| --- | --- | --- |
| Splash | Logo, wordmark, tagline, gold rays ring, build stamp, auto advance after 2 seconds | FILE EVIDENCE: `lib/screens/screens.dart` SplashScreen |
| Onboarding | Multi step intro, Skip and Begin both land on sign in | FILE EVIDENCE: `lib/screens/screens.dart` OnboardingScreen |
| Auth | Email/password sign up and sign in, forgot password email, Google sign in with ID token, phone sign in code present in AuthService, Google link flow when a Google sign in finds an existing email account (link with password once, then link) | FILE EVIDENCE: `lib/screens/auth_screen.dart`, `lib/services/auth_service.dart` |
| Home | Greeting, kundli card, daily horoscope card from published Firestore content, consult card | FILE EVIDENCE: `lib/screens/screens.dart` HomeScreen |
| Kundli input | Birth details form: name, date, time, place. Explicit "I do not know my birth time" choice. Place matched against a fixed city list of about 50 Indian cities; unknown place falls back to Jaipur coordinates and the result is marked approximate | FILE EVIDENCE: `lib/screens/screens.dart` KundliInputScreen, `lib/services/astro.dart` kIndianCities, `lib/services/user_profile.dart` birthTimeUnknown |
| Kundli chart | North Indian square chart, Lagna Chart and Moon Chart switcher (Moon chart counts bhavas from the Moon sign), summary chips Lagna/Rashi/Nakshatra, planet summary list, tap through to planet details | FILE EVIDENCE: `lib/screens/screens.dart` KundliChartScreen, `_ChartSwitcher`, `lib/widgets/kundli_chart.dart` |
| Planet details | Degree, rashi, bhava, swami, note per planet, from the real engine | FILE EVIDENCE: `lib/widgets/planet_details.dart` |
| Daily horoscope | Reads the published horoscope document for the user rashi and date from Firestore. Draft content is never shown: only published content renders, and an explicit "Sample data only. No real prediction." state exists in tests | FILE EVIDENCE: `lib/screens/screens.dart` HoroscopeScreen, `test/widget_test.dart` lines 552, 620, 653 |
| Panchang | Tithi, yoga, karana, nakshatra, sunrise, sunset, abhijit muhurat, rahu kaal, computed by the engine for the chosen date and place, plus published panchang documents from Firestore | FILE EVIDENCE: `lib/screens/screens.dart` PanchangScreen, `lib/services/astro.dart` PanchangCalculator |
| Matching | Two person form, Ashtakoot guna milan out of 36 with per guna rows and verdict, Mangal dosha flags for both persons. Full report is premium gated: when premium is off the screen says the full report is premium and premium is not available yet | FILE EVIDENCE: `lib/screens/screens.dart` MatchingScreen, `lib/services/matching.dart` |
| Remedies | Weak planets from the real chart (debilitated or in bhava 6, 8 or 12), current Vimshottari Mahadasha lord card, standard traditional upay text per planet | FILE EVIDENCE: `lib/screens/screens.dart` RemediesScreen, `lib/services/remedies_engine.dart` |
| Library | Festival days computed by scanning the panchang engine over the next 30 days, dasha timeline from the real chart, planet reference paired with the user own computed positions | FILE EVIDENCE: `lib/screens/screens.dart` LibraryScreen, `lib/services/library_content.dart` |
| Consult chat | Real Firestore backed chat room, one chat per user (`user_<uid>`), messages stream live oldest first, send stores sender id, sender role, server timestamp plus client sentAt millis. Admin app reads and replies. No astrologer identity exists yet, so the admin answers until one is added | FILE EVIDENCE: `lib/screens/screens.dart` ConsultScreen, ChatScreen, `lib/services/chat_service.dart` |
| Consult call | NOT in app voice or video. The call button dials the phone number the admin saved for that astrologer through url_launcher, and says plainly when none is saved | FILE EVIDENCE: `lib/screens/screens.dart` ConsultScreen `_callAstrologer`, callAvailable flag |
| Profile | Full profile form (name, gender, date of birth, time of birth, place, marital status, occupation, phone, language English/Hindi, daily horoscope alert time). Profile counts as complete with name, date of birth and birth place; time of birth is optional | FILE EVIDENCE: `lib/screens/profile_form_screen.dart`, `lib/services/user_profile.dart` |
| Notifications (user) | One time permission dialog on the main screen after onboarding and sign in, with the reason shown first, never at app open. Daily alert time default 06:00 AM from the design profile screen. The alert time and payload are computed locally; actual delivery on a real device is NOT proven (see section 9) | FILE EVIDENCE: `lib/core/navigation/app_shell.dart`, `lib/services/notification_schedule.dart`, `lib/services/firebase_service.dart` |
| Premium | Gate only. `PremiumService` reads Remote Config `premium_enabled`, default false. No price, no trial, no currency anywhere, no payment provider, no purchase code | FILE EVIDENCE: `lib/services/premium_service.dart` |

## 5. Admin app functionality

Entry: `lib/main_admin.dart` calls `FirebaseService.initialise()` then `AdminSeedService.ensureDefaultAdmin()`, then `DharmGuruAdminApp`. Same Firebase project and same auth system as the user app. Two flavors: user APK package com.codeair.dharm_guru_shrinkhala, admin APK package com.codeair.dharm_guru_shrinkhala.admin (CI verifies the package names differ with aapt).

Admin gate: the admin app checks the `admins/{uid}` document for role owner, with a 20 second timeout and explicit error screens. The gate has two fallback paths that are security items, recorded in section 10: (a) the seeded email passes the gate even when its admins document is missing (`isAdminUser` in `lib/services/firestore_service.dart`); (b) `ensureAdminDoc` writes role owner for ANY account that signs in through the admin app with Google.

Admin shell tabs (9): Dashboard, Astrologers, Daily Content, Chats, Subscriptions, Analytics, Notifications, Moderation, Account. Source: `_labels` in `lib/screens/admin_screens.dart` AdminShell.

| Area | What it does at release 10 | Evidence |
| --- | --- | --- |
| Dashboard | Counts from Firestore collections, attention rows, feature flags incl premium_enabled read | FILE EVIDENCE: `lib/screens/admin_screens.dart` AdminDashboardScreen |
| Astrologers | Create, read, update, delete astrologer records in Firestore: name, languages, chatAvailable, callAvailable, phone. No real astrologer identity exists yet; records are whatever the admin enters | FILE EVIDENCE: `lib/screens/admin_screens.dart` AstrologersScreen |
| Daily Content | Publish daily horoscope documents (draft vs publish), panchang form for published panchang documents | FILE EVIDENCE: `lib/screens/admin_screens.dart` DailyContentScreen, `_HoroscopeGrid`, `_PanchangForm` |
| Chats | Admin reads and replies in every user chat | FILE EVIDENCE: `lib/screens/admin_screens.dart` AdminChatsScreen |
| Subscriptions | Reads plans and payments collections, shows subscription state. No payment provider behind it, so no real revenue flows through it | FILE EVIDENCE: `lib/screens/admin_screens.dart` SubscriptionsScreen |
| Analytics | Range stats and charts drawn from Firestore data with custom painters. Revenue figures depend on payments data that does not exist yet | FILE EVIDENCE: `lib/screens/admin_screens.dart` AnalyticsScreen |
| Notifications | Admin composes a notification and picks "Send now" or a send time in HH:MM AM/PM form. The send time and the payload are computed locally (`NotificationSchedule.scheduledSendTime`, `horoscopeAlertPayload`). There is NO server send path: no Cloud Function, no FCM admin send call in the repo | FILE EVIDENCE: `lib/screens/admin_screens.dart` NotificationsScreenAdmin, `lib/services/notification_schedule.dart` |
| Moderation | Reads and writes the moderation collection, owner only | FILE EVIDENCE: `lib/screens/admin_screens.dart` ModerationScreen |
| Account | Admin account screen, incl change of the default password after first sign in (per the comment in `lib/core/admin_config.dart`) | FILE EVIDENCE: `lib/screens/admin_screens.dart` AdminAccountScreen |

## 6. Firebase services state

Project: dharm-guru-shrinkhala, project number 987289079284, Firestore region asia-south1. Sources: FILE EVIDENCE `lib/firebase_options.dart` (Android appId 1:987289079284:android:913871be9f5be889143da1, iOS appId 1:987289079284:ios:7cea32f975fc66fc143da1, storage bucket dharm-guru-shrinkhala.firebasestorage.app); CONSOLE VERIFIED for region asia-south1 and the published rules and owner record (console facts, no file proves them).

| Service | State at Phase 0 | Evidence |
| --- | --- | --- |
| Authentication | Configured in code: email/password, Google, phone. Google sign in wired to the web client id. Admin seed creates the default admin account on first admin app launch | FILE EVIDENCE: `lib/services/auth_service.dart`, `lib/services/admin_seed_service.dart` |
| Firestore | Rules file `firebase/firestore.rules` in repo. CONSOLE VERIFIED: rules published from that exact file on 28 Nov 2026 00:06 IST, live version matches repo incl isOwner, admins, chats/messages rules. Before that, live rules covered only users/horoscopes/astrologers/panchang with writes allow false | FILE EVIDENCE for the file, CONSOLE VERIFIED for the publish |
| Firestore owner record | CONSOLE VERIFIED: admins collection holds a document for admin@gmail.com, uid XUdDmGwDGXMsxG883un42zEe7X72, field role owner, visible live | CONSOLE VERIFIED only. No file in the repo holds this uid or proves the record. |
| Firestore rules playground | CONSOLE VERIFIED: owner write allowed, non owner write denied | CONSOLE VERIFIED only |
| Firestore indexes | MISSING. No `firestore.indexes.json` in the repo and no index definition anywhere. Queries today are single collection streams that need no composite index; any later filtered or ordered query will need one | FILE EVIDENCE: file listing, `firebase.json` |
| Remote Config | Configured in code with defaults premium_enabled false, live_consult_enabled false, fetch timeout 1 minute, minimum fetch interval 1 hour. CONSOLE VERIFIED: premium_enabled false is the live value | FILE EVIDENCE: `lib/services/firebase_service.dart`; CONSOLE VERIFIED for the live value |
| Cloud Messaging (FCM) | Partial. Code fetches a token at startup (`FirebaseService._configureMessaging`, `NotificationService.initialise`) and listens for foreground messages in debug. The token is NEVER stored against the user document (stated as a later phase task in the code comment). No topic subscribe, no background handler, no server send. Real device delivery is NOT proven | FILE EVIDENCE: `lib/services/firebase_service.dart`, `lib/services/notification_service.dart` |
| Storage | NOT configured as a feature. The bucket name appears only inside `lib/firebase_options.dart` (storageBucket dharm-guru-shrinkhala.firebasestorage.app). No `storage.rules` file, no firebase_storage dependency in `pubspec.yaml`, no upload or download code anywhere. Any use of Storage is BLOCKED BY EXTERNAL CONFIGURATION plus missing code | FILE EVIDENCE: `pubspec.yaml`, file listing, grep for storage across lib |
| Cloud Functions | ABSENT. No `functions/` directory, no cloud_functions dependency, no callable or trigger in the repo. Any server side work (push send, scheduled horoscope send, payment webhook, role grant) is MISSING and also needs a Blaze plan decision from the user | FILE EVIDENCE: file listing, `pubspec.yaml` |
| App Check | NOT configured. No app_check dependency, no App Check code, no enforcement state recorded. Status: BLOCKED BY EXTERNAL CONFIGURATION (console enforcement plus code wiring both missing) | FILE EVIDENCE: `pubspec.yaml`, grep across lib |
| Crashlytics | REMOVED by decision in release 6 (0.1.0+4). No crashlytics dependency, and the CI dex gate FAILS the build if any Crashlytics class is present. Fatal Flutter errors are logged by the app instead. Do not re-enable without reversing that decision | FILE EVIDENCE: `pubspec.yaml`, `.github/workflows/flutter-analyze.yml`, `FIREBASE-SETUP.md` section 8 |
| Analytics | Firebase Analytics dependency present and `FirebaseService.analytics` exposed. No event taxonomy is documented; analytics screens read Firestore data, not Analytics events | FILE EVIDENCE: `pubspec.yaml`, `lib/services/firebase_service.dart` |
| iOS apps | CONSOLE VERIFIED: main iOS app verified with both SHA1 fingerprints (release plus debug); admin iOS app registered with bundle com.codeair.dharmgurushrinkhala.admin, App ID 1:987289079284:ios:2bce40df3197896e143da1. GoogleService-Info.plist download NOT done at the time of that check | CONSOLE VERIFIED only |
| Android apps | FILE EVIDENCE: Android appId in `lib/firebase_options.dart`. Release APK signing is gated in CI to the permanent release key; the fingerprint printed by CI is the value the console must hold | FILE EVIDENCE: `lib/firebase_options.dart`, `.github/workflows/flutter-analyze.yml` |
| Web app | NOT registered. `lib/firebase_options.dart` web options are placeholders (apiKey, appId, messagingSenderId, projectId, authDomain, storageBucket all PLACEHOLDER). Same for macOS, Windows, Linux | FILE EVIDENCE: `lib/firebase_options.dart` |

## 7. Data models and Firestore collections

### 7.1 Dart models

| Model | File | Fields of note |
| --- | --- | --- |
| BirthDetails | `lib/models/kundli.dart` | name, dateOfBirth, timeOfBirth, placeOfBirth, rashi, nakshatra, tithiAtBirth |
| PlanetDetail | `lib/models/kundli.dart` | name, rashi, bhava, degree, swami, note |
| Panchang | `lib/models/panchang.dart` | Panchang day values (tithi, yoga, karana, nakshatra, sunrise, sunset, muhurat, rahu kaal) |
| HoroscopeEntry | `lib/models/panchang.dart` | Published horoscope document shape |
| UserProfile | `lib/models/panchang.dart` | Profile document shape |
| Remedy | `lib/models/remedies.dart` | Remedy text model |
| AppUserProfile | `lib/services/user_profile.dart` | name, gender, dateOfBirth, timeOfBirth, birthTimeUnknown, birthCity/State/Country, maritalStatus, occupation, phoneNumber, language (English/Hindi), horoscopeAlertTime |
| KundliResult | `lib/services/astro.dart` | lagna, moonRashi, moonNakshatra, tithiAtBirth, 9 planets, placeApproximate, timeApproximate |
| DashaInfo | `lib/services/astro.dart` | Vimshottari dasha data |
| MatchingResult / GunaScore | `lib/services/matching.dart` | total out of 36, per guna rows, verdict, mangal flags |
| ChatMessage | `lib/services/chat_service.dart` | id, senderId, senderRole (user/admin), text, createdAt, sentAt |
| FestivalDay / PlanetReference | `lib/services/library_content.dart` | date, tithi, observance; planet reference text |

### 7.2 Firestore collections (all named in `lib/services/firestore_service.dart`)

users, horoscopes, astrologers, panchang, admins, plans, payments, notifications, chats (with subcollection messages), moderation.

Rules summary (`firebase/firestore.rules`): users read/write only their own document; admins read/write only their own document; horoscopes, astrologers, panchang read by any signed in user, write by owner only; plans read by signed in users, write owner only; payments read/write owner only; notifications read by signed in users, write owner only; moderation read/write owner only; chats read/update by participants or owner, create by a participant, messages create only as self and only as a participant. The `isOwner()` helper reads `admins/{uid}` role owner on every owner write check.

## 8. Astrology algorithms

FILE EVIDENCE: `lib/services/astro.dart` (953 lines), `test/astro_test.dart` (192 lines).

* Method: tropical longitudes from standard low precision Keplerian element algorithms (Paul Schlyter method: Sun, Moon and planets, about 0.01 degrees for the Sun, about 0.3 degrees for the Moon, arcminutes to a few tenths of a degree for the planets), converted to sidereal longitudes with the Lahiri ayanamsa. Lagna, rashi, nakshatra, tithi, yoga, karana, sunrise, sunset, abhijit muhurat and rahu kaal are derived from those longitudes.
* Validation: checked against JPL Horizons DE441 vectors for the sample birth 14 March 1998 06:25 IST Jaipur. Expected sidereal longitudes are written in `test/astro_test.dart`: Sun 329.44, Moon 158.63, Mars 343.44, Mercury 346.04, Jupiter 315.21, Venus 283.78, Saturn 355.78, Rahu 136.08, Ketu 316.08. Tolerances in the test are generous: Sun within 0.5 degrees, Moon within 1 degree, planets within 2 degrees. The task brief records every planet within 0.21 degrees of the reference; the test file itself proves the looser tolerance above, and the tighter figure is a brief claim, not a test assertion. Sample birth result: Lagna Kumbha, Moon rashi Kanya, Moon nakshatra Uttara Phalguni, tithi at birth Krishna Pratipada. The old hardcoded planet table in the app was fabricated (Sun 2 degrees off, Moon 10.5 degrees off, Jupiter 7 degrees off) and is not used anywhere.
* Tithi fix in release 10: the 30th tithi is now Krishna Amavasya; before the fix it was wrongly Krishna Purnima. Covered by tests.
* Panchang: `PanchangCalculator.forDate` computes the day values for any date and place.
* Dasha: Vimshottari Mahadasha from the Moon nakshatra, used by the remedies screen and the library dasha timeline.
* Matching: Ashtakoot guna milan, total out of 36: Varna 1, Vashya 2, Tara 3, Yoni 4, Graha Maitri 5, Gana 6, Bhakoot 7, Nadi 8. Every guna reads the Moon rashi and Moon nakshatra the engine calculated for each person. No score is fixed.
* Remedies: a planet counts as weak when debilitated or in bhava 6, 8 or 12. The current Mahadasha lord gets its own card. Remedy text is the standard traditional upay for that planet.
* Known shortcuts, written in the code itself with `shortcut:` comments: (a) planetary longitudes use mean elements without the small perturbation terms, so Jupiter and Saturn can sit up to about half a degree from a full ephemeris; that never moves a planet to another rashi except within half a degree of a cusp; upgrade to full VSOP87 only if sub degree precision is ever needed. (b) Places outside the city list fall back to Jaipur coordinates and the result is marked approximate; add the city when a user reports it. (c) Yoni scores 4 for the same animal and 2 for a different animal; the friendly and enemy animal refinement is deferred until the owner confirms the table.
* Divisional charts: NONE. No Navamsa (D9), no other varga chart, no code and no design decision recorded for the 16 divisional charts the master order names. Status MISSING, to be specified in a later phase.

## 9. Tests and build status

### 9.1 Test inventory

111 test cases counted by grep for `test(` and `testWidgets(` across `test/*.dart`, and confirmed by the CI log line "111 tests passed." Count per file:

| File | Cases | What it proves |
| --- | --- | --- |
| `test/admin_gate_test.dart` | 4 | Admin gate behaviour |
| `test/admin_proof_test.dart` | 13 | Admin features end to end on fake Firestore |
| `test/astro_test.dart` | 10 | Engine vs JPL DE441 reference, panchang, place fallback, date parsing |
| `test/chat_test.dart` | 2 | Chat message model and service |
| `test/firestore_flow_test.dart` | 3 | Firestore flows on fake Firestore |
| `test/google_signin_error_test.dart` | 2 | Google sign in error paths |
| `test/library_test.dart` | 7 | Festival days, dasha timeline, planet reference |
| `test/matching_test.dart` | 4 | Guna milan totals and verdicts |
| `test/notification_schedule_test.dart` | 6 | Next alert, admin send time, alert payload |
| `test/premium_test.dart` | 2 | Premium gate flag |
| `test/proof_test.dart` | 10 | Every user feature runs on real logic and real data |
| `test/remedies_test.dart` | 4 | Weak planet detection and remedy selection |
| `test/widget_test.dart` | 44 | Full widget pump tests incl auth gate, onboarding, sample data labelling |
| Total | 111 | |

Test stack: `flutter_test` plus `fake_cloud_firestore` ^3.1.0 for Firestore backed tests. No integration test directory, no device test, no golden test. All 111 tests run in CI on ubuntu-latest with the stable Flutter channel.

### 9.2 Build status

* CI run 46043847890 on HEAD eb0c471: success. analyze job: `flutter analyze` "No issues found!", `flutter test` 111 passed. build-apk job: user and admin release APKs built with flavor user/admin, release keystore restored from CI secret, signing fingerprint gate passed (both APKs carry the permanent release key, never a debug key), package names verified distinct, Firebase dex class gate passed (all required Firebase classes present, no Crashlytics class present). build-ios job: green in 14m11s.
* Release 10 APKs (from the parent record, not re verified in Phase 0): user APK 56,607,226 bytes, admin APK 55,508,558 bytes, both signed with the permanent release key SHA1 D9:1A:02:84:0D:FE:F5:82:D3:3E:3E:9C:21:5A:77:D2:73:D7:89:A3. Phase 0 did NOT rebuild and did NOT re download the APKs; the CI run above is the build proof for this baseline.
* Local build: impossible on this VM (no Flutter installed) and not attempted. Flutter must NOT be installed here per the Phase 0 brief.

## 10. Known defects and security issues

Severity follows the usual order: P0 blocks safe use, P1 blocks a feature, P2 degrades correctness, P3 is polish or process.

### P0

1. Default admin credentials live in source. `lib/core/admin_config.dart` holds the default admin email and the default password in plain constants, and `lib/services/admin_seed_service.dart` creates that account through Firebase Auth on the first launch of the admin app. CONFLICT NOTE, do not resolve in Phase 0: this seed was the user own Round 4 order. It is removed ONLY after secure owner provisioning is proven working, and the decision goes to the parent, not to a Phase 0 agent. Phase 0 made NO code change and did NOT remove the seed.
2. Admin gate fallback by email. `isAdminUser` in `lib/services/firestore_service.dart` returns true for the seeded email even when its `admins` document is missing, so the email alone, plus the known password, opens the admin app when the rules were not yet published. Combined with item 1, anyone who reads this public repo knows both the email and the password.
3. Any Google sign in in the admin app becomes owner. `ensureAdminDoc` in `lib/services/firestore_service.dart` writes role owner for ANY uid that signs in through the admin app with Google, and the rules allow a signed in user to write their own `admins` document. The comment in the code says the owner ordered this. It means the admin gate is not a closed list: any Google account that reaches the admin sign in screen can grant itself owner.

### P1

4. README is stale and contradicts the shipped app. `README.md` still says Phase 1 foundation, sample data only, no real kundli calculation, no real panchang, no admin panel, no live consult. At release 10 all of those exist. It also still lists the old fabricated sample chart values (Lagna Meena, Rashi Kanya, Nakshatra Hasta, Krishna Dwitiya) which the engine disproved (real result: Lagna Kumbha, Moon nakshatra Uttara Phalguni, Krishna Pratipada). The README also still says "Private repo" while the repo is PUBLIC.
5. FCM token is fetched and dropped. `FirebaseService._configureMessaging` and `NotificationService.initialise` call `getToken()` and never store it. No user document carries a token, no topic exists, so no push can be addressed to a user. Admin push has a compose screen and a computed payload but no send call.
6. Web, macOS, Windows and Linux Firebase options are placeholders. The web app is not registered, so `flutter run -d chrome` against this repo cannot initialise Firebase with real values.
7. No Firestore indexes file. No composite index is defined; the first filtered or ordered query in a later phase will fail at runtime until an index is created in the console.

### P2

8. City list is fixed at about 50 Indian cities. Any other place silently uses Jaipur coordinates. The result is marked approximate, which is honest, but the user gets a wrong place chart unless they pick a listed city.
9. Engine precision shortcut: Jupiter and Saturn can sit up to about half a degree from a full ephemeris (see section 8). A planet within half a degree of a rashi cusp can land in the wrong rashi.
10. Yoni guna refinement is deferred (same animal 4, different animal 2; friendly and enemy animal table not applied).
11. No Storage rules and no Storage code, so any later image or file feature (astrologer photo, user avatar) has no backend at all.

### P3

12. No App Check, no Crashlytics (by decision), no performance monitoring, no event taxonomy for Analytics.
13. `pubspec.lock` is untracked, so a fresh clone resolves dependencies at whatever versions the solver picks that day instead of the locked set the release 10 CI run used.
14. Dark mode follows the system setting only; there is no in app theme switch (design section 16 open question 2).

## 11. Missing modules

| Module | Status | Note |
| --- | --- | --- |
| Cloud Functions (any) | MISSING | No functions directory, no Blaze plan decision. Needed for push send, scheduled sends, payment webhooks, secure role grants |
| Payment provider | MISSING | No Razorpay, Stripe, or any other provider. No purchase code, no webhook, no price |
| Divisional charts (16 varga charts) | MISSING | No code, no design, no decision recorded |
| Hindi copy | MISSING | All copy in the repo and in design is English. Language field offers English/Hindi in the profile, but no Hindi strings exist |
| In app voice/video consult | MISSING | Call is a phone dial only |
| Storage (rules plus code) | MISSING | Bucket name only, in firebase_options |
| App Check | MISSING | Code plus console enforcement both absent |
| Firestore indexes file | MISSING | No indexes defined |
| iOS GoogleService-Info.plist download | Not done at console check time | CONSOLE VERIFIED note from 28 Nov 00:06 IST; the file exists in the local working tree now, untracked |
| Integration / device tests | MISSING | Only unit and widget tests exist; real device delivery (notifications, Google sign in on phone) is unproven in this baseline |

## 12. Exact implementation decisions recorded at baseline

1. Flutter app direct to Firebase, no backend server. Every feature reads and writes Firestore directly under the rules in `firebase/firestore.rules`.
2. Two apps from one codebase: user flavor and admin flavor, separate package names, separate entry points, same Firebase project, same auth system.
3. All verification runs on GitHub Actions, never locally. The workflow is the only build and test proof.
4. Remote Config defaults premium_enabled false and live_consult_enabled false. Premium stays off until the owner turns the flag on and pricing is decided.
5. No horoscope prediction text is written by design or by code. All prediction copy comes from published admin content. Draft content is never shown to users.
6. No dummy or sample data is filled in anywhere in the app at release 10. The old Phase 1 sample chart values are gone from the engine; the only remaining sample text is the explicit "Sample data only. No real prediction." state and the stale README copy (P1 item 4).
7. The notification permission dialog fires once, on the main screen after onboarding and sign in, with the reason shown first, never at app open.
8. Crashlytics stays removed. The CI dex gate fails the build if any Crashlytics class appears.
9. The default admin seed stays in place through Phase 0. Removal needs secure owner provisioning proven working first, and the decision goes to the parent.
10. Design tokens are taken exactly from `design/DESIGN-SYSTEM.md`. No hyphen and no em dash in any visible copy, per design section 3.3.
11. Timezone handling: birth times are local times at the place of birth; the engine converts with the place longitude. Unknown birth time is an explicit user choice, not a silent default.

## 13. Known blockers for later phases

Recorded here, not resolved in Phase 0. Each one needs a user decision or an external console step.

1. Astrologer identity: undecided. No astrologer names, photos or profiles exist. Design section 16 question 4. The admin answers consult chats until one is added.
2. Pricing: undecided. No price, no trial length, no currency. Design section 16 question 1. Blocks premium, subscriptions and payments.
3. Hindi copy: undecided, and no supplier named. Design section 16 question 3.
4. Moon Chart variant: the switcher is built and working, but design section 16 question 5 asks to confirm whether Moon Chart ships in version 1 or a later phase.
5. Notification timing: default 06:00 AM comes from the presentation profile screen. Design section 16 question 6 asks to confirm the default time and whether the user can change it.
6. Payment provider: none chosen, none integrated. Blocks all revenue features.
7. Cloud Functions: absent, and the Blaze plan is a user decision. Blocks push send, scheduled sends and any server side work.
8. In app theme switch: open question, design section 16 question 2. Dark mode follows the system setting today.
9. Secure owner provisioning: the replacement for the default admin seed. Blocked until a provisioning flow is designed, built and proven, and the parent decides. Until then the seed stays.
10. Real device proof: install the release 10 APKs, sign in to the admin app, tap publish live, and prove a push arrives on a real phone. Owed by the user on his phone; no agent in this baseline can do it from this VM.

## 14. What Phase 0 did and did not do

Did: inspected the full repo, verified the baseline commands in section 1, verified the CI run and the 111 test count from the CI log, read the design system section 16 open questions, and wrote this file plus `docs/implementation/FEATURE_INVENTORY.md`. No code file was changed. No Firebase console mutation was made. No destructive test was run. No real user data was touched. No token, secret or password is written in this file: the default admin password is named as a security item by file reference only, and its value is NOT repeated here.

Skipped: local Flutter run, local test run, APK rebuild, device verification, README correction, seed removal. Each of those is either impossible on this VM, forbidden by the Phase 0 brief, or owned by a later phase or by the parent decision.
