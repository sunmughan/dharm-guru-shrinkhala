# Flow 03 Matching Flow

## Goal

Two kundlis go in, one clear verdict comes out, in language a family can trust and share. The score is never shown without the verdict, and the verdict is never shown without the score breakdown.

## Screens involved

• `screens/09-kundli-matching.md` for the match itself
• `screens/14-premium-upgrade.md` for the full report gate
• `screens/11-profile.md` for saved kundlis

## Flow, step by step

1. User opens Matching from Home or from the quick links row. The screen title is "Kundli Matching" and the intro reads "Milan for marriage and partnership."
2. Left person card shows the users own kundli, Aarav, Meena Lagna in the sample. If no kundli is saved, the screen shows an empty state with primary button "Create My Kundli" and the flow stops there.
3. User taps the right person card, "Add second kundli", and chooses a saved kundli or creates a new one from the input form. In the sample the second person is Priya, Karka Lagna.
4. Both cards filled: the score hero card appears with "Guna Milan Score", "28 / 36", and the verdict "Very Good Match".
5. Below the hero card, the score rows card shows Varna "1 / 1", Bhakoot "7 / 7", Nadi "8 / 8". Below that, the dosha card shows Mangal Dosha "Balanced".
6. User taps "View Full Milan Report". The full report is premium. A free user is taken to the premium upgrade screen. A premium user opens the full report directly.
7. User taps "New match" to clear the second kundli and start again. The first kundli stays.

## Flow rules

• One free matching each day. The count is shown in the footnote: "One free matching each day. The next matching is free tomorrow." After the free matching is used, the screen shows the last result with an info strip "You have used todays free matching. The next matching is free tomorrow." and the "New match" action is hidden until tomorrow.
• Score and verdict always appear together. A score without a verdict is a design fault.
• Guna rows shown are only the rows the matching engine supplies. In version 1 the presentation shows Varna, Bhakoot, and Nadi only. No other guna row is invented in the design.
• Dosha is shown as a word, "Balanced", in good green, never as a colour alone and never as a bare number.
• The full report is the premium depth. The free screen never hides the score to force an upgrade. The score is free. The written report is premium.

## Sample match used in this flow

Aarav, Meena Lagna, and Priya, Karka Lagna. Score 28 / 36. Verdict Very Good Match. Varna 1 / 1. Bhakoot 7 / 7. Nadi 8 / 8. Mangal Dosha Balanced. All sample data from the presentation.

## Failure paths

• One side missing: score hero card and primary button stay hidden. The empty card reads "Add second kundli".
• Matching fails: score hero card shows "Matching could not be completed." with a text button "Try again". Person cards stay.
• Free limit reached: as above, last result stays visible, new match hidden until tomorrow.
• Full report fails to load for a premium user: toast "Could not load the report. Try again." and the user stays on the matching screen.

## Open question

• Full guna list: confirm the full list of guna rows and their maximum scores before build, so the engine and the design agree. The presentation shows Varna, Bhakoot, and Nadi only.
