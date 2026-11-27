# Dharm Guru Shrinkhala

Astrology and horoscope app. Flutter app direct to Firebase, no backend.

## Overview

Dharm Guru Shrinkhala is an astrology and horoscope app with an Indian spiritual design language in saffron and deep ink tones.

Visual flow: birth details to kundli, horoscope, panchang, matching, remedies, live consult.

User scope: free and premium plans. Owner scope: admin panel to manage astrologers, publish daily horoscope content, manage subscriptions and payments, view analytics and revenue, send push notifications, and moderate content. The admin panel is a later phase.

Pricing: to be decided everywhere. No price is invented in this repo.

## Sample data

All screens in Phase 1 use the same sample data, labelled sample data on screen:

* Birth: 14 March 1998, 06:25 AM, Jaipur, Rajasthan
* Sample name: Aarav Sharma
* Lagna: Meena, Rashi: Kanya, Nakshatra: Hasta, Tithi at Birth: Krishna Dwitiya
* Surya in Meena lagna at 01° 24′

Design tokens in `lib/core/theme/design_tokens.dart` use the exact values from `design/DESIGN-SYSTEM.md`, which takes every token from the presentation.

No real horoscope prediction is shown. No astrologer names are used. Planet rows carry the exact sample values from `design/screens/06-planet-details.md`. Panchang values carry the exact sample values from `design/screens/08-panchang.md`. Sample day is Saturday 14 March 1998, so Vaar is Shanivaar.

## Project structure

* `lib/main.dart` app entry point, Firebase bootstrap
* `lib/firebase_options.dart` placeholder Firebase config, replace with generated values
* `lib/core/theme/design_tokens.dart` colours, type scale, spacing
* `lib/core/navigation/app_shell.dart` bottom tab shell and root widget
* `lib/models/kundli.dart` birth details and sample planet data
* `lib/models/panchang.dart` panchang and horoscope models
* `lib/services/firebase_service.dart` Firebase bootstrap, Remote Config, Messaging
* `lib/services/auth_service.dart` phone sign in and Google sign in
* `lib/services/firestore_service.dart` Firestore collections
* `lib/services/notification_service.dart` Cloud Messaging setup
* `lib/widgets/kundli_chart.dart` North Indian square kundli chart
* `lib/widgets/planet_details.dart` planet details with degrees
* `lib/screens/screens.dart` splash, onboarding, home, kundli input, kundli chart, horoscope, panchang, matching, remedies, profile

## How to run

Requirements: Flutter SDK 3.22 or later, Dart 3.4 or later, a Firebase project. Flutter was not installed on the machine that created this Phase 1 foundation, so the build is not verified here. Install Flutter first, then run the steps below.

* Install Flutter from the official Flutter site and add it to your path
* Run `flutter pub get` in the repo root
* Configure Firebase, see FIREBASE-SETUP.md
* Run `flutter run` to start the app on a connected device or emulator
* Run `flutter analyze` to check the code
* Run `flutter test` to run tests when tests are added

## Firebase setup

See FIREBASE-SETUP.md for the full console steps.

Services to enable: Auth with phone and Google, Firestore, Cloud Messaging, Remote Config, Analytics. Crashlytics is removed, see FIREBASE-SETUP.md section 8.

Do not invent API keys or config values. Run `flutterfire configure` and use the generated values in `lib/firebase_options.dart`. The placeholder file in this repo is committed on purpose so the structure is visible; replace its placeholder values only with generated values.

## Roadmap phases

* Phase 1 foundation, this repo state: project skeleton, navigation shell, design tokens, sample kundli chart and planet details, panchang layout, Firebase setup docs. No production release.
* Phase 2: real kundli calculation, real panchang calculation, horoscope content publishing from the admin panel.
* Phase 3: live astrologer consult by chat and call, notifications, free versus premium gating.
* Phase 4: admin panel, subscriptions and payments, analytics and revenue, content moderation. Payments start only after pricing is decided.

## What is NOT built yet

* No production release
* No real astrologer data and no astrologer names
* No real kundli calculation, no real panchang calculation, no real horoscope predictions
* No payment integration until pricing is decided
* No admin panel
* No live consult by chat or call
* No real user accounts in production; phone and Google sign in code is present but untested against a live Firebase project

## Repo

Private repo: https://github.com/sunmughan/dharm-guru-shrinkhala
