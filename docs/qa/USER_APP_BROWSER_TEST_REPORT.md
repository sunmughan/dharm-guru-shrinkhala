# Dharm Guru Shrinkhala User App Browser Test Report

## PHASE

Phase 16 user app browser QA. Scope is the user app only, file `lib/main.dart`, baseline release 10. Admin app is out of scope for this report.

## STATUS

BLOCKED. Browser testing could not run against the real user app. Two P0 gaps stop every app flow before it starts. No test in this report is marked pass. Nothing here claims the app works in a browser. The two browser checks that did run, console and network on the served web directory, both failed with real evidence.

## IMPLEMENTED

1. Own clone made at `~/workspace/dharm-guru-team/phase16-qa-user`, own branch `phase16-qa-user`, HEAD `eb0c471d8f28335d3e03e1c934351f1eb8631ea3`, verified same as release 10 baseline. Shared local clone was not edited.
2. CI run `46043847890` checked through `gh` CLI. All 3 jobs green. Artifact list pulled. Only 2 artifacts exist, both APKs. No web build artifact exists.
3. CI workflow read end to end. Jobs are analyze, build apk, build ios only. No web build job exists anywhere in the workflow.
4. Web Firebase config read in `lib/firebase_options.dart`. Web values are placeholders. File header says no web app is registered yet.
5. App structure read in code. Five bottom tabs Home, Kundli, Panchang, Consult, Profile. Auth gate in `lib/core/navigation/app_shell.dart` shows only the sign in screen when signed out. Firestore rules read in `firebase/firestore.rules`. Auth service, premium service, notification service, astro engine, matching engine and remedies engine read for preconditions.
6. Playwright headless Chromium harness run against a local server. Control page loaded clean, proving the harness works. The repo `web` directory served as is returned a blank page at 1280px and at 390px, with `flutter_bootstrap.js` 404 and console error. Screenshots and JSON logs saved under `docs/qa/screenshots` and `docs/qa/browser-logs`.
7. No dummy data and no sample data added anywhere. No live production data touched. No destructive test run. No QA account created. No credential of any kind written in chat or in files. No live deploy done.

## FILES CHANGED

1. `docs/qa/USER_APP_BROWSER_TEST_REPORT.md` (this file, new)
2. `docs/qa/screenshots/A-control-1280.png` (new)
3. `docs/qa/screenshots/B-web-template-1280.png` (new)
4. `docs/qa/screenshots/B-web-template-390.png` (new)
5. `docs/qa/browser-logs/A-control-1280.json` (new)
6. `docs/qa/browser-logs/B-web-template-1280.json` (new)
7. `docs/qa/browser-logs/B-web-template-390.json` (new)
8. `docs/qa/browser-logs/summary.json` (new)
9. `docs/qa/browser-logs/prereq-checks.txt` (new)

No app code changed. No config changed. No file outside `docs/qa` changed in this branch.

## FIREBASE CHANGES

None. Zero changes to the Firebase project `dharm-guru-shrinkhala`. No rules change, no console change, no data write, no data read of live collections, no Storage change, no Remote Config change, no user record created or touched.

## TESTS EXECUTED

Exact commands run in this task, in order.

1. `git clone https://github.com/sunmughan/dharm-guru-shrinkhala phase16-qa-user`
2. `git checkout -b phase16-qa-user`
3. `git rev-parse HEAD` result `eb0c471d8f28335d3e03e1c934351f1eb8631ea3`
4. `gh run view 46043847890 --repo sunmughan/dharm-guru-shrinkhala`
5. `gh api repos/sunmughan/dharm-guru-shrinkhala/actions/runs/46043847890/artifacts`
6. `grep` for `flutter build web` in `.github/workflows/flutter-analyze.yml`, no match
7. `ls build/web` in the clone, no such file or directory
8. `python3 -m http.server 8900` in `/tmp/phase16-qa` for the control page
9. `python3 -m http.server 8901` in the repo `web` directory for the app template
10. `curl` probes on `http://127.0.0.1:8901/` and on `main.dart.js`, `flutter.js`, `flutter_bootstrap.js`
11. `node run.js` in `/tmp/phase16-qa`, Playwright headless Chromium, executable path `/home/hatch/.cache/ms-playwright/chromium-1248/chrome-linux64/chrome`, viewports 1280x800 and 390x844
12. Code reads with `grep` for pdf, numerology, D9, D10, muhurat, Storage calls, premium gate and notification stream

