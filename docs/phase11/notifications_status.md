# Notifications status, Phase 11

## What was verified in the repo

* `firebase_messaging` 15.1.3 is already a dependency.
* Native Android and iOS Firebase options carry a real
  `messagingSenderId` 987289079284, so a native token fetch
  can work.
* Web Firebase options are placeholders
  (`WEB_API_KEY_PLACEHOLDER`, `MESSAGING_SENDER_ID_PLACEHOLDER`),
  and `web/` has no messaging service worker, so web has no
  push token. Web push is BLOCKED until `flutterfire
  configure` is run for web and a service worker is added.
* The admin app only writes the notification to the
  `notifications` collection. It does not send FCM. The
  user app shows it in the notifications inbox at once.
  That is the in app history, and it already existed.
* The scheduling logic from release 10 is kept untouched:
  `NotificationSchedule.scheduledSendTime` still computes
  `scheduledFor`, and the admin screen still stores it.
  Tests in `test/notification_schedule_test.dart` still
  prove it.

## What Phase 11 added

* Token registration: `NotificationService.initialise`
  fetches the token and stores it on the user document under
  `fcmTokens`, only when notifications are authorised. The
  user document rule allows a user to write only their own
  document.
* Token refresh: the `onTokenRefresh` stream stores the new
  token the same way, with the same authorisation check.
* Token removal on sign out: `removeToken`, ready to wire
  to the sign out path.
* Preferences: `NotificationPreferences` with daily
  horoscope, consult replies, admin announcements and the
  alert time, stored on the user document. A bad stored time
  throws instead of alerting at the wrong hour. The daily
  alert time reuses the release 10 schedule computation.
* Deep link navigation: `NotificationDeepLink.parse` maps a
  push payload or a notification document to home,
  horoscope, panchang, consult or chat. The values match the
  `openScreen` values the admin app writes and the screens
  the inbox already opens. A chat target without a chat id
  falls back to consult, an unknown target to home.
* Wiring: the main screen calls `initialise` with the signed
  in uid after the one time permission prompt, and also on
  later launches when the prompt was already shown.

## What is BLOCKED, exact config needed

Delivery and retry are BLOCKED. No FCM send happens from
any code in this repo:

1. No sender. No Cloud Function sends FCM, and the Blaze
   plan for one is not confirmed.
2. No server key or service account is configured for
   sending. Nothing may be put in chat or in files.
3. No VAPID key is configured, so web push has no key
   either, on top of the placeholder web options above.
4. No retry handling exists yet, because there is no sender
   to retry from. Retry belongs to the sender: exponential
   backoff on a send failure, dead letter after the retries
   run out, and no retry on an invalid token, which is
   removed instead.
5. No delivery receipt exists. FCM delivery can only be
   proved from a real device receiving a console test
   message, which is still open as phone proof.

Until the sender exists, the admin Send button means the
notification is stored and visible in the app, not that a
push was delivered. The admin screen already says this in
its own comment, and no fake delivery is shown anywhere.
