# Flow 04 Remedies Flow

## Purpose

Remedies are chosen from the users own kundli, shown one per card, and tracked as a small daily habit. Nothing here promises an outcome. Every remedy carries its caution where a caution exists.

## Screens involved

• `screens/10-remedies.md` for the remedy list
• `screens/12-live-consult-chat.md` for asking an astrologer about a remedy
• `screens/05-kundli-chart.md` for the chart the remedies come from

## Flow, step by step

1. User opens Remedies from Home. The intro reads "Simple upay chosen from your own kundli."
2. If no kundli is saved, the screen shows an empty state with primary button "Create My Kundli" and the flow stops there.
3. Remedy cards appear, one idea per card, in this order: a planet remedy, a calm remedy, a gemstone note, a daily small act.
4. User reads a card and taps "Mark as done" on a daily act. The card shows a check mark and "Done today" in good green. The state resets the next morning.
5. User reads the gemstone note: "Panna suits your rashi swami Mercury. Wear it only after a full consultation." The gemstone card has no "Mark as done" button. It has "Ask about this gemstone" instead, which opens live consult.
6. User taps "Ask About a Remedy" at the foot of the screen to ask an astrologer. Live consult is premium, so a free user is taken to the premium upgrade screen first.

## Flow rules

• One idea per card. A card never mixes a mantra with a gemstone note.
• General remedies are free. The personal remedies plan is premium. A free user sees an info strip above the cards: "This is a general set. A personal plan from your own kundli is premium." with a text button "View premium".
• Done state is a daily habit check, not a claim. It resets the next morning. It never accumulates into a streak count in version 1, because no streak is in the presentation.
• Gemstone caution is permanent. The line "Wear it only after a full consultation." is never removed, never shortened, and never hidden behind a tap.
• No remedy card promises an outcome. No medical, financial, or legal claim appears on this screen or in this flow.

## Sample remedies used in this flow

For weak Sun: "Offer water to the rising sun each morning and chant Om Suryaya Namah eleven times." For Saturn calm: "Light a mustard oil diya under a peepal tree on Saturday evening." Gemstone note: "Panna suits your rashi swami Mercury. Wear it only after a full consultation." Daily small act: "Feed birds before breakfast. A tiny habit with a large blessing." All sample data from the presentation, tied to the sample kundli with Rashi swami Mercury.

## Failure paths

• No kundli: empty state as above.
• Remedies fail to load: cards area shows "Remedies could not be loaded." with a text button "Try again".
• Consult unavailable: if the user taps "Ask About a Remedy" and no astrologer is online, the consult list opens and shows who is online, rather than showing an error on the remedies screen.

## Open question

• Disclaimer: if the client wants a disclaimer line at the foot of the remedies screen, the wording must be supplied by the client. No disclaimer is invented in this design.
