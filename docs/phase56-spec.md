# Dharm Guru Phase 5 and 6 Specification

Panchang extras and the advanced engine. All values are computed
from the engine in `lib/services/astro.dart` (Schlyter Sun, Moon
and planets, Lahiri ayanamsa, JPL Horizons DE441 validated).
No AI prediction, no dummy data, no stored annual tables.

## 1. Phase 5 Panchang extras (`lib/services/panchang_extra.dart`)

### Daily timings

Rahu Kaal, Yamaganda and Gulika are 1.5 hour parts counted
from sunrise, Monday first. Rahu Kaal parts are
1, 6, 4, 5, 3, 2, 7. Yamaganda parts are 3, 2, 1, 0, 6, 5, 4.
Gulika parts are 5, 4, 3, 2, 1, 0, 6. Source: the standard
Kala Velai weekday tables. Brahma Muhurat is 96 to 48 minutes
before sunrise. Choghadiya splits the day and the night into
8 equal parts each. Day lords start Monday Amrit, Tuesday Kaal,
Wednesday Labh, Thursday Shubh, Friday Char, Saturday Rog,
Sunday Udveg, cycling Udveg, Char, Labh, Amrit, Kaal, Shubh, Rog.
Good segments are Shubh, Labh and Amrit. Night segments continue
the cycle after the 8 day segments.

Moonrise and moonset come from a 10 minute altitude scan of
the Moon over the local date, using the ecliptic longitude
from the engine. Lunar latitude is left out, so the result
is approximate within about 20 minutes and the UI labels it
approximate. An event that does not fall on the date is null,
and the UI says so.

### Paksha and lunar month

Tithi number is elongation divided by 12 plus 1, at local
noon for paksha. 1 to 15 is Shukla, 16 to 30 is Krishna,
30 is Amavasya. The lunar month is named from the Sun sign
at the month Purnima: the full Moon sits in the nakshatra
the month is named after, and the Sun sits opposite it, so
Meena Sun means Chaitra, Mesha Sun means Vaishakha, and so
on round the year. Amanta reads the Purnima in the middle
of the month, so a Shukla date reads the coming Purnima
and a Krishna date reads the Purnima just passed.
Purnimanta ends the month on its Purnima, so every date
reads the coming Purnima. The two agree in Shukla paksha
and differ by one month in Krishna paksha. Configuration:
`PanchangSettings` with `LunarConvention.amanta` or
`LunarConvention.purnimanta`; the app shows both names.

### Adhika Masa

A lunar month is Amavasya to Amavasya. It is Adhika when
no sankranti (Sun sign change) falls strictly inside it.
New moon and full moon moments are found by scanning the
elongation in 6 hour steps and bisecting to the minute.
Sankranti moments are found the same way from the Sun
longitude. 2026 has one: Adhik Jyeshtha, 17 May to 15 June.
2025 has none. Kshaya Masa (two sankrantis in one lunar
month) is not implemented; no year in the test range has
one, and it is listed under remaining work.

### Test datasets

`test/panchang_extra_test.dart`. Weekday tables checked as
offsets from sunrise for Monday 30 November 2026 and Sunday
29 November 2026. Full moon 24 November 2026 moonrise near
sunset, new moon 8 December 2026 moonrise near sunrise.
Paksha and month checks on 5, 8, 10 and 23 December 2026.
Adhika checks for 2026 and 2025. Regression: every day of
December 2026 has no Krishna Purnima, and 8 December 2026
is Krishna Amavasya.

## 2. Festival engine (`lib/services/festivals.dart`)

