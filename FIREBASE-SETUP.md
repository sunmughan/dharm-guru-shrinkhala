# Firebase Setup for Dharm Guru Shrinkhala

Flutter app direct to Firebase, no backend. Follow these console steps in order. Do not invent API keys or config values. Every value comes from the Firebase console or from the generated file.

## 1. Create the Firebase project

* Open the Firebase console
* Create a new project named Dharm Guru Shrinkhala
* Enable Google Analytics for the project when asked, Analytics is used by the app
* Wait for project creation to finish

## 2. Register the Android apps

There are two Android apps in this project, one per flavor, so both
can live side by side on one phone:

* User app package name: `com.codeair.dharm_guru_shrinkhala`
* Admin app package name: `com.codeair.dharm_guru_shrinkhala.admin`

* In Project settings, add an Android app for each package name
  above. The package names come from `android/app/build.gradle.kts`
  in this repo.
* Download `google-services.json` and place it in `android/app/`
* This file is gitignored. Never commit a real `google-services.json`
* The app itself starts from the values in
  `lib/firebase_options.dart`, not from this file, so the file is
  only needed for native Google sign in. The app builds on CI
  without it. Do not add the google-services Gradle plugin: the
  build on CI has no `google-services.json` to read, and the plugin
  would fail the build.
* The admin Android app is NOT registered yet (console step still
  owed). The admin flavor currently reuses the user app
  registration, so Google sign in in the admin app on Android
  will fail until the admin app is registered and its SHA-1 is
  added. After registering it, download `google-services.json`
  again and update the GOOGLE_SERVICES_JSON_BASE64 repo secret
  with the new file, so CI builds with both clients.

## 3. Register the iOS apps

There are two iOS apps in this project, one per flavor:

* User app bundle id: `com.codeair.dharmgurushrinkhala`
* Admin app bundle id: `com.codeair.dharmgurushrinkhala.admin`

* In Project settings, add an iOS app for each bundle id above.
  The bundle ids come from `ios/Runner.xcodeproj/project.pbxproj`
  in this repo.
* Download `GoogleService-Info.plist` and place it in `ios/Runner/`
* This file is gitignored. Never commit a real `GoogleService-Info.plist`
* Both flavors share the one `ios/Runner/Info.plist` in this repo.
  After the admin iOS app is registered, its own reversed client id
  belongs in a flavor specific Info.plist. Until then Google sign in
  on the admin iOS build uses the user app client id.

## 4. Enable Authentication, email, phone and Google

* Open Authentication, then Sign in method
* Enable Email/Password sign in, so sign up, sign in and the
  forgot password reset email work
* Enable Phone sign in
* Enable Google sign in
* Add the SHA fingerprint for EACH Android app when the console asks
  for it, so Google sign in works on Android for both the user app
  and the admin app. Both apps are signed with the same permanent
  release key, so both take the SAME fingerprint:
  * SHA-1: `D9:1A:02:84:0D:FE:F5:82:D3:3E:3E:9C:21:5A:77:D2:73:D7:89:A3`
  * SHA-256: `51:9C:8C:FD:B1:94:F4:5D:50:BF:F2:0A:D5:AF:1D:E7:67:A6:73:C2:47:03:CD:7E:BB:0D:A9:36:B9:2E:68:72`
  * Subject: `CN = Dharm Guru Shrinkhala, O = Codeair Software Solutions, C = IN`
  * The key never changes: every CI build signs with it, so this
    fingerprint stays valid for every future release. See the
    release signing key section below. Without a registered SHA-1
    there is no Android OAuth client, and Google sign in on
    Android fails even though email sign in and phone OTP work.
  * The `google-services.json` on disk currently has an empty
    `oauth_client` list. After the SHA-1 is registered for the
    user app and the admin app is registered, re-download the
    file and confirm it lists an Android OAuth client for each
    package and a web OAuth client. Then update the
    GOOGLE_SERVICES_JSON_BASE64 repo secret with the new file.
* Phone sign in needs no extra step in the console beyond enabling it

## 5. Enable Firestore

* Open Firestore Database
* Create the database in production mode
* Choose a location close to the users
* Collections planned in Phase 1: `users`, `horoscopes`, `astrologers`, `panchang`
* Set security rules before any production use. The default locked mode is the safe starting point. Rules that open reads or writes are a later phase task with review.
  The owner only rules for this app live in `firebase/firestore.rules` in this repo. Paste that file into the console rules editor and publish it. Do not invent wider rules.

## 6. Enable Cloud Messaging

* Open Cloud Messaging in the Firebase console
* No extra console step is needed to send from the console. The app requests permission and fetches a token on start, see `lib/services/notification_service.dart`
* To send a test message, use the console messaging composer and target the app
* Web push is not configured: the web Firebase options are placeholders and there is no messaging service worker, so web has no push token. Native Android and iOS fetch a token, and the app stores it on the user document only when notifications are authorised.
* Permission timing: the app asks for notification permission once,
  on the main screen after onboarding and sign in, with the reason
  shown first. No permission dialog appears at app open, during
  the splash screen, or during onboarding.

## 7. Enable Remote Config

* Open Remote Config in the Firebase console
* Add the parameters used by the app, with safe defaults:
  * `premium_enabled`, boolean, default false
  * `live_consult_enabled`, boolean, default false
* Publish the config. The app fetches and activates it on start, see `lib/services/firebase_service.dart`

## 8. Crashlytics is removed, do not re-enable it

* Crashlytics was removed from the app in release 6 (0.1.0+4).
  Its component broke Firebase init on the phone: the release
  build shipped without the Crashlytics component and init threw
  a missing component error, so the app showed the setup screen.
* Do not add the firebase_crashlytics dependency back and do not
  enable Crashlytics in the console. Fatal Flutter errors are
  logged by the app instead of being sent to Crashlytics.