Test IDs covered by these commands: UG01 to UG30, all listed in TEST RESULTS below. No test ID was executed inside the real app, because the real app never rendered in the browser.

## TEST RESULTS

Summary counts. Passed 0. Failed 2. Blocked 23. Not Tested 5. Total 30.

| Test ID | Module | Feature | Result | Defect | Evidence |
| UG01 | Startup | App startup and Firebase init | Blocked | DF01 DF02 | browser-logs/prereq-checks.txt |
| UG02 | Navigation | Bottom tabs Home Kundli Panchang Consult Profile | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG03 | Auth | Registration with email and password | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG04 | Auth | Login and reload session persist | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG05 | Auth | Password reset email | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG06 | Profile | Birth profile save and retrieve | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG07 | Kundli | Location search and select | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG08 | Kundli | Kundli calculate and planetary positions | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG09 | Kundli | D1 chart Lagna and Moon | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG10 | Kundli | D9 chart | Not Tested | DF04 | code grep, no D9 string in lib |
| UG11 | Kundli | D10 chart | Not Tested | DF04 | code grep, no D10 string in lib |
| UG12 | Kundli | Dasha timeline | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG13 | Panchang | Panchang date and location select | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG14 | Panchang | Muhurat date range | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG15 | Horoscope | Rule based daily horoscope result | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG16 | Matching | Matching with two real QA birth profiles | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG17 | Numerology | Numerology from actual input | Not Tested | DF05 | code grep, zero matches in lib and test |
| UG18 | Remedies | Rule based remedy recommendations | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG19 | PDF | PDF generate open inspect | Not Tested | DF06 | code grep, zero pdf matches in lib pubspec test |
| UG20 | Subscription | Subscription entitlement state | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG21 | Notifications | Notification delivery and history | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG22 | Consult | Consultation booking and chat | Blocked | DF01 | browser-logs/prereq-checks.txt |
| UG23 | Profile | Profile edit save reload | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG24 | Auth | Logout session end | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG25 | Authorization | Other user private record attempt | Blocked | DF01 DF03 | browser-logs/prereq-checks.txt |
| UG26 | Browser | Console errors on app load | Fail | DF01 | B-web-template-1280.json, B-web-template-1280.png |
| UG27 | Browser | Network requests on app load | Fail | DF01 | B-web-template-1280.json, B-web-template-390.json |
| UG28 | Browser | JavaScript exceptions on app load | Blocked | DF01 | B-web-template-1280.json |
| UG29 | Browser | Responsive behavior 390px and 1280px | Blocked | DF01 | B-web-template-390.png, B-web-template-1280.png |
| UG30 | Storage | Storage upload and download | Not Tested | DF07 | code grep, no Storage calls in lib |

## TEST DETAILS

### UG01 Startup

