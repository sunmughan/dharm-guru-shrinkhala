# User App Browser Test Report

* Status: NOT_TESTED, no browser run has happened on this branch
* Date: 28 Nov 2026
* Branch: phase1218-ci
* Build under test: none yet, web build artifact from the CI build-web job

## Why NOT_TESTED

This agent cannot operate a live browser. The CI browser-smoke job
runs widget tests on headless Chrome only. A full user workflow in
a real browser, signed in, against the built web app, needs a
browser agent. Until that run happens, every ID below stays
NOT_TESTED. No ID is marked PASS on the strength of a unit test.

## Test IDs

| ID | Workflow | Status |
| BT-USER-01 | Open the user web app, splash loads, no console error | NOT_TESTED |
| BT-USER-02 | Sign up with email and password, reach home | NOT_TESTED |
| BT-USER-03 | Sign in with email and password, reach home | NOT_TESTED |
| BT-USER-04 | Sign in with Google, reach home | NOT_TESTED |
| BT-USER-05 | Forgot password sends a reset email | NOT_TESTED |
| BT-USER-06 | Signed out user cannot reach any screen, auth gate holds | NOT_TESTED |
| BT-USER-07 | Fill the Kundli form, submit, chart renders with 9 planets | NOT_TESTED |
| BT-USER-08 | Kundli form rejects a future birth date with a clear message | NOT_TESTED |
| BT-USER-09 | Open planet details from the chart | NOT_TESTED |
| BT-USER-10 | Daily Horoscope shows the published entry for today | NOT_TESTED |
| BT-USER-11 | Daily Horoscope shows an honest empty state when nothing is published | NOT_TESTED |
| BT-USER-12 | Panchang shows today values for the chosen city | NOT_TESTED |
| BT-USER-13 | Kundli Matching returns a score and a Low Match case | NOT_TESTED |
| BT-USER-14 | Remedies list matches the computed weak planets and Mahadasha | NOT_TESTED |
| BT-USER-15 | Profile save persists, reload shows the saved values | NOT_TESTED |
| BT-USER-16 | Library shows dasha timeline and festivals | NOT_TESTED |
| BT-USER-17 | Consult Chat sends and receives a message | NOT_TESTED |
| BT-USER-18 | Premium screen shows the locked state while Remote Config is false | NOT_TESTED |

## What the browser run must record

* One screenshot per ID in docs/qa/screenshots/, named BT-USER-01.png and so on
* Console log and network log in docs/qa/browser-logs/, named BT-USER-01.log and so on
* The exact build artifact used, with its CI run number and commit SHA
* The signed in account used, without recording its password anywhere

## Automated coverage that already exists

* test/widget_test.dart: 6 widget tests, PASS in CI
* test/proof_test.dart: 10 tests, real input to real output, PASS in CI
* test/firestore_flow_test.dart: 3 tests, profile save and publish flow, PASS in CI
* test/chat_test.dart: 2 tests, PASS in CI
* These prove logic, not the browser. They do not change any status above.
