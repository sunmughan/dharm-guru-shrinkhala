# Performance Report

* Status: PASS for the CI runner timings below, NOT_TESTED for every device metric
* Date: 28 Nov 2026
* Branch: phase1218-ci

## Measured on the CI runner

Automated tests test/performance_cache_test.dart, IDs PERF-01 to PERF-05.
Timings are measured with a stopwatch on the GitHub Actions runner.
They are runner numbers, not phone numbers, and they change with
the runner. The tests assert only generous upper bounds, so a slow
runner cannot fail the build. Exact millisecond values per run are
in the CI test log, not copied here, because they are not stable
enough to quote as product numbers.

| Metric | Bound in test | Status |
| Kundli calculation time | under 5 seconds | PASS in CI |
| Panchang calculation time | under 5 seconds | PASS in CI |
| Repeated Kundli returns cached chart | identical instance | PASS in CI |
| Different inputs do not share cache | different instance | PASS in CI |
| Cache clear forces fresh calculation | different instance | PASS in CI |

## NOT_TESTED on any device

| Metric | Status | Reason |
| Initial app load | NOT_TESTED | Needs a phone run with a stopwatch |
| Login duration | NOT_TESTED | Needs a phone run, real auth |
| Dashboard load | NOT_TESTED | Needs a phone run, real Firestore |
| Firestore query latency | NOT_TESTED | Needs a phone run, real network |
| PDF generation time | NOT_TESTED | Feature does not exist yet |
| Memory usage | NOT_TESTED | Needs a phone profiler run |
| Web load time | NOT_TESTED | Needs a browser run against the web build |

No device number is invented here. A metric with no measurement
stays NOT_TESTED.

## Phase 12 quality work done

* Query optimisation: FirestoreService.getDocsPaged, limit 25 by
  default, cursor by document id. Admin lists must use it.
* Firestore indexes: firebase/firestore.indexes.json, six indexes,
  valid JSON, checked in CI.
* Cache invalidation: MemoCache.invalidate per key and clear for
  all keys, plus KundliCalculator.clearCache and
  PanchangCalculator.clearCache for tests.
* Calculation caching: bounded memo cache, 64 entries, keyed by
  inputs only, never by name, email or any personal data.
* Retry behaviour: Retry.run, 3 attempts by default, backoff
  doubling from 200 ms, no retry for ArgumentError. Covered by
  RET-01 to RET-05.
* Input validation: InputValidation for email, password, display
  name, birth date, birth time and birth place. Covered by
  VAL-01 to VAL-09.
* Logging without sensitive data: AppLogger redacts emails and
  long digit runs before writing. Covered by LOG-01 to LOG-04.
* Error boundaries: the admin gate already shows an error, not a
  spinner, on write failure, read failure and timeout. Covered
  by test/admin_gate_test.dart. A global Flutter error boundary
  for the rest of the app does not exist yet, see gaps below.

## Phase 12 gaps, NOT implemented

| Gap | Severity | Note |
| watchDocs streams whole collections with no limit | P2 | Admin screens call watchDocs on users, astrologers, horoscopes, chats, payments, plans, panchang and moderation. getDocsPaged exists now, but no screen uses it yet. Migrating the screens is feature phase work. |
| Offline saved Kundli and report access | P1 | No offline cache of a saved Kundli or a report exists. SharedPreferences holds only flags. |
| Secure Storage rules | P1 | No flutter_secure_storage dependency, no secure storage of tokens or sensitive fields. |
| Data export | P2 | No export of user data exists. |
| Account deletion | P1 | No delete account flow exists in app or in rules. |
| Audit history | P2 | No audit log of admin writes exists. |
| Privacy settings | P2 | No privacy settings screen exists. |
| Rate limiting | P2 | No client side rate limiting exists. Firestore rules do not rate limit. |
| Accessibility | P2 | No accessibility audit was run: no screen reader pass, no contrast check, no tap target check. |
| Responsive web layouts | P2 | No responsive layout check was run on the web builds at 390 px, 768 px and 1280 px. |
| Loading and empty states | P3 | Daily Horoscope has an honest empty state. Other lists were not audited for loading and empty states. |
| Error messages | P3 | Auth errors have clear messages. Other screens were not audited for message quality. |

## Pre-existing formatting debt, P3

* The format gate in CI covers only the files this phase added
  or changed. The rest of lib was not format checked, because no
  local Dart exists on this VM to verify it. Running dart format
  across the whole repo is a follow up for a phase with a local
  Flutter install or a CI run that reports the diff.
