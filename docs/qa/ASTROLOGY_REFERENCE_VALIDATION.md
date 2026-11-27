# Astrology Reference Validation

* Status: PASS for the checks listed below, NOT_TESTED for independent ephemeris comparison
* Date: 28 Nov 2026
* Branch: phase1218-ci

## Engine

lib/services/astro.dart. Real Vedic calculations, pure Dart, no
network, no table lookup, no AI, no LLM prediction anywhere.

* Tropical longitudes from the standard low precision algorithms
  from Paul Schlyter, Sun, Moon and planets from Keplerian elements
* Conversion to sidereal longitudes with the Lahiri ayanamsa
* Lagna, rashi, nakshatra, tithi, yoga, karana, sunrise, sunset,
  abhijit muhurat and rahu kaal derived from those longitudes
* Vimshottari Mahadasha from the Moon nakshatra lord

## Known precision limits, from the code itself

* Planetary longitudes use mean elements without the small
  perturbation terms, so Jupiter and Saturn can sit up to about
  half a degree from a full ephemeris. That never moves a planet
  to another rashi except within half a degree of a cusp.
* Places outside the city list fall back to Jaipur coordinates
  and the result is marked approximate.
* These limits are recorded as shortcut comments in astro.dart.
  Upgrade to full VSOP87 only if sub degree precision is ever needed.

## Automated checks

* test/astro_test.dart: 10 tests against a known ephemeris, PASS in CI
* test/matching_test.dart: 4 tests, including Matching 11/36 Low Match, PASS in CI
* test/remedies_test.dart: 4 tests, PASS in CI
* test/proof_test.dart: 10 tests, real input to real output, PASS in CI
* test/library_test.dart: 5 tests, PASS in CI
* test/performance_cache_test.dart, new in this phase: PERF-01 to PERF-05
  * Kundli calculation finishes in under 5 seconds on the CI runner
  * Panchang calculation finishes in under 5 seconds on the CI runner
  * Repeated calculation returns the cached chart, different inputs
    do not share a cache entry, clearing the cache forces a fresh
    calculation
  * These are runner timings, not phone timings

## Amavasya fix, regression covered

* Release 10 fixed the 30th tithi: now Krishna Amavasya, was wrongly
  Krishna Purnima. The fix is covered by the proof tests in
  test/proof_test.dart. Any future change to tithi math must add a
  regression test before it merges, see REGRESSION_REPORT.md.

## NOT_TESTED

* No independent ephemeris comparison was run in this phase. No
  second source, such as Swiss Ephemeris or a published panchang,
  was compared against the engine output for a set of dates.
* To complete: pick a fixed set of birth dates and places, compute
  lagna, Moon rashi, nakshatra and tithi, and record the values
  beside the same values from an independent ephemeris, with the
  difference in degrees for each planet.
* Kundli and Panchang timings on a real phone are NOT_TESTED.
  CI runner timings are in PERFORMANCE_REPORT.md.
