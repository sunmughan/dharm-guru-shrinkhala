# 06 Planet Details

## Purpose

Show position, rashi, bhava, and exact degree of every graha, with the swami of lagna, rashi, and nakshatra. This is the depth layer of the kundli.

## Source

Presentation section Three, sixth phone mockup.

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Planet Details" in H3 serif 18. No right action.
2. Intro, Body 16 ink2, 8 below the top bar: "Position, rashi, bhava and exact degree of every graha."
3. Table card, 16 below the intro, standard card, padding 0, radius 18, overflow hidden: header row plus nine planet rows. Header row fill surface2, labels Caption 12 semibold ink3: "Planet", "Rashi", "Bhava", "Degree". Each planet row is 52 high, divider 1px line, planet name Title 17 ink on the left, rashi Body 16 ink, bhava Body 16 ink centred, degree Body 16 ink semibold on the right.
4. Swami notes card, 16 below the table, standard card, padding 16: title H3 18 "Swami notes", then three rows, each with label Caption 12 ink3 above value Body 16 ink: "Lagna swami is Jupiter.", "Rashi swami is Mercury.", "Nakshatra swami is Moon."
5. Premium note, only for free users, info strip style below the swami card: "Full planet detail is a premium feature. Your basic chart stays free." with a text button "View premium" that opens the premium upgrade screen.
6. No bottom tabs on this screen. It is a detail screen reached from the chart, with back navigation only.

## Sample table, labelled sample data

Birth 14 March 1998, Jaipur. Surya in Meena lagna at 01° 24′.

• Sun, Meena, Bhava 1, 01° 24′
• Moon, Kanya, Bhava 7, 19° 08′
• Mars, Mesha, Bhava 2, 14° 52′
• Mercury, Meena, Bhava 1, 16° 37′
• Jupiter, Kumbha, Bhava 12, 22° 05′
• Venus, Makara, Bhava 11, 09° 41′
• Saturn, Meena, Bhava 1, 24° 18′
• Rahu, Simha, Bhava 6, 11° 30′
• Ketu, Kumbha, Bhava 12, 11° 30′

## Components

• Planet table with four columns.
• Swami notes card with three rows.
• Premium note strip for free users only.

## Copy

• Title: "Planet Details"
• Intro: "Position, rashi, bhava and exact degree of every graha."
• Table headers: "Planet", "Rashi", "Bhava", "Degree"
• Swami title: "Swami notes"
• Swami rows: "Lagna swami is Jupiter.", "Rashi swami is Mercury.", "Nakshatra swami is Moon."
• Premium note: "Full planet detail is a premium feature. Your basic chart stays free."
• Premium action: "View premium"

## States

• Default, premium user: full table and swami notes, no premium note strip.
• Free user: the table is shown in full in this draft, because the presentation shows the full table as the screen. The premium gate is the note strip plus the upgrade action, and the full lock decision is open, see the foot of this file. Do not lock the table without client approval, because the presentation shows it open.
• Loading: table card shows a spinner and the words "Loading planet details".
• Error: table card shows "Planet details could not be loaded." with a text button "Try again".
• Empty: not possible for a saved kundli. If no kundli exists, this screen is not reachable, and the user is sent to the input form.

## Accessibility

• The table is a real table with header labels, so a screen reader reads each row as "Sun, Meena, Bhava 1, 01 degrees 24 minutes".
• Degree text uses the degree sign and the prime mark, with a text equivalent in the accessible label.
• Row height 52 keeps each row a comfortable tap target if rows become tappable later. In version 1 rows are not tappable.

## Data and gating

• Premium: full planet detail with exact degrees, bhava reading, and swami analysis is listed as premium in the presentation features layer.
• Free: basic kundli with lagna, rashi, nakshatra, and the square chart.
• Sample data: the whole table above is the presentation sample kundli. No other planet data is shown anywhere.

## Open question

• Lock behaviour: confirm whether free users see the full table with a premium note, as drawn here, or see the degrees hidden behind the paywall. The presentation lists planet detail as premium but shows the full table in the mockup, so the client must settle this before build.