1. Test ID: UG01
2. Module: Startup
3. Feature: App startup and Firebase initialization with the correct Firebase project
4. Preconditions: Web build served on a local server, web Firebase config present
5. Test input: Load app root URL in headless Chromium at 1280x800
6. Action: Open `http://127.0.0.1:8901/`, wait 4 seconds, read body text, console and network
7. Expected result: Splash renders, Firebase initializes against project `dharm-guru-shrinkhala`, then onboarding or sign in screen appears
8. Actual result: Page title `dharm_guru_shrinkhala`, body text empty, no splash, no Firebase call at all. Only request outcomes were index 200, `flutter_bootstrap.js` 404, favicon 200
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/B-web-template-1280.json`, `docs/qa/screenshots/B-web-template-1280.png`
11. Firebase verification: Not possible in browser. Code read shows web options are placeholders in `lib/firebase_options.dart`, so even a compiled web build would fail Firebase init and show the Firebase setup screen from `lib/core/navigation/app_shell.dart`
12. Defect ID: DF01, DF02
13. Retest result: Retest pending after DF01 and DF02 fix

### UG02 Navigation

1. Test ID: UG02
2. Module: Navigation
3. Feature: Bottom tabs Home, Kundli, Panchang, Consult, Profile, plus inner screens
4. Preconditions: Signed in session, app shell rendered
5. Test input: Tap each tab in turn
6. Action: Open each tab, confirm screen load and tab state
7. Expected result: Each tab loads its screen, tab highlight follows the tap
8. Actual result: No tab rendered. App never reached the shell. Code read confirms the five tabs exist in `lib/core/navigation/app_shell.dart` in fixed order Home, Kundli, Panchang, Consult, Profile
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable, no screen rendered
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG03 Registration

1. Test ID: UG03
2. Module: Auth
3. Feature: Registration with email and password, valid input and invalid input
4. Preconditions: Web build served, Firebase Auth enabled, no QA account used yet
5. Test input: New email and a password of 6 or more characters, then an invalid email and a weak password
6. Action: Submit the registration form with valid input, then with invalid input
7. Expected result: Valid input creates the account and opens the app shell. Invalid input shows a plain words error and creates nothing
8. Actual result: No registration screen rendered. Code read confirms `signUpWithEmailAndPassword` exists in `lib/services/auth_service.dart` and plain words errors exist for `email-already-in-use` and `weak-password`
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. No account created, no credential written anywhere
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and QA account provisioning

### UG04 Login and reload

1. Test ID: UG04
2. Module: Auth
3. Feature: Login, then browser reload, session must persist
4. Preconditions: QA account provisioned, web build served
5. Test input: QA account email and password
6. Action: Sign in, reload the browser, check the landing screen
7. Expected result: After reload the user stays signed in and lands in the app shell, not on the sign in screen
8. Actual result: No sign in screen rendered. Code read confirms `signInWithEmailAndPassword` exists and the app shell is gated on the `signedIn` stream in `lib/core/navigation/app_shell.dart`
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. No QA account exists yet, no real user credential used
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and QA account provisioning

### UG05 Password reset

1. Test ID: UG05
2. Module: Auth
3. Feature: Password reset email from the forgot password flow
4. Preconditions: QA account provisioned, web build served
5. Test input: QA account email, then an unknown email
6. Action: Request reset for each email, check the confirmation shown
7. Expected result: Reset email sent for the known account, clear message shown. Unknown email handled without leaking account existence
8. Actual result: No reset screen rendered. Code read confirms `sendPasswordResetEmail` exists in `lib/services/auth_service.dart` and the auth screen wires it with a `_resetSentTo` confirmation
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. No reset email sent
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and QA account provisioning

### UG06 Birth profile save and retrieve

1. Test ID: UG06
2. Module: Profile
3. Feature: Birth profile save, then retrieve after reload
4. Preconditions: Signed in QA account, web build served
5. Test input: Name, birth date, birth time, place of birth
6. Action: Save the profile, reload the browser, open the profile again
7. Expected result: Saved values return unchanged after reload
8. Actual result: No profile form rendered. Code read confirms `ProfileFormScreen` exists and `FirestoreService` writes the `users` collection
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. Firestore rules read only: `users` documents allow read and write only when `request.auth.uid` equals the document id, file `firebase/firestore.rules`
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and QA account provisioning

### UG07 Location search and select

1. Test ID: UG07
2. Module: Kundli
3. Feature: Location search and select for place of birth
4. Preconditions: Signed in QA account, Kundli input screen open
5. Test input: Type a city name, pick one result
6. Action: Search, select, confirm latitude and longitude used for calculation
7. Expected result: Typed text returns matching places, selection fills coordinates
8. Actual result: No input screen rendered. Code read shows the Kundli place field is free text in `lib/screens/screens.dart` and the Panchang screen picks from a local `AstroPlace` list dialog. No live location search API call exists in the user app code
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable, location data is local code, not Firestore
12. Defect ID: DF01, DF08
13. Retest result: Retest pending after DF01 fix. Retest must confirm whether free text plus local list is the intended design or a gap

### UG08 Kundli calculate

1. Test ID: UG08
2. Module: Kundli
3. Feature: Kundli calculate and planetary positions verify
4. Preconditions: Signed in QA account, birth profile saved
5. Test input: Real QA birth date, time and place
6. Action: Submit the Kundli form, read planetary positions, compare against the engine
7. Expected result: Chart opens with correct Lagna and planet positions for the given birth data
8. Actual result: No Kundli screen rendered. Engine level evidence only: `test/astro_test.dart` and `test/proof_test.dart` pass in CI run `46043847890`, all 3 jobs green. That is unit proof, not browser proof, and is not marked pass here
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`, CI run `46043847890`
11. Firebase verification: Not applicable, calculation is local engine code
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG09 D1 chart

