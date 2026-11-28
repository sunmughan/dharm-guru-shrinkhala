# Astrology Library Evaluation

Date: 28 November 2026. Baseline: release 10, HEAD eb0c471.
Question: keep the existing pure Dart engine in
lib/services/astro.dart, or replace it with an external
astrology library? This document evaluates the candidates
the master instruction names, then records the decision.

## The bar a replacement must clear

A replacement must beat the current engine on accuracy,
cost nothing the project cannot pay, run on Flutter Web
without native code or a server, keep working offline, and
leave the app free to sell charts commercially. Anything
that needs a network call for every chart, a native binary,
or a licence that forces the app open source fails the bar
before accuracy is even discussed.

## Current engine, for reference

Pure Dart, no dependencies, no data files, no network.
Sun, Moon and planets from Schlyter Keplerian elements,
Lahiri ayanamsa, whole sign houses, mean lunar node.
Validated against JPL Horizons DE441 for the canonical
birth, 14 March 1998 06:25 IST Jaipur: every planet within
0.21 degrees. Re checked for this document against Skyfield
1.55 with JPL DE421: tropical Sun 353.2684 degrees against
the DE441 derived 353.27, Moon 182.4691 against 182.46,
Jupiter 339.0346 against 339.04, Saturn 19.6025 against
19.60. The two JPL editions agree to about 0.02 degrees
here, and the engine sits inside that same band. Weaknesses
are named in the code: Jupiter and Saturn can sit up to
about half a degree from a full ephemeris, and only Lahiri
and the mean node were implemented before this phase.

## Candidates

### Swiss Ephemeris

What it is: the industry standard C library from
Astrodienst, built on NASA JPL DE441 data, accurate to
about 0.001 arcseconds against the JPL data it compresses.
Accuracy: the best available, far beyond what a kundli
needs. Licence: dual. Free under GNU AGPL v3, or the Swiss
Ephemeris Professional Licence, a one time CHF 700
contract with Astrodienst AG, valid 6 years, unlimited
projects, covers server and SaaS use, no royalties. The
AGPL path forces the whole app open source: AGPL section
13 triggers on network use, so a hosted app must offer its
complete source to every user. The professional licence
avoids that but is a paper contract, must be renewed every
6 years, and forbids API services to third parties unless
each third party buys its own licence. Flutter Web: no.
It is C with data files. There is no maintained Dart port.
Running it needs a native build per platform or a server
that calls it, which breaks the offline app and adds a
backend the project does not have. Maintenance: active,
Astrodienst, decades old. Verdict: the accuracy reference,
not the runtime engine. It stays the yardstick the engine
is validated against.

### Astronomy Engine

What it is: Don Cross, MIT licence, in C, C#, JavaScript,
TypeScript, Python and Kotlin. Analytic VSOP87 plus a
Brown lunar theory, truncated to fit in about 116 KB of
minified JavaScript with no data files. Accuracy: within 1
arcminute of NOVAS by design, measured within 20
arcseconds of JPL Horizons on the Sun, Moon and planets in
independent checks. That is about 30 times tighter than
the current engine. Licence: MIT, no obligations for a
closed source commercial app. Flutter Web: there is no
Dart port. The JavaScript build could run inside a web
view or be ported, but that is a porting project with its
own validation bill, and it brings no house systems and no
ayanamsas: both would still be hand built on top. Mobile:
the Kotlin port could serve Android, but iOS would need
the C port through FFI, which is native code per platform.
Maintenance: last release 2.1.19, December 2023. Stable
but quiet. Verdict: the best fallback if the pure Dart
engine ever proves too weak. Today it is a port, not a
drop in, and its 1 arcminute buys nothing a kundli can
show: a rashi is 30 degrees wide.

### Skyfield

What it is: Brandon Rhodes, pure Python, MIT licence. It
loads official JPL ephemeris files and handles time
scales, observers and satellites with care. Accuracy: it
reads JPL DE440 and DE441 unchanged, so it agrees with
JPL Horizons to about 0.005 arcseconds. It was used to
generate the reference values for Phase 17 in this same
phase, docs/implementation/reference_cases.json. Licence:
MIT, JPL files are NASA public domain. Flutter Web: no.
It is Python. It needs NumPy and a 17 to 33 MB JPL file
downloaded at first use, and there is no Dart port. It
cannot run in the app at all. It also has no house systems
and no ayanamsas. Maintenance: active, release 1.55,
August 2026, about 718,000 downloads a month on PyPI.
Verdict: the reference tool, not the runtime engine. Its
role in this project is validation: every Phase 17 case
carries Skyfield DE421 numbers, so the Dart engine is
checked against JPL data on every CI run without Skyfield
ever shipping in the app.

### VedAstro

What it is: open source Vedic astrology, MIT licence on
GitHub, self hostable, Docker image available, Python
library on PyPI, plus a hosted REST API at 1 dollar a
month unlimited. Calculations sit on the Swiss Ephemeris,
so raw positions are Swiss Ephemeris grade, arcsecond
class, with 47 ayanamsa systems. Licence: the code is
MIT, but the calculation core is the Swiss Ephemeris,
which carries its own AGPL or professional licence
obligation. Taking the MIT wrapper does not cure the
AGPL underneath: the free path still obliges the app, and
the professional licence is still CHF 700 per 6 years.
Flutter Web: no Dart client. The hosted API needs a
network call and an API key per chart, which breaks
offline use and puts every birth detail on a third party
server. Self hosting needs a Python server. Maintenance:
active, 530 plus stars, but a one person project with a
hosted service behind it. Verdict: not usable as the app
engine. Its value here is as a cross check list: 47
ayanamsas and 684 calculations show how far the feature
surface can go, not how this app should get there.