A festival is a rule: lunar month, paksha, tithi number,
and the moment of the day its tithi is read at. The scan
walks every day of the year and keeps the days that match.
Diwali is Kartika Krishna Amavasya at sunset. Holi is
Phalguna Shukla Purnima at sunrise. Raksha Bandhan is
Shravana Shukla Purnima at sunrise. Janmashtami is Shravana
Krishna Ashtami at midnight. Ram Navami is Chaitra Shukla
Navami at noon. Hanuman Jayanti is Chaitra Shukla Purnima
at sunrise. Maha Shivratri is Magha Krishna Chaturdashi at
sunset; in Purnimanta counting this is Phalguna Krishna
Chaturdashi. Ganesh Chaturthi is Bhadrapada Shukla
Chaturthi at noon. Dussehra is Ashwin Shukla Dashami in the
afternoon. Chaitra Navratri begins on Chaitra Shukla
Pratipada at sunrise. Shardiya Navratri begins on Ashwin
Shukla Pratipada at sunrise. Makar Sankranti is solar: the
day the sidereal Sun enters Makara, from the bisected
ingress moment. Every result carries its rule and source.

Limit: the tithi is read at one fixed moment per festival.
A tithi that starts minutes after that moment can move a
festival by a day against a published panchang. Tests allow
one day either side, except Makar Sankranti, which is exact.

### Test datasets

`test/festivals_test.dart`. All 2026 dates checked against
published 2026 dates. Diwali 2026 and Diwali 2027 differ,
proving the dates are computed, not stored.

## 3. Muhurat engine (`lib/services/muhurat.dart`)

Purposes: marriage, Griha Pravesh, vehicle purchase,
business opening, travel, naming ceremony. Day rules: Rikta
tithis (4, 9, 14) and Amavasya (30) avoided for beginnings;
yogas Vyatipata and Vaidhriti avoided, with Atiganda, Ganda
and Shula also avoided for marriage; Vishti karana avoided;
marriage also avoids Bharani and Krittika nakshatra;
Griha Pravesh needs Shukla paksha. Windows inside a good
day are Abhijit and the good Choghadiya segments, with any
window overlapping Rahu Kaal, Yamaganda or Gulika cut out.
Every window lists the rules applied with the values they
were checked against, and the inputs: place, coordinates,
date, tithi, nakshatra, yoga, karana, sunrise, sunset,
ayanamsa. At most 10 windows, earliest first.

Limit: tithi, yoga, karana and nakshatra are read at local
noon. A tithi that changes near noon can admit or reject a
day a full span check would judge the other way.

### Test datasets

`test/muhurat_test.dart`. Marriage windows in 60 days from
28 November 2026 carry rules and inputs and never overlap
an inauspicious window. Griha Pravesh windows all fall in
Shukla paksha. Every purpose finds a window in 90 days.

## 4. Vimshottari sub dashas (`lib/services/dasha_detail.dart`)

Antardasha, Pratyantardasha and Sookshma Dasha split the
parent span in proportion to the Vimshottari years: a sub
lord with Y years takes Y divided by 120 of the parent
span, in the same cycle order as the Mahadasha, starting
with the parent lord. Source: the Vimshottari proportional
rule in Brihat Parashara Hora Shastra. Spans are cut in
whole days; the last part ends where the parent ends, so
the parts always add up to the whole within one day.

### Test datasets

`test/dasha_detail_test.dart`. Sample birth 14 March 1998.
Antardashas cover the Mahadasha exactly, in order, first
lord equal to the Mahadasha lord. Current levels nest
inside each other and hold the date.

## 5. Gochar (`lib/services/gochar.dart`)

Transit positions come from `siderealLongitudes` at local
noon IST on the chosen date, against the natal chart from
`KundliCalculator`. Any date works: past, current or future.
Each result names the transit sign and degree, the natal
sign and house, and the house from lagna. Sade Sati is
Saturn in the Moon sign (peak), the sign before it
(rising), or the sign after it (setting). Dhaiya is Saturn
in the 4th or 8th sign from the Moon.

### Test datasets

`test/gochar_test.dart`. Saturn around the Kanya Moon gives
rising, peak and setting; 4th and 8th give Dhaiya. On
28 November 2026 Saturn transits Meena, Bhava 2 from
Kumbha lagna, no Sade Sati. On 15 January 2007 Sade Sati
is rising.

## 6. Strengths (`lib/services/strengths.dart`)

