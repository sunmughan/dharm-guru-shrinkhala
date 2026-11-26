# Flow 01 Kundli Chart Readability

## Goal

Any user, including an elder reading on a small phone, can find lagna, rashi, and each planet in the square chart in under ten seconds, without zoom and without a legend hunt.

## Screens involved

• `screens/04-kundli-input-form.md` for the input that creates the chart
• `screens/05-kundli-chart.md` for the chart itself
• `screens/06-planet-details.md` for the full table

## Flow, step by step

1. User enters four details on the input form: name, date of birth, time of birth, place of birth. Place search fills latitude and longitude on its own.
2. User taps "Generate My Kundli". The button shows a spinner. No second tap is possible.
3. Chart screen opens on Lagna Chart. The square chart is the first large element below the top bar. The lagna cell carries a saffron diamond marker and the word "Lagna".
4. User reads the three summary chips below the chart: "Lagna Meena", "Rashi Kanya", "Nakshatra Hasta". These answer the three most common questions at once, without opening another screen.
5. User reads the planet summary list below the chips, one row per planet, in the same order as the planet details table.
6. User taps "See Planet Details" to open the full table with exact degrees and swami notes.
7. User taps back to return to the chart. The chart state, Lagna Chart or Moon Chart, is kept.

## Readability rules

• Fixed geometry: the North Indian square layout never changes. Lagna sits in the top centre diamond cell. Rashi order runs anticlockwise from lagna.
• Rashi name 13 semibold ink2 at the top of each cell. Planet abbreviations 14 semibold ink in the centre. No smaller text in the chart.
• No colour fill inside a bhava cell. No blend. The only colour in the chart is the saffron lagna marker.
• Crowded cell rule: more than three planet abbreviations in one cell shows the first three plus "+1" in Caption 12, and the full list sits in the planet summary list below the chart. Text never shrinks to fit.
• Narrow phone rule: at 320 width the chart stays square and full width. Rashi labels stay 13, planet abbreviations stay 14. Nothing is clipped.
• Text equivalent rule: the chart is a figure, so the planet summary list below it is the mandatory text equivalent. A screen reader reads "Birth kundli, Lagna Meena, Rashi Kanya, Nakshatra Hasta" followed by the planet list.
• One tap rule: the chart itself is not a tap target. The "See Planet Details" button below the chart is the tap target, height 52.

## Sample chart used in this flow

Birth 14 March 1998, 06:25 AM, Jaipur, Rajasthan. Lagna Meena, Rashi Kanya, Nakshatra Hasta. Bhava 1 Meena holds As, Su, Me, Sa. Bhava 2 Mesha holds Ma. Bhava 6 Simha holds Ra. Bhava 7 Kanya holds Mo. Bhava 11 Makara holds Ve. Bhava 12 Kumbha holds Ju, Ke. All other bhavas are empty. Surya in Meena lagna at 01° 24′.

## Failure paths

• Chart creation fails: toast "Could not create your kundli. Check your connection and try again." The entered values stay in the form.
• Chart fails to draw: chart frame shows "Your chart could not be drawn." with a text button "Try again". Summary chips stay empty.
• Moon Chart has no data: the segmented control stays, the chart frame shows "Moon chart is not ready yet." No invented Moon values are shown.

## Open question

• Moon Chart ship decision: confirm if Moon Chart ships in version 1 or in a later phase. The switcher is designed, the ship decision is open.
