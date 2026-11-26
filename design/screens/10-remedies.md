# 10 Remedies

## Purpose

Show simple upay chosen from the users own kundli: mantra, daan, fasting, and gemstone guidance mapped to weak or strong planets in the personal chart.

## Source

Presentation section Three, tenth phone mockup, and section Five, Remedies Layer.

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Your Remedies" in H3 serif 18. No right action.
2. Intro, Body 16 ink2, 8 below the top bar: "Simple upay chosen from your own kundli."
3. Remedy cards, 12 gap, one card per remedy, standard card, padding 16:
   • Card 1, title H3 18 "For weak Sun", body Body 16 ink "Offer water to the rising sun each morning and chant Om Suryaya Namah eleven times."
   • Card 2, title H3 18 "For Saturn calm", body Body 16 ink "Light a mustard oil diya under a peepal tree on Saturday evening."
   • Card 3, title H3 18 "Gemstone note", body Body 16 ink "Panna suits your rashi swami Mercury. Wear it only after a full consultation."
   • Card 4, title H3 18 "Daily small act", body Body 16 ink "Feed birds before breakfast. A tiny habit with a large blessing."
   • Each card has a text button on its foot, 12 below the body: card 1 and card 2 use "Mark as done", card 3 uses "Ask about this gemstone", card 4 uses "Mark as done". "Mark as done" is a daily habit check, not a medical or financial claim. Tapping it shows a check mark and the words "Done today" in good green, and it resets the next morning.
4. Primary button, foot, full width, 24 gap above the last card: "Ask About a Remedy". Tapping it opens live consult, so the user can ask an astrologer. If the user is on the free plan, tapping it opens the premium upgrade screen first, because live consult is premium.
5. Bottom tabs: Home, Kundli, Panchang, Consult, Profile. Remedies is reached from Home, so back returns to Home.

## Components

• Four remedy cards, one idea per card.
• Daily done state on cards 1, 2, and 4.
• Primary button to ask an astrologer.

## Copy

All remedy copy below is sample data from the presentation, tied to the sample kundli.

• Title: "Your Remedies"
• Intro: "Simple upay chosen from your own kundli."
• Card 1 title: "For weak Sun"
• Card 1 body: "Offer water to the rising sun each morning and chant Om Suryaya Namah eleven times."
• Card 2 title: "For Saturn calm"
• Card 2 body: "Light a mustard oil diya under a peepal tree on Saturday evening."
• Card 3 title: "Gemstone note"
• Card 3 body: "Panna suits your rashi swami Mercury. Wear it only after a full consultation."
• Card 4 title: "Daily small act"
• Card 4 body: "Feed birds before breakfast. A tiny habit with a large blessing."
• Done action: "Mark as done"
• Done state: "Done today"
• Gemstone action: "Ask about this gemstone"
• Primary: "Ask About a Remedy"

## States

• Default, kundli saved: four cards as above.
• Done today: the tapped card shows a check mark in good green and the words "Done today". The button is replaced by the done state. The state resets the next morning.
• No kundli yet: empty state with sun mark 48, title "Create your kundli first", body "Remedies are chosen from your own chart. Create your kundli to see yours.", primary button "Create My Kundli".
• Free user: general remedies for common planetary periods are free. The four cards above are the general sample set. The personal remedies plan is premium, and a free user sees an info strip above the cards: "This is a general set. A personal plan from your own kundli is premium." with a text button "View premium".
• Premium user: no info strip. The cards are the personal plan from the users own kundli, supplied by the remedies engine. No extra card is invented here.
• Loading: cards show a spinner and the words "Loading your remedies".
• Error: cards area shows "Remedies could not be loaded." with a text button "Try again".

## Accessibility

• Remedy titles are serif H3, body is Body 16, so long reading stays comfortable.
• Done state is a check mark plus the words "Done today", never colour alone.
• Gemstone card always carries the caution "Wear it only after a full consultation." That line is never removed.

## Data and gating

• Free: general remedies for common planetary periods.
• Premium: personal remedies plan built from the users own kundli.
• Sample data: all four remedy cards are the presentation sample values for the sample kundli. No remedy is invented.

## Safety note

• Remedies are guidance only. No remedy card promises an outcome. No medical, financial, or legal claim appears on this screen. If the client wants a disclaimer line, add it as a footnote in Caption 12 ink3 at the foot of the screen, with wording supplied by the client. No disclaimer is invented in this file.
