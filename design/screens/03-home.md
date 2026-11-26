# 03 Home

## Purpose

Daily home base with todays horoscope, panchang snapshot, muhurat, and quick entries to every section. One open, one morning habit.

## Source

Presentation section Three, third phone mockup, and section Four, Home Wireframe.

## Layout, top to bottom

1. Top bar, height 56: left, greeting "Namaste Aarav Sharma" in Title 17 semibold ink, with the date in Caption 12 ink3 below it. Right, avatar pill 30, saffron pair fill, initial "A" in white light mode and #14100C dark mode. Tapping the avatar opens Profile.
2. Hero card, padding 20, fill surface2 light and surface dark, radius 18: overline "Today for Kanya", star row gold 16 with text "4 of 5", body "A strong day for money talks. Start new work after the morning muhurat." Tapping the card opens Daily Horoscope.
3. Row of two small cards, 12 gap, equal width:
   • Left card, label "Tithi", value "Shukla Panchami", Caption 12 ink3 label above Title 17 value.
   • Right card, label "Nakshatra", value "Rohini", same style.
   • Tapping either card opens Panchang.
4. Quick links row, four entries, 12 gap, each a square card 72 high with icon 20 on top and label 12 semibold below: "My Kundli", "Panchang", "Matching", "Remedies". Icons: chart, calendar, plus in a circle for matching, sun for remedies. Tapping opens the matching screen.
5. Muhurat strip, info strip style, radius 14, padding 12: label "Shubh Muhurat Today" in Caption 12 semibold saffron2, value "09:42 AM to 11:15 AM is best for new beginnings." in Body small 14 ink, and a text button "View" on the right that opens Panchang.
6. Consult banner, standard card, padding 16: title H3 18 "Talk to an astrologer live", body Body small 14 "Chat or call when you want a human answer." plus a text button "Consult now" that opens Consult. If the user is on the free plan, the banner shows a small premium tag "Premium" in Caption 12 saffron2. The banner itself is not a paywall; tapping it opens the consult list, and the paywall appears only when a consult is started.
7. Bottom tabs: Home active, Kundli, Panchang, Consult, Profile.

## Components

• Greeting top bar with avatar.
• Hero horoscope card, the one hero card on this screen.
• Two snapshot cards, tithi and nakshatra.
• Four quick link cards.
• Muhurat strip with View action.
• Consult banner.

## Copy

• Greeting: "Namaste Aarav Sharma" (Sample data)
• Hero overline: "Today for Kanya" (Sample data)
• Hero stars: "4 of 5"
• Hero body: "A strong day for money talks. Start new work after the morning muhurat." (Sample data, published horoscope copy)
• Tithi label: "Tithi", value: "Shukla Panchami" (Sample data)
• Nakshatra label: "Nakshatra", value: "Rohini" (Sample data)
• Quick links: "My Kundli", "Panchang", "Matching", "Remedies"
• Muhurat label: "Shubh Muhurat Today"
• Muhurat value: "09:42 AM to 11:15 AM is best for new beginnings." (Sample data)
• Muhurat action: "View"
• Consult title: "Talk to an astrologer live"
• Consult body: "Chat or call when you want a human answer."
• Consult action: "Consult now"

## States

• Default, kundli saved: as above, with the sample data shown.
• No kundli yet: hero card is replaced by a welcome card titled "Create your kundli", body "Four details are enough for a full birth chart.", primary button "Create My Kundli" that opens the input form. Tithi and nakshatra cards still show todays values. Quick links for Kundli, Matching, and Remedies are shown in a muted state and tapping any of them opens the input form first, with a toast "Create your kundli first."
• Loading: hero card shows a spinner and the words "Loading todays horoscope". Snapshot cards show a soft line2 placeholder, no shimmer blend.
• Offline: cached horoscope and panchang are shown with a small info strip at the top: "Showing saved content. Check your connection for todays update."
• Error: if todays horoscope fails to load and no cache exists, the hero card shows "Todays horoscope is not ready yet." and a text button "Try again".
• Premium user: no change to this layout except the consult banner has no premium tag.

## Accessibility

• Greeting is the screen title for screen readers.
• Star row is announced as "4 of 5 stars".
• Quick link cards are buttons with their label as the name.

## Data and gating

• Free: hero horoscope, tithi, nakshatra, muhurat strip, quick links, all visible.
• Premium: same layout. Premium depth lives on the detail screens, not on Home.
• Sample data: the name, the Kanya hero copy, tithi, nakshatra, and muhurat values are the presentation sample values. The app must label the sample kundli as sample data until real data replaces it.

## Open question

• None on layout. Notification timing and language are in the design system open questions.
