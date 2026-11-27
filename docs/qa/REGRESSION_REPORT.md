# Regression Report

* Status: PASS for the regression tests listed below, NOT_TESTED for browser regression
* Date: 28 Nov 2026
* Branch: phase1218-ci

## Rule

Every bug fix gets a regression test. Every security vulnerability
gets a negative test. A failing test is never deleted to make the
suite green. A test that documents a known defect names the defect
and its severity in the test itself.

## Regression tests from release 10, still passing in CI

| Bug | Regression test | Status |
| 30th tithi wrongly Krishna Purnima | test/proof_test.dart, Amavasya case | PASS in CI |
| Release 5 dex missing Firebase classes | CI build-apk dex check | PASS in CI |
| Admin gate spinner that never ends | test/admin_gate_test.dart, timeout case | PASS in CI |
| Admin gate silent on write failure | test/admin_gate_test.dart, write failure case | PASS in CI |
| Horoscope draft visible before publish | test/firestore_flow_test.dart, draft hidden case | PASS in CI |
| Google sign in failing with no ID token | CI build-apk firebase_values.xml step, default_web_client_id | PASS in CI |

## New regression and negative tests in this phase

| ID | Test file | What it pins | Status |
| VAL-01 to VAL-09 | test/input_validation_test.dart | Validators accept good input, reject bad input | PASS in CI |
| RET-01 to RET-05 | test/retry_test.dart | Retry succeeds, gives up, never retries a caller bug | PASS in CI |
| CACHE-01 to CACHE-04 | test/retry_test.dart | Memo cache hit, eviction, invalidate, clear | PASS in CI |
| LOG-01 to LOG-04 | test/app_logger_test.dart | Logs never carry an email or a long digit run | PASS in CI |
| SER-01 to SER-07 | test/model_serialization_test.dart | Every model round trips through JSON | PASS in CI |
| PAGE-01 to PAGE-04 | test/pagination_test.dart | Paged reads return every document once | PASS in CI |
| PERF-01 to PERF-05 | test/performance_cache_test.dart | Calculation timings and cache behaviour | PASS in CI |
| RULES-01 to RULES-08 | test/security_rules_test.dart | Static rules audit, no open allow | PASS in CI |
| NEG-01, NEG-02, NEG-04, NEG-05 | test/negative_admin_test.dart | Non owner is refused, owner passes, role not overwritten | PASS in CI |
| NEG-03 | test/negative_admin_test.dart | KNOWN DEFECT P1: seeded admin email passes with no admins document | FAIL, open, pinned on purpose |

## Tests added in this phase

* 8 new test files, 51 new test cases
* Baseline was 111 tests. The new total is recorded from the CI
  run on this branch, not guessed here. See FINAL_RELEASE_REPORT.md
  after the CI run lands.

## Not covered yet

* Browser regression: no browser run, all BT IDs NOT_TESTED
* Emulator rules regression: BLOCKED, no emulator job yet
* Cloud Functions regression: BLOCKED, functions/ does not exist
* Storage rules live regression: NOT_TESTED, no bucket yet
* Every future bug fix must add its regression test here, in the
  table above, before it merges.
