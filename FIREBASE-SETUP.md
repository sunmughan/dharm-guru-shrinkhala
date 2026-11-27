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
* Bundle id: `com.codeair.dharm_guru_shrinkhala`, the iOS bundle
  id from the `ios/` project scaffolding in this repo. If the
  `ios/` directory is missing, create it the same way as in step 2.
* Download `GoogleService-Info.plist` and place it in `ios/Runner/`
* This file is gitignored. Never commit a real `GoogleService-Info.plist`

## 4. Enable Authentication, phone and Google

* Open Authentication, then Sign in method
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

## Checklist

* Project created, Analytics on
* Android app registered, `google-services.json` in place, not committed
* iOS app registered, `GoogleService-Info.plist` in place, not committed
* Auth phone enabled, Auth Google enabled
* Firestore created, locked mode rules in place
* Cloud Messaging reachable from the console composer
* Remote Config parameters published
* Crashlytics enabled
* `lib/firebase_options.dart` holds generated values only