### Drik Panchanga

What it is: an observational Indian lunisolar calendar in
Python, by Satish BD, using the Swiss Ephemeris. It
computes tithi, nakshatra, yoga, karana and vaara with end
times, plus sunrise, sunset, moonrise and moonset, and
names lunar months in amanta or purnimanta reckoning.
Accurate from 5000 BCE to 5000 CE as far as the Swiss
Ephemeris is. Licence: GNU AGPL v3, so the same open
source obligation as the Swiss Ephemeris itself, and it
inherits the Swiss Ephemeris licence too. Flutter Web:
no. Python plus pyswisseph plus .se1 data files, with a
Moshier fallback when the files are missing. No Dart
port, no house system, no divisional charts, no dasha.
Maintenance: small, single maintainer, steady but narrow.
Verdict: a panchang reference implementation, not an
engine. Its useful contribution is method: the Hindu day
runs sunrise to sunrise, and tithi and nakshatra end times
are found by bisection on the underlying longitude. The
Phase 3 time work in this phase follows that method.

## Comparison

| Library | Accuracy | Licence | Flutter Web | Data files | Houses and ayanamsa |
| --- | --- | --- | --- | --- | --- |
| Current pure Dart engine | 0.21 deg measured | none, own code | yes, pure Dart | none | yes, Lahiri, whole sign |
| Swiss Ephemeris | 0.001 arcsec | AGPL or CHF 700 per 6 years | no, C | yes | yes |
| Astronomy Engine | 1 arcmin | MIT | no Dart port | none | no |
| Skyfield | 0.005 arcsec | MIT, JPL public domain | no, Python | 17 to 33 MB | no |
| VedAstro | arcsecond class | MIT wrapper over AGPL core | no, API or Python | via Swiss Ephemeris | yes, 47 ayanamsas |
| Drik Panchanga | Swiss Ephemeris grade | AGPL | no, Python | yes | panchang only |

## Decision

Keep the existing pure Dart engine as the primary engine.
No library change. Reasons, in order:

1. Accuracy already exceeds the need. A kundli reads
   signs, houses, nakshatras and dashas. The engine is
   within 0.21 degrees of JPL on every planet; the
   tightest boundary it must respect is a nakshatra pada
   at 3 degrees 20 minutes. Only a planet within half a
   degree of a cusp can move, and the engine names that
   limit in its own comment.
2. Licence and commercial distribution. The app is a
   commercial product. The pure Dart engine carries no
   licence obligation at all. Every accurate alternative
   is either AGPL, which would force the app open source,
   or a paid contract, or a wrapper that hides an AGPL
   core. Astronomy Engine is MIT but has no Dart port.
3. Flutter Web compatibility. The app ships on Flutter
   Web. Pure Dart runs everywhere Flutter runs, offline,
   with no native build, no FFI, no server, no data file
   download. Every candidate fails this except by porting
   or by adding a backend.
4. Performance and size. The engine is a few kilobytes
   of arithmetic and answers in milliseconds. Skyfield
   needs a 17 MB JPL file; Swiss Ephemeris needs data
   files and native code; a hosted API needs a round trip
   per chart.
5. Maintenance. The engine is 953 lines the team owns
   and can read. A port of Astronomy Engine would be a
   second engine to maintain and validate, for a gain no
   user can see.

## What changes instead of a replacement

1. The engine grows the options the candidates made
   look necessary: Raman and Krishnamurti ayanamsas and
   the true node are now implemented in astro.dart, with
   published values in the tests.
2. Validation moves to JPL data without shipping JPL
   data: Phase 17 reference cases carry Skyfield DE421
   numbers, and the CI tests compare the Dart engine
   against them numerically.
3. If sub degree precision is ever needed, the documented
   upgrade path is a VSOP87 port of the planetary series
   inside the same pure Dart engine, not a library swap.
   The trigger is a real user facing error, not a
   theoretical one, and the work is a series replacement,
   not a rewrite.

## Calculation contract

The contract is implemented in
lib/services/calculation.dart, version 1.0.0.

BirthInput: date, localTime, latitude, longitude,
ianaTimezone, locationId. Optional utcOffsetMinutes.
When it is null, the engine resolves the offset only for
Asia/Kolkata; any other zone without an explicit offset
throws.

CalculationConfiguration: ephemeris, ayanamsha,
zodiacMode, houseSystem, nodeMode, calculationVersion.
Defaults: schlyter, Lahiri, sidereal, wholeSign, mean
node, 1.0.0. Only schlyter, sidereal or tropical, and
wholeSign are implemented; anything else throws instead
of returning a wrong system.

CalculationResult: utcInstant, julianDay,
planetaryPositions, ascendant, houses, nakshatras, padas,
aspects, metadata. Metadata carries engine, ayanamsa
value, node mode, place and config version, so any chart
can be reproduced from its input and its config version.

No AI astrology: no OpenAI, Gemini or other language
model call exists anywhere in this contract. Every value
is deterministic math and classical rules.