## 9. Confirm Analytics

* Analytics was enabled at project creation in step 1
* Confirm the Analytics dashboard shows the project. No extra code step is needed, the app uses Firebase Analytics through the Firebase bootstrap

## 10. Generate the config file

* Install the FlutterFire CLI
* Run `flutterfire configure` in the repo root and select the project and the Android and iOS apps
* This generates real values in `lib/firebase_options.dart`. Replace the placeholder values in that file only with the generated values
* Verify the generated file has no placeholder text left, then run `flutter run`
* The admin flavor currently reuses the user app registration in
  `lib/firebase_options.dart`. After the admin Android and iOS apps
  are registered in steps 2 and 3, add their app ids to that file
  and select them per flavor. Do not invent the values.

## 13. Build the two flavors

* User APK: `flutter build apk --release --flavor user`
* Admin APK: `flutter build apk --release --flavor admin -t lib/main_admin.dart`
* User iOS: `flutter build ios --release --flavor user --no-codesign`
* Admin iOS: `flutter build ios --release --flavor admin --no-codesign -t lib/main_admin.dart`
* A plain `flutter build apk` with no flavor now fails. Always pass
  a flavor.

## 11. Enable your own admin access

The admin app has no hardcoded admin bypass and no open gate.
Access is owner only, through a record in Firestore, and the
default admin account is seeded through Firebase Auth:

1. Default admin account: `admin@gmail.com` with password
   `admin123`. The admin app creates this account through
   Firebase Auth on its first launch, and writes the `admins`
   record with role `owner` for it. Sign in with it and the
   admin dashboard opens.
2. After the first sign in, change the password from the admin
   Account screen (change password, with reauthentication). The
   default password is a starting point, not a password to keep.
3. Google sign in in the admin app: whoever signs in or creates
   an account with Google in the admin app gets an `admins`
   record with role `owner` automatically, so they get admin
   access. A Google account linked to the default admin account
   (from the Account screen, "Link Google account") opens the
   SAME admin account, by email password and by Google, never
   two separate admin accounts.
4. Manual fallback: sign in to the admin app once with your own
   account (email password, Google, or phone OTP). Signing in
   works, but the app shows "Admin access is not enabled for
   this account" until the record below exists.
5. In the Firebase console, open Firestore Database, open the
   `admins` collection, and add a document. The document ID must
   be your Firebase Auth user ID (the `uid` shown in
   Authentication > Users for your account).
6. Give that document one field: `role` with the string value
   `owner`.
7. Sign out and sign in again. The admin dashboard opens.

Only that one account can write admin content. The Firestore rules
in `firebase/firestore.rules` enforce it: every admin write checks
that the signed in user has an `admins` record with role `owner`.
Publish the rules in the console (Firestore Database > Rules >
Publish) after any change to that file.

## 12. Publish the Firestore rules

* Open the Firebase console > Firestore Database > Rules
* Paste the contents of `firebase/firestore.rules`
* Click Publish
* Without this step the admin writes are denied and the admin app
  shows its write error message

## Checklist

* Project created, Analytics on
* Android app registered, `google-services.json` in place, not committed
* Admin Android app registered (`com.codeair.dharm_guru_shrinkhala.admin`)
* iOS app registered, `GoogleService-Info.plist` in place, not committed
* Admin iOS app registered (`com.codeair.dharmgurushrinkhala.admin`)
* SHA-1 `D9:1A:02:84:0D:FE:F5:82:D3:3E:3E:9C:21:5A:77:D2:73:D7:89:A3`
  added for the user Android app and for the admin Android app
  (same key signs both; see the signing key section below)
* Auth phone enabled, Auth Google enabled
* Firestore created, locked mode rules in place
* Cloud Messaging reachable from the console composer
* Remote Config parameters published
* Default admin account seeded on first admin launch
  (`admin@gmail.com` / `admin123`), password changed after
  first sign in
* `admins/{your uid}` document created with role `owner`
* `firebase/firestore.rules` published in the console
* Crashlytics removed from the app, do not re-enable it (section 8)
* `lib/firebase_options.dart` holds generated values only

## 14. Release signing key (permanent)

Releases before round 4 were signed with a fresh debug key on
every CI build, so each release had a different signing cert and
Google sign in could never be registered. Since release 7 every
CI build signs both flavors with one permanent release key:

* Keystore: RSA 2048, self signed, alias `dharmguru`,
  CN = Dharm Guru Shrinkhala, O = Codeair Software Solutions,
  C = IN, 10000 days, PKCS12, one password for store and key
* SHA-1: `D9:1A:02:84:0D:FE:F5:82:D3:3E:3E:9C:21:5A:77:D2:73:D7:89:A3`
* SHA-256: `51:9C:8C:FD:B1:94:F4:5D:50:BF:F2:0A:D5:AF:1D:E7:67:A6:73:C2:47:03:CD:7E:BB:0D:A9:36:B9:2E:68:72`
* Secrets in this repo: `DHARM_GURU_KEYSTORE_BASE64`,
  `DHARM_GURU_KEYSTORE_PASSWORD`, `DHARM_GURU_KEY_PASSWORD`
  (same value as the store password), `DHARM_GURU_KEY_ALIAS`
* Keystore backup: `~/workspace/keys/dharm-guru-release.keystore`
  on the build machine. Keep a safe copy of the passwords: if
  they are lost, the keystore is unusable and the app can never
  be updated in place again.
* The CI workflow fails the build if the APK cert subject is
  Android Debug, so a debug signed release can never ship by
  mistake.
* Because the release 6 APKs were signed with a debug key, the
  user must UNINSTALL release 6 from the phone before
  installing release 7. Android refuses an update when the
  signing cert changes.
