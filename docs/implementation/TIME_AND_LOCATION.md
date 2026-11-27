# Time and Location Infrastructure

Date: 28 November 2026. Baseline: release 10, HEAD eb0c471.
What Phase 3 verified, what it extended, and what is still
missing. All functions named here live in
lib/services/astro.dart unless stated otherwise.

## Verified: what the engine already did right

Julian Day: the engine day number is JD minus 2451543.5,
and the conversion is now public as julianDay. Checked:
2000-01-01 12:00 UTC is JD 2451545.0, and 1998-03-14
00:55 UTC, the canonical birth instant, is JD 2450886.54.
Leap years: Dart DateTime handles them, and the reference
tests cover 29 February 2000 and 29 February 2024
explicitly. Day boundaries: the Hindu day runs sunrise to
sunrise, and localSolarDay now returns sunrise, next
sunrise and the day length, so panchang code can stop
using midnight as the day boundary. Sunrise and sunset:
already computed from solar declination with the minus
0.833 degree horizon correction and the equation of time.
Checked against Skyfield DE421: Jaipur 14 March 1998,
sunrise 06:37 IST by Skyfield, engine within 5 minutes.
Sunset 18:34 IST by Skyfield, engine within 5 minutes.

## Extended in this phase

julianDay: public, tested against J2000.0.
indiaUtcOffset: the India offset history, in one place.
IST is UTC plus 5 hours 30 minutes since 1906. India ran
wartime daylight saving, UTC plus 6 hours 30 minutes,
from 15 May 1942 to 15 October 1945. Before 1906 each city
kept local mean time, so the offset comes from the
longitude at 4 minutes per degree east. A birth in 1943
now converts with the right offset; before this phase it
was silently an hour wrong.
sunriseSunset: public, takes the place and the zone
offset, returns local wall clock sunrise and sunset. The
old panchang code kept its own inline copy for India; the
new function is the one the reference tests check.
moonriseMoonset: new. Moon altitude from the Schlyter
lunar theory plus the main Meeus latitude terms, sampled
every 10 minutes across the local day, crossings bisected
to the minute at minus 0.583 degrees. Either value is null
when the Moon does not rise or set that day. Checked
against Skyfield: Jaipur 14 March 1998, moonset 07:14 IST
and moonrise 19:39 IST by Skyfield, engine within 15
minutes. The looser tolerance is honest: the Moon moves
about half a degree an hour and the latitude terms are
truncated.
localSolarDay: new. Sunrise to next sunrise, with length.
The panchang day boundary.
tropicalLongitudeAt and ascendantTropical: public, so the
reference tests can compare the engine against JPL DE421
without going through the chart.
AyanamshaMode: Lahiri, Raman, Krishnamurti. Raman is
Lahiri minus 1 degree 26 minutes, Krishnamurti is Lahiri
minus 6 arcminutes, both documented approximations with
their published values in the tests.
NodeMode: mean or true. True node is the Meeus mean node
plus the five periodic terms of Astronomical Algorithms
chapter 47. Checked against Skyfield: the true node at
the canonical birth is 160.61 degrees tropical by the
Moon latitude crossing, the engine true node sits within
0.5 degrees of it.

## Unknown places: the rule changed

Before this phase, a place text that matched no city fell
back to Jaipur coordinates and set placeApproximate. That
is gone. KundliCalculator.calculate now throws
ArgumentError naming the place, and the caller must show
the error and ask for a place the engine knows or for a
manual latitude and longitude. A wrong chart is worse
than no chart: Jaipur coordinates for a birth in Sydney
move the Lagna by hours. The five UI call sites catch the
error and show the honest message instead of crashing.
placeApproximate stays on KundliResult for callers, always
false now.

## Location: what exists and what does not

What exists: a 55 city Indian table with latitudes and
longitudes, matched by substring on the place text, and
AstroPlace for a manual latitude and longitude pair. The
calculation contract in lib/services/calculation.dart
takes latitude, longitude, IANA zone and location id
directly, so a place that came from geocoding never passes
through the city table at all.

What does not exist: no geocoding call, no timezone
database, and no offline city table for the world. Dart
has no IANA timezone database in the standard library,
and this app has no timezone package. That is a deliberate
boundary, not an oversight: a bundled tz database is a
large data file that needs updates when governments change
rules, and a wrong bundled table is worse than an explicit
offset the caller supplies.

## Geocoding provider plan for Web

Requirement: a Web compatible provider that turns a typed
place name into latitude, longitude and IANA timezone,
works from Flutter Web without native code, and costs
nothing at the app current volume.

Recommended: OpenStreetMap Nominatim for search plus
GeoNames for timezone, in that order.

1. Nominatim search, api at nominatim.openstreetmap.org,
   returns latitude, longitude and a place id for a typed
   name. Free, no key, usage policy asks for a real
   application name and at most one request a second.
   Limit: the usage policy forbids heavy bulk use and the
   service can be slow. Mitigation: search only when the
   user types, debounce, and cache results locally.
2. GeoNames timezoneJSON, api at geonames.org, takes the
   latitude and longitude and returns the IANA zone name
   and the current offset. Free tier needs a username and
   allows 30,000 credits a day, which covers this app.
3. The app stores the triple the user picked: latitude,
   longitude, IANA zone. It never stores only a city name
   and re resolves it later, because a re resolution can
   move the coordinates.
4. Fallback order when the network is down: cached
   places first, then the manual latitude and longitude
   form, never a guessed city. The manual form is the
   honest boundary: a user who knows their coordinates
   gets an exact chart with no network at all.

Not recommended: Google Geocoding API. Accurate and
fast, but it needs a billed API key, the key must not
ship in the app, and it needs a backend proxy to keep the
key secret. That is a backend the project does not have,
for a problem the free providers already solve.

Not built in this phase: the provider integration itself
is a UI and networking task for the phase that owns the
birth form. This phase delivers the contract it will call
(BirthInput with latitude, longitude, ianaTimezone and
locationId) and the error behaviour when the place is
unknown. No API key, token or secret is stored anywhere
in this phase.

## Historical timezone offsets and DST

India: covered by indiaUtcOffset above. No other zone is
hardcoded. Outside India the caller passes
utcOffsetMinutes for the birth date, which is the only
correct approach without a tz database: the offset on the
birth date is a fact about that date, and the caller that
resolves the zone owns it. The Phase 17 cases cover
America/New_York DST fall back on 7 November 2010, where
01:30 happens twice, and Europe/London BST start on 29
March 2026. Both are defined by their UTC instant in the
reference file, so no local time is ever ambiguous in the
test: the two New York 01:30 births are two different UTC
instants, 05:30 and 06:30, with different charts.

## Known limits

1. PanchangCalculator.forDate is India only: it subtracts
   a fixed IST offset and reads the city list. The new
   sunriseSunset and moonriseMoonset are the general
   path; the panchang must be moved onto them in a later
   phase, not silently extended here.
2. vimshottariDasha takes no place, so its pre 1906
   conversion uses the IST meridian longitude. Post 1906
   it is exact.
3. Moon latitude uses the four largest Meeus terms only,
   so moonrise and moonset carry a 15 minute tolerance.
   A full ELP lunar theory would tighten it, at the cost
   of a second lunar engine.
4. Polar days and nights: sunriseSunset clamps the hour
   angle, so a polar day returns a sunrise after its
   sunset. The caller must check that and say the Sun
   does not set, instead of showing a nonsense time.
   Moonrise and moonset return nulls in the same cases.