Shadbala here is a simplified three part strength, labelled
as such in every result: Sthana (exalted 100, own 80,
friendly 60, neutral 50, enemy 30, debilitated 10),
Dig Bala (100 in the directional house, else 50), Kaala Bala
(day or night birth, Mercury 80 always). Total 0 to 300.
The full classical Shadbala has six balas and is not
claimed here. Ashtakavarga is the full classical system:
the bindu tables of Brihat Jataka IX.1 to IX.7, with the
lagna as the eighth contributor. Fixed totals are Sun 48,
Moon 49, Mars 39, Mercury 54, Jupiter 56, Venus 52,
Saturn 39, sarvashtakavarga 337. Bhava Bala is simplified:
lord Sthana Bala plus 10 per planet in the house.

### Test datasets

`test/strengths_test.dart`. Ashtakavarga totals asserted
exactly for two charts, sarva 337 both times. Shadbala Sun
180 and Moon 170 for the sample birth, from the stated
parts. Bhava Bala houses 1 and 2 scored from lord and
occupants.

## 7. Yogas and doshas (`lib/services/yogas_doshas.dart`)

Raj Yoga: a kendra lord and a trikona lord in the same sign
or in mutual exchange. Dhana Yoga: lords of the 2nd, 5th,
9th and 11th houses in the same sign or in mutual exchange.
Mangal Dosha: Mars in houses 1, 2, 4, 7, 8 or 12 from lagna,
from the Moon, or from Venus; Mars in own or exalted sign
cancels it. Kaal Sarp Dosha: all seven visible planets on
one side of the Rahu Ketu axis. Source: the classical yoga
and dosha rules in Brihat Parashara Hora Shastra. Every
result states which planets and houses were checked.

### Test datasets

`test/yogas_doshas_test.dart`. Sample birth gives 3 Raj
Yogas and no Dhana Yoga. Mangal Dosha shows from lagna and
Moon and cancels because Mars is in Meena, its own sign.
No Kaal Sarp Dosha for the sample chart.

## 8. Other systems (`lib/services/other_systems.dart`)

Jaimini, KP and Lal Kitab are evaluated, not implemented:
each entry states what the system needs, what the app
already computes, what is missing, and the verdict. No
system borrows rules from another. Western is partially
available: tropical signs of the seven visible planets and
the tropical ascendant, from the tropical longitudes the
engine already produces. No Western house or aspect reading
is mixed into the Vedic chart.

### Test datasets

`test/other_systems_test.dart`. Four evaluations, each with
needs, gaps and verdict. Western Sun Pisces and Moon Libra
for the sample birth.

## 9. UI integration

Panchang screen shows a Daily timings card: Yamaganda,
Gulika, Brahma Muhurat, moonrise and moonset (labelled
approximate), paksha, lunar month under Amanta and
Purnimanta, Adhika Masa note, and the good Choghadiya
segments. Library screen shows the current Antardasha
under the current Mahadasha, and the festival dialog shows
the festival rule and source when the engine supplies one.
The muhurat engine, gochar, strengths, yogas and doshas
have no dedicated screen yet; that is listed under
remaining work. No new screen was added, to keep this
change to the screens that already show this data.

## 10. Firebase changes

None. No new collection, no rule change, no document
shape change. The Panchang screen still reads the admin
published panchang document when one exists for the date,
and the computed values otherwise.

## 11. Known limits

1. Moonrise and moonset leave out lunar latitude, so they
   run within about 20 minutes of a full ephemeris.
2. Festival dates can sit one day from a published
   panchang when a tithi starts just after the observance
   moment.
3. Muhurat days are judged from the tithi, yoga, karana
   and nakshatra at local noon, not from their full spans.
4. Shadbala and Bhava Bala are simplified and labelled so;
   the full classical Shadbala is not implemented.
5. Kshaya Masa detection is not implemented.
6. Jaimini, KP and Lal Kitab are evaluated only, not
   computed.
7. Planetary longitudes use mean elements without the
   small perturbation terms, as the base engine already
   notes; Jupiter and Saturn can sit up to about half a
   degree from a full ephemeris.
