# 09 Kundli Matching

## Purpose

Match two kundlis with guna milan score, dosha checks, and a clear match verdict in language a family can trust and share.

## Source

Presentation section Three, ninth phone mockup, and section Five, Matching Layer.

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Kundli Matching" in H3 serif 18. Right side: text button "New match" that clears the second kundli and returns to person choice.
2. Intro, Body 16 ink2, 8 below the top bar: "Milan for marriage and partnership."
3. Two person cards side by side, 12 gap, each standard card padding 16, centred: left card avatar pill 40 with initial "A", name Title 17 "Aarav", detail Body small 14 ink2 "Meena Lagna". Centre between the cards, a small saffron diamond mark 12. Right card avatar pill 40 with initial "P", name Title 17 "Priya", detail Body small 14 ink2 "Karka Lagna". Tapping a person card opens kundli choice for that side.
4. Score hero card, 16 below the person cards, padding 20, fill surface2 light and surface dark, centred: overline "Guna Milan Score" in Caption 12 semibold saffron2, score H1 serif 28 "28 / 36", verdict Title 17 semibold good green "Very Good Match".
5. Score rows card, 16 below the hero card, standard card, padding 16, three rows with dividers, each row label Title 17 ink on the left and score Body 16 ink semibold on the right:
   • "Varna", "1 / 1"
   • "Bhakoot", "7 / 7"
   • "Nadi", "8 / 8"
   • Remaining guna rows are not in the presentation. They are not invented here. The card shows only these three rows in version 1, and the full guna list is supplied by the matching engine at build time. See the open question at the foot of this file.
6. Dosha row, standard card, 12 below the score rows, padding 16: label Title 17 "Mangal Dosha" on the left, value Body 16 semibold good green "Balanced" on the right.
7. Primary button, foot, full width, 24 gap above it: "View Full Milan Report". The full report is premium. A free user tapping it opens the premium upgrade screen.
8. Footnote, 12 below the button, centred, Caption 12 ink3: "One free matching each day. The next matching is free tomorrow." The count resets daily, per the free scope.

## Components

• Two person cards with a diamond mark between them.
• Score hero card with verdict.
• Score rows card with three rows.
• Dosha row card.
• Primary button for the full report.

## Copy

• Title: "Kundli Matching"
• Intro: "Milan for marriage and partnership."
• Person left, sample data: "Aarav", "Meena Lagna"
• Person right, sample data: "Priya", "Karka Lagna"
• Score overline: "Guna Milan Score"
• Score: "28 / 36" (Sample data)
• Verdict: "Very Good Match" (Sample data)
• Score rows, sample data: "Varna", "1 / 1"; "Bhakoot", "7 / 7"; "Nadi", "8 / 8"
• Dosha: "Mangal Dosha", "Balanced" (Sample data)
• Primary: "View Full Milan Report"
• Footnote: "One free matching each day. The next matching is free tomorrow."
• New match action: "New match"

## States

• Default, both kundlis chosen: as above, with the sample score.
• One side missing: the missing person card shows a plus mark and the text "Add second kundli" in Body 16 ink2. The score hero card is hidden. The primary button is hidden. Tapping the empty card opens kundli choice.
• No kundli saved at all: the screen shows an empty state with sun mark 48, title "Create your kundli first", body "Matching needs two kundlis. Create yours to begin.", primary button "Create My Kundli".
• Free limit reached: if the user has already run one matching today, the screen shows the last result with an info strip at the top: "You have used todays free matching. The next matching is free tomorrow." The "New match" action is hidden until tomorrow. The full report button stays visible because it is a premium action.
• Loading: score hero card shows a spinner and the words "Matching the kundlis".
• Error: score hero card shows "Matching could not be completed." with a text button "Try again". The person cards stay.
• Premium user: same layout, plus the primary button opens the full milan report directly, and the footnote is hidden because the daily limit does not apply.

## Accessibility

• Score is text "28 / 36" with the verdict in words, never colour alone.
• Person cards are buttons with the person name as the label.
• The verdict uses good green plus the words "Very Good Match".

## Data and gating

• Free: one matching each day with the guna milan score.
• Premium: detailed matching with dosha analysis and a written milan report.
• Sample data: Aarav, Priya, the score, the three guna rows, and the dosha value are the presentation sample values.

## Open question

• Full guna list: the presentation shows Varna, Bhakoot, and Nadi only. Confirm the full list of guna rows and their maximum scores for the score rows card before build, so the engine and the design agree. No guna row is invented in this file.