1. Test ID: UG09
2. Module: Kundli
3. Feature: D1 chart with Lagna chart and Moon chart switch
4. Preconditions: Kundli calculated, chart screen open
5. Test input: Toggle the chart switch
6. Action: Open D1 chart, switch between Lagna and Moon views
7. Expected result: Both views render with correct planets and Lagna
8. Actual result: No chart rendered. Code read confirms `KundliChartScreen` has a Lagna and Moon chart switcher in `lib/screens/screens.dart`
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG10 D9 chart

1. Test ID: UG10
2. Module: Kundli
3. Feature: D9 chart, Navamsa
4. Preconditions: Kundli calculated, chart screen open
5. Test input: Open D9 view
6. Action: Look for D9 tab or switch on the chart screen
7. Expected result: D9 chart renders with its own planetary positions
8. Actual result: Feature absent in release 10 code. Code search for D9, Navamsa, navamsa across `lib` returns nothing. Chart screen offers Lagna and Moon only
9. Result: Not Tested
10. Evidence: Code grep in this task, no matching string in `lib`
11. Firebase verification: Not applicable
12. Defect ID: DF04
13. Retest result: Retest pending after the feature is built, then after DF01 fix

### UG11 D10 chart

1. Test ID: UG11
2. Module: Kundli
3. Feature: D10 chart, Dashamsa
4. Preconditions: Kundli calculated, chart screen open
5. Test input: Open D10 view
6. Action: Look for D10 tab or switch on the chart screen
7. Expected result: D10 chart renders with its own planetary positions
8. Actual result: Feature absent in release 10 code. Code search for D10, Dashamsa, dashamsa across `lib` returns nothing
9. Result: Not Tested
10. Evidence: Code grep in this task, no matching string in `lib`
11. Firebase verification: Not applicable
12. Defect ID: DF04
13. Retest result: Retest pending after the feature is built, then after DF01 fix

### UG12 Dasha timeline

1. Test ID: UG12
2. Module: Kundli
3. Feature: Dasha timeline, current Mahadasha and dates
4. Preconditions: Kundli calculated
5. Test input: Open the Dasha view for the QA birth profile
6. Action: Read the current Mahadasha, its dates and the timeline order
7. Expected result: Current Mahadasha matches the engine result for the birth data, timeline in Vimshottari order
8. Actual result: No Dasha view rendered. Code read confirms Vimshottari Mahadasha engine in `lib/services/astro.dart` with `kDashaOrder`, `kDashaYears` and `DashaInfo`
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG13 Panchang

1. Test ID: UG13
2. Module: Panchang
3. Feature: Panchang date select and location select
4. Preconditions: Signed in QA account, Panchang tab open
5. Test input: Pick a date, pick a place from the list
6. Action: Change date, change place, read Tithi, Nakshatra and other values
7. Expected result: Values update for the chosen date and place
8. Actual result: No Panchang screen rendered. Code read confirms `PanchangScreen` keeps a `_place` starting at `kDefaultPlace` and opens an `AstroPlace` picker dialog
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable, Panchang is local calculation. Firestore `panchang` collection is admin published content, read only for signed in users per rules
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG14 Muhurat

1. Test ID: UG14
2. Module: Panchang
3. Feature: Muhurat date range
4. Preconditions: Signed in QA account, Panchang tab open
5. Test input: Pick a date range, read Shubh Muhurat times
6. Action: Open Muhurat view, change the range, confirm times update
7. Expected result: Shubh Muhurat start and end shown for the chosen range
8. Actual result: No Muhurat view rendered. Code read confirms the Panchang model carries a `shubhMuhurat` string in `lib/models/panchang.dart` and the admin screens carry Shubh Muhurat start and end fields. A user side date range picker was not confirmed in code
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable
12. Defect ID: DF01, DF09
13. Retest result: Retest pending after DF01 fix, with a code read for the range picker first

### UG15 Horoscope

1. Test ID: UG15
2. Module: Horoscope
3. Feature: Rule based daily horoscope result
4. Preconditions: Signed in QA account, Home tab open
5. Test input: Open daily horoscope for the QA profile sign
6. Action: Read the result, confirm it comes from published content or the rule engine, not a fixed sample
7. Expected result: Result matches the published horoscope for the sign and date, or the rule output for the profile
8. Actual result: No Home screen rendered. Code read confirms `HoroscopeScreen` reads the `horoscopes` collection through `FirestoreService`
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. Rules read only: `horoscopes` allow read for signed in users, write owner only
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG16 Matching

