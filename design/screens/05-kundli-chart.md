# 05 Kundli Chart, North Indian Square

## Purpose

Show the birth kundli as the classic North Indian square chart that astro apps and astrologers already read with ease. The chart always looks hand drawn by an astrologer, never like a data table.

## Source

Presentation section Three, fifth phone mockup, section Four, Kundli Chart Wireframe, and section Two, "One chart pattern".

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Birth Kundli" in H3 serif 18. Right side: segmented control "Lagna Chart" and "Moon Chart", height 40. Default is Lagna Chart.
2. Chart frame, 16 below the top bar: square, full width minus 32 side padding, radius 16, 1px ink border, fill surface. Twelve bhavas in the classic North Indian square layout. Fixed geometry, never a list and never a circle.
3. Chart legend, 12 below the chart: three summary chips in a row, each a small card with label Caption 12 ink3 above value Title 17 ink: "Lagna Meena", "Rashi Kanya", "Nakshatra Hasta". Tapping a chip does nothing. They are a summary, not buttons.
4. Planet summary list, 16 below the legend: one row per planet that sits in the chart, in the same order as the planet details table. Each row shows the planet abbreviation in a 32 pill, the planet name Title 17, and the rashi and bhava in Body small 14 ink2 on the right, for example "Sun, Meena, Bhava 1". This list is the readable companion to the chart, not a repeat of the full table.
5. Primary button, foot, full width, 24 gap above it: "See Planet Details"

## Chart geometry, exact

• The square is divided by its two diagonals and by the diamond in the centre, giving twelve bhavas: four corner squares, four edge diamonds, and four centre edge triangles in the classic layout. Build it from the standard North Indian template, not from a new arrangement.
• Lagna, Meena in the sample, sits in the top centre diamond cell. The rashi order then runs anticlockwise from lagna: Mesha, Vrishabha, Mithuna, Karka, Simha, Kanya, Tula, Vrishchika, Dhanu, Makara, Kumbha, back to Meena.
• Each bhava cell shows the rashi name in 13 semibold ink2 at the top of the cell, and planet abbreviations in 14 semibold ink in the centre.
• Lagna cell carries a small saffron diamond marker, 8 size, and the word "Lagna" in saffron2 Caption 12 semibold below the rashi name.
• Planet abbreviations: As, Su, Mo, Ma, Me, Ju, Ve, Sa, Ra, Ke. "As" marks Lagna.
• No colour fill inside a bhava cell. No blend. No emoji.

## Sample chart, labelled sample data

Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan. Lagna Meena, Rashi Kanya, Nakshatra Hasta.

• Bhava 1, Meena, Lagna: As, Su, Me, Sa
• Bhava 2, Mesha: Ma
• Bhava 3, Vrishabha: empty
• Bhava 4, Mithuna: empty
• Bhava 5, Karka: empty
• Bhava 6, Simha: Ra
• Bhava 7, Kanya: Mo
• Bhava 8, Tula: empty
• Bhava 9, Vrishchika: empty
• Bhava 10, Dhanu: empty
• Bhava 11, Makara: Ve
• Bhava 12, Kumbha: Ju, Ke

## Components

• Segmented control for Lagna Chart and Moon Chart.
• Square chart frame.
• Three summary chips: Lagna, Rashi, Nakshatra.
• Planet summary list.
• Primary button "See Planet Details".

## Copy

• Title: "Birth Kundli"
• Segment labels: "Lagna Chart", "Moon Chart"
• Summary labels: "Lagna Meena", "Rashi Kanya", "Nakshatra Hasta" (Sample data)
• Primary: "See Planet Details"
• No other copy on this screen. The chart speaks for itself.

## States

• Default, Lagna Chart: as above.
• Moon Chart selected: same geometry, planets placed by Moon sign. The summary chips change to show Moon based values supplied by the chart engine. No values are invented in this spec; the engine supplies them.
• Crowded cell: if a cell would hold more than three planet abbreviations, the cell shows the first three and "+1" in Caption 12, and the full list sits in the planet summary list below the chart. The chart never shrinks its text to fit.
• Narrow phone, 320 width: chart stays square and full width. Rashi labels stay 13, planet abbreviations stay 14. Nothing is clipped.
• Loading: chart frame shows a spinner and the words "Loading your chart".
• Error: chart frame shows "Your chart could not be drawn." with a text button "Try again". The summary chips stay empty.
• Premium lock: the chart itself is free. No lock appears on this screen. Full planet degrees are premium and the lock lives on the planet details screen, not here.

## Accessibility

• The chart is a figure, so a text equivalent is mandatory. The planet summary list below the chart is that equivalent, and a screen reader reads the chart as "Birth kundli, Lagna Meena, Rashi Kanya, Nakshatra Hasta" followed by the planet list.
• Rashi names are text, never images, so they scale with dynamic type.
• The chart is not a tap target. The "See Planet Details" button is the tap target.

## Data and gating

• Free: basic kundli with lagna, rashi, nakshatra, and the square chart.
• Premium: full planet detail with exact degrees, bhava reading, and swami analysis, reached from this screen.
• Sample data: the whole chart above is the presentation sample kundli.

## Open question

• Moon Chart: confirm if Moon Chart ships in version 1 or in a later phase. The switcher is in the wireframe, so the control is designed, but the ship decision is open.
