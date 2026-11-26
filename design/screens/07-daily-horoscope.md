# 07 Daily Horoscope

## Purpose

Give a fresh prediction for every rashi each morning, with career, money, health, and love notes. One rashi at a time, one clear reading.

## Source

Presentation section Three, seventh phone mockup, and section Five, Free Layer.

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Daily Horoscope" in H3 serif 18. Right side: text button "Weekly" that opens the weekly view. Weekly is premium, so a free user tapping "Weekly" sees the premium upgrade screen.
2. Rashi selector, 16 below the top bar: horizontal scroll row of twelve chips, pill radius, height 36, label 14 semibold. Order: Mesha, Vrishabha, Mithuna, Karka, Simha, Kanya, Tula, Vrishchika, Dhanu, Makara, Kumbha, Meena. Selected chip is saffron fill with white text in light mode and #14100C text in dark mode. Default selected is the user rashi, Kanya for the sample user. The row scrolls, and the selected chip is always scrolled into view.
3. Hero card, 16 below the selector, padding 20, fill surface2 light and surface dark: rashi name H1 serif 28, for example "Mesha Today" when Mesha is selected, star row gold 16 with text "4 of 5", body Body 16 ink: "Energy stays high till noon. A pending payment may clear today. Avoid harsh words at home in the evening."
4. Four area cards, 12 gap, two by two grid, each standard card padding 16: label Caption 12 ink3 above value Title 17 ink. Cards: "Career", value "Strong"; "Money", value "Good"; "Health", value "Steady"; "Love", value "Warm".
5. Lucky row, two small cards side by side, 12 gap: "Lucky Number", value "5"; "Lucky Colour", value "Saffron". The lucky colour value is text only. No colour swatch fill is used, so the word stays readable in both modes.
6. Primary button, foot, full width, 24 gap above it: "Read Weekly Horoscope". Weekly is premium. A free user tapping it opens the premium upgrade screen.
7. Bottom tabs: Home, Kundli, Panchang, Consult, Profile. Horoscope is reached from Home, so back returns to Home.

## Components

• Rashi chip row, twelve chips, horizontal scroll.
• Hero horoscope card with stars.
• Four area cards in a two by two grid.
• Two lucky cards.
• Primary button for the weekly view.

## Copy

• Title: "Daily Horoscope"
• Weekly action: "Weekly"
• Hero title, sample when Mesha is selected: "Mesha Today" (Sample data)
• Hero stars: "4 of 5"
• Hero body, sample Mesha copy from the presentation: "Energy stays high till noon. A pending payment may clear today. Avoid harsh words at home in the evening."
• Area labels and sample values: "Career", "Strong"; "Money", "Good"; "Health", "Steady"; "Love", "Warm"
• Lucky labels and sample values: "Lucky Number", "5"; "Lucky Colour", "Saffron"
• Primary: "Read Weekly Horoscope"

## States

• Default: user rashi Kanya selected on open, with Kanya copy supplied by published content. The Mesha copy above is the sample shown in the presentation when Mesha is selected. No horoscope copy is written by design; all copy comes from published daily content.
• Rashi change: tapping a chip swaps the hero card, the four area cards, and the lucky cards with a 200 ms fade. No loading spinner for a cached rashi. If the rashi content is not cached, a spinner shows in the hero card only.
• Loading: hero card shows a spinner and the words "Loading todays horoscope".
• Empty: if no content is published for a rashi, the hero card shows "Todays horoscope for this rashi is not ready yet." with a text button "Try again". The area cards stay empty, never with invented values.
• Error: same empty state with a toast "Could not load the horoscope. Check your connection and try again."
• Free user: daily horoscope for all twelve rashi is free. Weekly is premium and opens the upgrade screen.
• Premium user: "Read Weekly Horoscope" opens the weekly view directly.

## Accessibility

• Rashi chips are buttons with the rashi name as the label. Selected state is announced.
• Star row is announced as "4 of 5 stars".
• Area values are text, not colour, so "Strong" and "Good" are readable without colour.

## Data and gating

• Free: daily horoscope for all twelve rashi, refreshed every morning.
• Premium: yearly and monthly horoscope with dasha based guidance, plus the weekly view.
• Sample data: the Mesha copy, the four area values, and the lucky number and colour are the presentation sample values.

## Open question

• None on layout. Weekly content structure is a content decision for the admin panel, see screen 18.