1. Test ID: UG16
2. Module: Matching
3. Feature: Kundli matching with two real QA birth profiles
4. Preconditions: Two QA birth profiles provisioned, signed in QA account
5. Test input: Two real birth profiles with date, time and place
6. Action: Submit both profiles, read the score out of 36 and the match verdict
7. Expected result: Score and verdict match the matching engine for the two profiles
8. Actual result: No Matching screen rendered. No QA birth profiles exist yet, so no real pair was available. Code read confirms `MatchingScreen` and `lib/services/matching.dart` exist, and `test/matching_test.dart` passes in CI
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. No profiles created
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and provisioning of two QA birth profiles

### UG17 Numerology

1. Test ID: UG17
2. Module: Numerology
3. Feature: Numerology result from actual input
4. Preconditions: Signed in QA account, numerology screen open
5. Test input: Real name and birth date
6. Action: Submit the input, read the numerology result
7. Expected result: Result computed from the given name and date
8. Actual result: Feature absent in release 10 code. Code search for numerology across `lib` and `test` returns zero matches. No screen, no engine, no test
9. Result: Not Tested
10. Evidence: Code grep in this task
11. Firebase verification: Not applicable
12. Defect ID: DF05
13. Retest result: Retest pending after the feature is built, then after DF01 fix

### UG18 Remedies

1. Test ID: UG18
2. Module: Remedies
3. Feature: Rule based remedy recommendations
4. Preconditions: Signed in QA account, Kundli calculated
5. Test input: Open remedies for the QA profile
6. Action: Read the recommendations, confirm they follow the remedy rules for the chart
7. Expected result: Recommendations match the remedies engine for the profile, with the current Mahadasha reflected
8. Actual result: No Remedies screen rendered. Code read confirms `RemediesScreen` and `lib/services/remedies_engine.dart` exist, and `test/remedies_test.dart` passes in CI
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG19 PDF

1. Test ID: UG19
2. Module: PDF
3. Feature: PDF generate, open, inspect
4. Preconditions: Signed in QA account, Kundli calculated
5. Test input: Tap generate PDF on the Kundli result
6. Action: Generate the file, open it, inspect pages and content
7. Expected result: A readable PDF opens with the Kundli details for the QA profile
8. Actual result: Feature absent in release 10 code. Code search for pdf across `lib`, `pubspec.yaml` and `test` returns zero matches. No PDF package, no generate call, no button
9. Result: Not Tested
10. Evidence: Code grep in this task
11. Firebase verification: Not applicable
12. Defect ID: DF06
13. Retest result: Retest pending after the feature is built, then after DF01 fix

### UG20 Subscription

1. Test ID: UG20
2. Module: Subscription
3. Feature: Subscription entitlement state, premium gate
4. Preconditions: Signed in QA account, premium flag state known
5. Test input: Open a premium gated view such as the full matching report
6. Action: Check whether the gate opens or blocks, and what message shows
7. Expected result: Gate follows the Remote Config `premium_enabled` value and the pricing decision
8. Actual result: No screen rendered. Code read confirms `PremiumService` reads Remote Config `premium_enabled`, default false, and the full matching report is premium gated. Pricing is still undecided per memory, and the flag is off
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run in browser. Memory records Remote Config published as version 1 with `premium_enabled` false and `live_consult_enabled` false. That is console state, not a browser check
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix and after the pricing decision

### UG21 Notifications

1. Test ID: UG21
2. Module: Notifications
3. Feature: Notification delivery and history
4. Preconditions: Signed in QA account, notification permission decided
5. Test input: Open the notifications screen, trigger a test message if available
6. Action: Read the history list, confirm delivery state and empty state
7. Expected result: Sent notifications appear in history, empty state shows when none exist, errors show a plain message
8. Actual result: No notifications screen rendered. Code read confirms `NotificationsScreen` streams the `notifications` collection with error and loading states, and `NotificationService` only logs the FCM token in debug mode. Storing the token against the user document is a later phase task per code comment
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. Rules read only: `notifications` allow read for signed in users, write owner only
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix. Real delivery proof needs a device or a console test message, browser alone cannot prove push delivery

### UG22 Consultation

1. Test ID: UG22
2. Module: Consult
3. Feature: Consultation booking and chat
4. Preconditions: Signed in QA account, Consult tab open
5. Test input: Open consult, start a chat, send a message
6. Action: Book or open a consultation, send a message, confirm it persists
7. Expected result: Chat opens, sent message appears and persists after reload
8. Actual result: No Consult screen rendered. Code read confirms `ConsultScreen` and `ChatScreen` exist with `ChatService`. No astrologer identity exists yet per memory, so the admin answers until one is added
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. Rules read only: `chats` allow read and write only for participants or the owner, messages only from the sender id in the participant list
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix and after the astrologer identity decision

