# QA Reports

Quality, automated tests, QA reports, CI and final summary live here.
Owner of this folder: Phase 12 18 19 21 24 agent, branch phase1218-ci.

## Status words

Only these four words are used for status, in every report.

* PASS: verified with evidence named in the report
* FAIL: verified and found broken, with evidence
* BLOCKED: cannot be tested yet, with the reason named
* NOT_TESTED: not run yet, no claim made

BLOCKED is never written as PASS. NOT_TESTED is never written as PASS.

## Reports

* BASELINE_REPORT.md: baseline release 10, what was true before this phase
* FIREBASE_SECURITY_REPORT.md: Firestore rules, Storage rules, auth and roles
* LIBRARY_COMPATIBILITY_REPORT.md: dependencies, licenses, versions
* ASTROLOGY_REFERENCE_VALIDATION.md: calculation checks against known values
* USER_APP_BROWSER_TEST_REPORT.md: user app browser workflows BT-USER-01 to BT-USER-18
* ADMIN_APP_BROWSER_TEST_REPORT.md: admin app browser workflows BT-ADMIN-01 to BT-ADMIN-14
* ASTROLOGER_WORKFLOW_TEST_REPORT.md: astrologer and consult workflows
* FIREBASE_INTEGRATION_REPORT.md: live Firebase integration checks
* PDF_AND_PAYMENT_TEST_REPORT.md: PDF generation and payments
* PERFORMANCE_REPORT.md: measured timings, Phase 12 quality gaps
* REGRESSION_REPORT.md: regression coverage for every bug fix
* FINAL_RELEASE_REPORT.md: release verdict, filled only when every phase is done

## Evidence folders

* screenshots/: browser and phone screenshots, one file per browser test ID
* browser-logs/: console and network logs from browser runs
* test-results/: CI test output and coverage files, copied from CI artifacts

## Coverage matrix

FEATURE_INVENTORY.md maps every feature to implementation files,
backend integration, automated tests, browser test IDs and final status.
Other agents send their reports here; this folder integrates them.
Until a report arrives, its rows stay NOT_TESTED.

## Baseline

* Repo: sunmughan/dharm-guru-shrinkhala, main, HEAD eb0c471, release 10
* Baseline CI run 46043847890 green, 111 tests, flutter analyze clean
* This branch: phase1218-ci, quality and CI work only, no feature code
