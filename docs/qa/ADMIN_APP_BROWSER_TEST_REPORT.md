# Admin App Browser Test Report

* Status: NOT_TESTED, no browser run has happened on this branch
* Date: 28 Nov 2026
* Branch: phase1218-ci
* Build under test: none yet, web build artifact from the CI build-web job

## Why NOT_TESTED

Same reason as the user app report: this agent cannot operate a
live browser, and the CI browser-smoke job runs widget tests on
headless Chrome only. A full admin workflow in a real browser,
signed in as the owner, against the built admin web app, needs a
browser agent. Until that run happens, every ID below stays
NOT_TESTED.

## Test IDs

| ID | Workflow | Status |
| BT-ADMIN-01 | Open the admin web app, sign in as owner, dashboard loads | NOT_TESTED |
| BT-ADMIN-02 | A non owner signed in user is refused the admin panel | NOT_TESTED |
| BT-ADMIN-03 | Dashboard shows users, astrologers, horoscopes, payments counts | NOT_TESTED |
| BT-ADMIN-04 | Approve an astrologer, astrologer appears in the user app Consult list | NOT_TESTED |
| BT-ADMIN-05 | Publish a Daily Horoscope draft, user app shows it the same day | NOT_TESTED |
| BT-ADMIN-06 | A draft horoscope stays hidden in the user app | NOT_TESTED |
| BT-ADMIN-07 | Publish Panchang for a date, user app shows it | NOT_TESTED |
| BT-ADMIN-08 | Subscriptions and Payments screen lists plans and payments | NOT_TESTED |
| BT-ADMIN-09 | Analytics and Revenue screen loads without error | NOT_TESTED |
| BT-ADMIN-10 | Send a push notification, it reaches the user app inbox | NOT_TESTED |
| BT-ADMIN-11 | Content Moderation lists flagged items and an action applies | NOT_TESTED |
| BT-ADMIN-12 | Admin record write failure shows an error, not a spinner | NOT_TESTED |
| BT-ADMIN-13 | Admin access check timeout shows an error, not a spinner | NOT_TESTED |
| BT-ADMIN-14 | Try again after a failure reruns the check and lets the owner in | NOT_TESTED |

## What the browser run must record

* One screenshot per ID in docs/qa/screenshots/, named BT-ADMIN-01.png and so on
* Console log and network log in docs/qa/browser-logs/, named BT-ADMIN-01.log and so on
* The exact build artifact used, with its CI run number and commit SHA
* The owner account used, without recording its password anywhere

## Automated coverage that already exists

* test/admin_gate_test.dart: 4 widget tests, write failure, read
  failure, timeout and Try again, PASS in CI
* test/admin_proof_test.dart: admin proof tests, PASS in CI
* These prove the gate logic, not the browser. They do not change
  any status above.

## Known admin defects that the browser run must confirm

* P1 seeded admin email bypass, see FIREBASE_SECURITY_REPORT.md
* P1 any Google sign in grants owner, see FIREBASE_SECURITY_REPORT.md
* P2 default admin password admin123 still in code