### UG23 Profile edit

1. Test ID: UG23
2. Module: Profile
3. Feature: Profile edit, save, reload
4. Preconditions: Signed in QA account with a saved profile
5. Test input: Change name and place, save, reload
6. Action: Edit the profile, save, reload the browser, open the profile again
7. Expected result: Edited values persist after reload
8. Actual result: No Profile screen rendered. Code read confirms `ProfileScreen` exists with `FirestoreService` and `AuthService`
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run. Rules read only: own `users` document only
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and QA account provisioning

### UG24 Logout

1. Test ID: UG24
2. Module: Auth
3. Feature: Logout ends the session
4. Preconditions: Signed in QA account
5. Test input: Tap sign out
6. Action: Sign out, reload the browser, confirm the landing screen
7. Expected result: After logout and reload the sign in screen shows, and no tab screen opens without sign in
8. Actual result: No screen rendered. Code read confirms the auth gate in `lib/core/navigation/app_shell.dart` returns the sign in screen when the `signedIn` stream is false
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not run
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and QA account provisioning

### UG25 Authorization

1. Test ID: UG25
2. Module: Authorization
3. Feature: Attempt to read another user private record
4. Preconditions: Signed in QA account A, a private record owned by user B exists
5. Test input: Direct read of user B document id in Firestore
6. Action: Attempt the read as user A, record allow or deny
7. Expected result: Read denied by Firestore rules, and the app never shows user B data
8. Actual result: No browser test run, no user B record touched, no cross user read attempted. Rules read only, and the rules are strict: `users` documents allow read and write only when `request.auth.uid` equals the document id. `payments` and `moderation` are owner only. `chats` are participant or owner only. This is code evidence only, not a live denial proof
9. Result: Blocked
10. Evidence: `firebase/firestore.rules` read in this task, `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Rules file read, live denial not proven. A live rules check needs two QA accounts and a real read attempt
12. Defect ID: DF01, DF03
13. Retest result: Retest pending after DF01 fix and provisioning of two QA accounts

### UG26 Console

1. Test ID: UG26
2. Module: Browser
3. Feature: Browser console errors on app load
4. Preconditions: Repo `web` directory served on local server at port 8901
5. Test input: Load `http://127.0.0.1:8901/` at 1280x800 and at 390x844
6. Action: Collect console messages, page errors and failed requests for 4 seconds after load
7. Expected result: App loads with zero console errors
8. Actual result: Console error at both viewports: Failed to load resource, server responded with status 404, File not found. Cause is the missing `flutter_bootstrap.js`. Page errors 0, but the app never started, so zero page errors proves nothing about app code
9. Result: Fail
10. Evidence: `docs/qa/browser-logs/B-web-template-1280.json`, `docs/qa/browser-logs/B-web-template-390.json`, `docs/qa/screenshots/B-web-template-1280.png`, `docs/qa/screenshots/B-web-template-390.png`
11. Firebase verification: Not applicable, no Firebase call was made
12. Defect ID: DF01
13. Retest result: Not yet. Needs DF01 fix and a fresh browser run

### UG27 Network

1. Test ID: UG27
2. Module: Browser
3. Feature: Network requests on app load, no failed app asset
4. Preconditions: Repo `web` directory served on local server at port 8901
5. Test input: Load `http://127.0.0.1:8901/` at 1280x800 and at 390x844
6. Action: Record every response status and every failed request
7. Expected result: All app assets return 200, no failed request
8. Actual result: Index 200, favicon 200, `flutter_bootstrap.js` 404 with `net::ERR_ABORTED`. Direct curl probes also returned 404 for `main.dart.js` and `flutter.js`. The compiled output does not exist because no web build was ever produced
9. Result: Fail
10. Evidence: `docs/qa/browser-logs/B-web-template-1280.json`, `docs/qa/browser-logs/B-web-template-390.json`, `docs/qa/browser-logs/prereq-checks.txt`
11. Firebase verification: Not applicable, no Firebase request was made
12. Defect ID: DF01
13. Retest result: Not yet. Needs DF01 fix and a fresh browser run

### UG28 JavaScript exceptions

