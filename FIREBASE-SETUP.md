# Firebase Setup for Dharm Guru Shrinkhala

Flutter app direct to Firebase, no backend. Follow these console steps in order. Do not invent API keys or config values. Every value comes from the Firebase console or from the generated file.

## 1. Create the Firebase project

* Open the Firebase console
* Create a new project named Dharm Guru Shrinkhala
* Enable Google Analytics for the project when asked, Analytics is used by the app
* Wait for project creation to finish

## 2. Register the Android app

* In Project settings, add an Android app
* Package name: `com.codeair.dharm_guru_shrinkhala`, the Android
  applicationId from `android/app/build.gradle.kts` in this repo.
  The `android/` directory is part of the Flutter project
  scaffolding. If it is missing, create it with
  `flutter create --platforms=android,ios,web .` in the repo root
  before this step, and do not copy the generated `lib/` or
  `pubspec.yaml` over the existing files.
* Download `google-services.json` and place it in `android/app/`
* This file is gitignored. Never commit a real `google-services.json`

## 3. Register the iOS app

* In Project settings, add an iOS app
* Bundle id: `com.codeair.dharmgurushrinkhala`, the iOS bundle
  id from the `ios/` project scaffolding in this repo. If the
  `ios/` directory is missing, create it the same way as in step 2.
* Download `GoogleService-Info.plist` and place it in `ios/Runner/`
* This file is gitignored. Never commit a real `GoogleService-Info.plist`

## 4. Enable Authentication, email, phone and Google

* Open Authentication, then Sign in method
* Enable Email/Password sign in, so sign up, sign in and the
  forgot password reset email work
* Enable Phone sign in
* Enable Google sign in
* Add the SHA fingerprint for the Android app when the console asks for it, so Google sign in works on Android
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

## 7. Enable Remote Config

* Open Remote Config in the Firebase console
* Add the parameters used by the app, with safe defaults:
  * `premium_enabled`, boolean, default false
  * `live_consult_enabled`, boolean, default false
* Publish the config. The app fetches and activates it on start, see `lib/services/firebase_service.dart`

## 8. Enable Crashlytics

* Open Crashlytics in the Firebase console
* Follow the console prompt to enable it for the Android and iOS apps
* The app records fatal Flutter errors to Crashlytics on start, see `lib/services/firebase_service.dart`
* A test crash is a later phase task, not part of Phase 1

## 9. Confirm Analytics

* Analytics was enabled at project creation in step 1
* Confirm the Analytics dashboard shows the project. No extra code step is needed, the app uses Firebase Analytics through the Firebase bootstrap

## 10. Generate the config file

* Install the FlutterFire CLI
* Run `flutterfire configure` in the repo root and select the project and the Android and iOS apps
* This generates real values in `lib/firebase_options.dart`. Replace the placeholder values in that file only with the generated values
* Verify the generated file has no placeholder text left, then run `flutter run`

## 11. Enable your own admin access

The admin app has no hardcoded admin and no open gate. Access is
owner only, through a record in Firestore:

1. Sign in to the admin app once with your own account (email
   password, Google, or phone OTP). Signing in works, but the app
   shows "Admin access is not enabled for this account" until the
   record below exists.
2. In the Firebase console, open Firestore Database, open the
   `admins` collection, and add a document. The document ID must
   be your Firebase Auth user ID (the `uid` shown in
   Authentication > Users for your account).
3. Give that document one field: `role` with the string value
   `owner`.
4. Sign out and sign in again. The admin dashboard opens.

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
* iOS app registered, `GoogleService-Info.plist` in place, not committed
* Auth phone enabled, Auth Google enabled
* Firestore created, locked mode rules in place
* Cloud Messaging reachable from the console composer
* Remote Config parameters published
* `admins/{your uid}` document created with role `owner`
* `firebase/firestore.rules` published in the console
* Crashlytics enabled
* `lib/firebase_options.dart` holds generated values only
