# Firebase Security Report

* Status: PASS for the static rules audit, BLOCKED for emulator rules tests, FAIL for one known defect below
* Date: 28 Nov 2026
* Branch: phase1218-ci

## Static rules audit, PASS

Automated tests test/security_rules_test.dart, IDs RULES-01 to RULES-08,
run in CI in the test job. They read the shipped rules files and assert:

* RULES-01: no open allow in firebase/firestore.rules
* RULES-02: a user reads and writes only their own profile, request.auth.uid == uid
* RULES-03: published content writes need the owner role
* RULES-04: chat messages can only be sent as yourself, senderId == request.auth.uid
* RULES-05: payments and moderation are owner only
* RULES-06: rules_version 2 is declared
* RULES-07: Storage rules deny everything by default
* RULES-08: Storage rules have no open allow

The CI rules-gate job repeats the open allow grep and validates
firebase.json and firebase/firestore.indexes.json as JSON.

## Emulator rules tests, BLOCKED

No test in this repo runs the Firebase rules emulator. The emulator
needs Java and the Firebase CLI on the runner, and no job installs
them yet. A live allow or deny is therefore NOT proven by an
automated test. The console Rules Playground check from 28 Nov 2026
00:06 IST, owner write allowed and non owner write denied, is the
only live evidence, and it was a manual console check, not a test.

To unblock: add a firebase emulator job to CI that installs the
Firebase CLI, starts the Firestore emulator, and runs rules tests
with the rules unit testing library against firebase/firestore.rules.

## Storage rules, NOT_TESTED live

firebase/storage.rules is new in this phase. It denies everything
by default, lets a signed in user read and write only under
users/{uid}, and lets the owner write under published/.

* The app has no Storage usage yet and no firebase_storage dependency
* No Storage bucket exists in the console yet
* firebase.json now points at the Storage rules file, but nothing
  deploys it until a bucket exists
* Live status stays NOT_TESTED until a bucket exists and the rules deploy

## Known defects

### P1: seeded admin email bypass in isAdminUser

* File: lib/services/firestore_service.dart, isAdminUser
* Finding: when the email is admin@gmail.com, the method returns true
  with no admins document at all. The seeded admin account can open
  the admin panel even if the owner record is deleted or the rules
  were never published.
* Negative test NEG-03 in test/negative_admin_test.dart pins this
  behaviour on purpose, so the removal is a visible deliberate
  change, not a silent one.
* Fix condition, from the master order: remove the bypass only after
  secure owner provisioning is proven working, decision to parent first.
* Status: FAIL, open

### P1: any Google sign in to the admin app grants owner

* File: lib/services/firestore_service.dart, ensureAdminDoc
* Finding: the method creates an admins document with role owner for
  any uid that signs in to the admin app with Google, when no document
  exists. The Firestore rules allow a signed in user to write only
  their own admins document, so the app itself hands out the owner
  role to the first Google account that signs in.
* Negative test NEG-05 proves an existing role is not overwritten,
  but it does not fix the first grant.
* Fix condition: same as the P1 above, secure owner provisioning first.
* Status: FAIL, open

### P2: default admin password in code

* File: lib/core/admin_config.dart, kDefaultAdminPassword admin123
* Finding: the default password is a constant in the repo. The master
  order says remove the default admin seed after secure owner
  provisioning is proven.
* Status: FAIL, open, removal blocked on the same condition as the P1 items

## Role escalation and ownership, automated coverage

* NEG-01: a uid with no admins document is not an admin, PASS in CI
* NEG-02: a uid with role member is not an admin, PASS in CI
* NEG-04: a uid with role owner passes the document based check, PASS in CI
* NEG-05: ensureAdminDoc does not overwrite an existing role, PASS in CI
* Cross user profile read and write, chat send as another user, and
  payment read as a normal user have no automated test yet. They need
  emulator rules tests, so they stay BLOCKED with the emulator job.

## Secrets

* No service account JSON, private key, password, access token or
  Firebase credential is committed in this branch
* Android config and release keystore come only from GitHub Actions Secrets
* The CI release gate now fails the build when the keystore secret is
  missing, instead of silently falling back to a debug key