1. Test ID: UG28
2. Module: Browser
3. Feature: JavaScript exceptions on app load
4. Preconditions: Repo `web` directory served on local server at port 8901
5. Test input: Load `http://127.0.0.1:8901/` at both viewports
6. Action: Collect page errors for 4 seconds after load
7. Expected result: Zero uncaught JavaScript exceptions from app code
8. Actual result: Zero page errors recorded at both viewports. But the app JavaScript never loaded, because `flutter_bootstrap.js` is missing, so this says nothing about app code. Marked Blocked, not pass
9. Result: Blocked
10. Evidence: `docs/qa/browser-logs/B-web-template-1280.json`, `docs/qa/browser-logs/B-web-template-390.json`
11. Firebase verification: Not applicable
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG29 Responsive

1. Test ID: UG29
2. Module: Browser
3. Feature: Responsive behavior at 390px phone width and 1280px desktop width
4. Preconditions: Real web build served, app rendered
5. Test input: Load the app at 390x844 and at 1280x800
6. Action: Screenshot each viewport, check layout, overflow and tap targets
7. Expected result: Layout fits each viewport with no horizontal overflow and no clipped content
8. Actual result: Both viewports show the same blank white page. Screenshots prove the blank state at both sizes, nothing about app layout
9. Result: Blocked
10. Evidence: `docs/qa/screenshots/B-web-template-390.png`, `docs/qa/screenshots/B-web-template-1280.png`
11. Firebase verification: Not applicable
12. Defect ID: DF01
13. Retest result: Retest pending after DF01 fix

### UG30 Storage

1. Test ID: UG30
2. Module: Storage
3. Feature: Storage upload and download operations
4. Preconditions: Signed in QA account, a Storage backed feature in the user app
5. Test input: Upload a file, then download it
6. Action: Run the upload flow, confirm the file lands in Storage, download it again
7. Expected result: Upload succeeds, download returns the same file, rules allow only the owner
8. Actual result: Feature absent in release 10 code. Code search for Firebase Storage calls across `lib` returns nothing. Only the `storageBucket` string appears in `lib/firebase_options.dart` for Android and iOS. No upload or download code exists to test
9. Result: Not Tested
10. Evidence: Code grep in this task
11. Firebase verification: Not applicable. No Storage rules file exists in the repo
12. Defect ID: DF07
13. Retest result: Retest pending after a Storage feature is built, then after DF01 fix

## BROWSER VERIFICATION

Real browser evidence, Playwright headless Chromium, executable path `/home/hatch/.cache/ms-playwright/chromium-1248/chrome-linux64/chrome`, script `/tmp/phase16-qa/run.js`.

1. Control check passed. Local page `http://127.0.0.1:8900/control.html` loaded with title `Phase16 control page`, body text `Playwright control page OK`, zero page errors, zero failed requests. Screenshot `docs/qa/screenshots/A-control-1280.png`. This proves the harness and the browser work. It proves nothing about the app.
2. App template check failed at both viewports. URL `http://127.0.0.1:8901/` served from the repo `web` directory returned index 200, title `dharm_guru_shrinkhala`, empty body text, one console error for a 404 resource, one failed request `flutter_bootstrap.js` with `net::ERR_ABORTED`, zero page errors. Screenshots `docs/qa/screenshots/B-web-template-1280.png` and `docs/qa/screenshots/B-web-template-390.png` are blank white pages. Logs `docs/qa/browser-logs/B-web-template-1280.json` and `docs/qa/browser-logs/B-web-template-390.json`.
3. Curl probes confirmed the same from the server side. Index 200, `main.dart.js` 404, `flutter.js` 404, `flutter_bootstrap.js` 404.
4. No app screen was ever observed in the browser. No splash, no onboarding, no sign in screen, no tab, no chart, no form. Every app flow result in this report is therefore Blocked or Not Tested, and the two Fail results cover only the served template, not app behavior.
5. No live browser task was used. This subagent cannot run live browser tasks. All browser evidence comes from the headless Playwright script above.

## KNOWN DEFECTS

### P0

