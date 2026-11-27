# PDF evaluation, Phase 11

## Choice

`pdf` 3.13.1 plus `printing` 5.15.0, both from pub.dev.
`printing` 5.15.0 requires `pdf` ^3.13.0 and Flutter
>=3.41.0, and this repo needs Flutter >=3.47.0, so the pair
resolves cleanly.

## Why this pair

`pdf` is a pure Dart producer: it builds the document with
no platform code, so the same builder runs on web and on
native. It supports TrueType fonts, vector graphics, tables
and `MultiPage`, which flows content across pages by itself
and gives a header and footer per page. `printing` adds the
share and print step: `sharePdf` downloads the file on web
and opens the share sheet on native, and `layoutPdf` opens
the system print dialog. No other package was needed.

## Alternatives considered

`dart_pdf_printing` 0.11.0 was checked and rejected: it is
new, it needs its own editor package for the full flow, and
it adds nothing this report needs. A server side PDF was
rejected too: there is no trusted backend yet, and the
report must work offline from data already on the device.

## What the report contains

Built only from `KundliReportData`, which comes from the
birth details the user entered and the kundli the engine
calculated:

* User and birth details: name, date, time, place, Moon
  rashi, nakshatra, tithi at birth.
* Calculation configuration: place used with latitude and
  longitude, Lahiri ayanamsa, chart kind, lagna, and plain
  notes when the place or the time was approximate.
* Chart diagram: the North Indian square chart, same bhava
  grid as the on screen chart, with rashi names and planet
  abbreviations in each bhava.
* Planetary positions: a table with planet, rashi, bhava,
  degree and lord for all 9 planets.
* Required explanations: one factual line per planet from
  the engine output, plus the lagna, Moon and tithi lines.
  These are positions, not predictions. No AI text anywhere.
* Report generation date and report version on every page
  footer, plus page numbers.
* Proper pagination: `MultiPage` with A4 pages. The sample
  chart paginates to 2 pages, proved in `test/phase11_test.dart`.

## Fonts

Roboto Regular and Bold from the google/roboto repository,
Apache 2.0, bundled in `assets/fonts` and embedded in every
report with `Font.ttf`. No font is downloaded at open time,
so the report reads the same on any reader.

## Verification

`flutter test` builds the report from the real birth 14
March 1998 06:25 Jaipur and asserts the PDF header, the
page count, the embedded font build, and the content with
the standard font build. `flutter build web` and the APK
and iOS jobs in CI prove the `printing` plugin compiles on
web, Android and iOS. Real device download and print are
still open: they need the phone proof step, like every
release before this one.