1. DF01. No web build exists and CI cannot produce one. CI run `46043847890` has only 2 artifacts, both APKs. The workflow `.github/workflows/flutter-analyze.yml` has jobs analyze, build apk and build ios only, no web build job. No `build/web` directory exists in any clone. The repo `web` directory holds only the unbuilt template, and `web/index.html` line 56 loads `flutter_bootstrap.js`, which does not exist. Browser result is a blank page with a 404. Blocks UG01 to UG09, UG12 to UG16, UG18, UG20 to UG29.
2. DF02. Web Firebase config is placeholders. File `lib/firebase_options.dart` lines 34 to 41 carry `WEB_API_KEY_PLACEHOLDER`, `WEB_APP_ID_PLACEHOLDER`, `MESSAGING_SENDER_ID_PLACEHOLDER`, `PROJECT_ID_PLACEHOLDER`, `AUTH_DOMAIN_PLACEHOLDER`, `STORAGE_BUCKET_PLACEHOLDER`. The file header says no web app is registered yet. Even with a compiled web build, Firebase init would fail and the app would show only the Firebase setup screen from `lib/core/navigation/app_shell.dart`. Blocks UG01 and every auth gated flow after DF01 is fixed.

### P1

1. DF03. No QA accounts provisioned. All auth gated flows UG03, UG04, UG05, UG06, UG16, UG23, UG24, UG25 need provisioned QA accounts before any browser run. No account was created in this task and no credential was written anywhere.
2. DF04. D9 and D10 charts absent in release 10. Code search finds no D9, D10, Navamsa or Dashamsa string in `lib`. Chart screen offers Lagna and Moon only. Affects UG10, UG11.
3. DF05. Numerology absent in release 10. Code search finds zero matches for numerology in `lib` and `test`. No screen, no engine, no test. Affects UG17.
4. DF06. PDF generation absent in release 10. Code search finds zero matches for pdf in `lib`, `pubspec.yaml` and `test`. No PDF package, no generate call. Affects UG19.

### P2

1. DF07. No Firebase Storage code in the user app. Code search finds no Storage upload or download call in `lib`. Only the `storageBucket` string exists in Firebase options. No Storage rules file exists in the repo. Affects UG30.
2. DF08. Location search is free text plus a local city list, not a live search. Kundli place field is free text in `lib/screens/screens.dart`. Panchang place picker is a dialog over the local `AstroPlace` list in `lib/services/astro.dart`. No live location search API call exists. Needs a decision on whether this is the intended design. Affects UG07.
3. DF09. FCM token is not stored against the user. `lib/services/notification_service.dart` only logs token presence in debug mode, and the code comment says storing the token is a later phase task. Real notification delivery proof needs a device or a console test message. Affects UG21.

### P3

1. DF10. Muhurat date range picker not confirmed in user code. The Panchang model carries a `shubhMuhurat` string and admin screens carry start and end fields, but a user side range picker was not confirmed by code read. Needs a code read before retest. Affects UG14.

## REMAINING WORK

1. Fix DF01. Add a web build job to CI or produce a web build another approved way, and publish the artifact. Until then no browser QA of the user app is possible.
2. Fix DF02. Register a web app in the Firebase console for project `dharm-guru-shrinkhala`, run the config step, and replace the web placeholders in `lib/firebase_options.dart` with real values from the console. Do not invent values by hand.
3. Provision QA accounts. Two accounts minimum, plus two real QA birth profiles for matching, before the next browser run. No passwords or tokens in chat or files.
4. Decide DF04, DF05, DF06. D9 chart, D10 chart, numerology and PDF generation are either in scope for a later phase or out of scope. The decision must come from the user, not from QA.
5. Decide DF08. Confirm whether free text place plus local city list is the intended location experience.
6. Decide the astrologer identity for UG22 and the pricing for UG20. Both are already open decisions from earlier phases.
7. Rerun all 30 tests UG01 to UG30 in the browser after DF01 and DF02 are fixed, with the same Playwright harness, same viewports, plus reload checks, invalid input checks and unauthorized access checks per test.
8. Prove UG25 live with two QA accounts and a real denied read attempt, and prove UG21 delivery with a console test message or a real device.

## NEXT PHASE

Phase 16 retest, user app browser QA round 2. Entry criteria are DF01 fixed with a downloadable web build artifact, DF02 fixed with real web Firebase config, and QA accounts provisioned. Round 2 reruns UG01 to UG30 in full, in the browser, with fresh screenshots and logs, and records a retest result per test. This report stays as the round 1 record. Blocked results here must not be copied as pass results in round 2.

Skipped or not checked in this task: live device testing of the APKs, admin app browser testing, live Firestore denial proof, live notification delivery proof, and any code fix for the defects above. Risk the user must know: the user app has never rendered in any browser as of this report, so every user facing flow is unverified in the browser despite 111 unit tests passing in CI.
