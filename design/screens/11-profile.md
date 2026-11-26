# 11 Profile

## Purpose

Personal hub with birth summary, age details, saved kundlis, plan status, and alert settings. One place to see who the account is and what it holds.

## Source

Presentation section Three, eleventh phone mockup.

## Layout, top to bottom

1. Top bar: title "Profile" in H3 serif 18 on the left. Right side: text button "Edit" that opens the kundli input form with saved values filled in.
2. Identity card, standard card, padding 16, 16 below the top bar: avatar pill 48 with initial "A" on the left, name Title 17 semibold "Aarav Sharma" and detail Body small 14 ink2 "Meena Lagna, Kanya Rashi, Hasta Nakshatra" to the right of the avatar.
3. Birth summary card, standard card, padding 16, 12 gap: rows with dividers, label Caption 12 ink3 above value Body 16 ink:
   • "Born", "14 March 1998, Jaipur"
   • "Age", "28 years 8 months"
   • "Tithi at Birth", "Krishna Dwitiya"
4. Plan card, standard card, padding 16, 12 gap: row with label Title 17 "Plan" on the left and a status pill "Premium" in good green on the right. Below, Body small 14 ink2: "Premium pricing is to be decided." For a free user the pill reads "Free" in saffron2 and the body reads "Daily horoscope, panchang, and one matching each day are free." plus a text button "View premium" that opens the premium upgrade screen.
5. Saved kundlis card, standard card, padding 16, 12 gap: row with label Title 17 "Saved Kundlis" on the left and value Title 17 "4" on the right. Body small 14 ink2 below: "Family charts saved for quick matching and reading." Text button "View saved kundlis" opens the saved list. The saved list itself is a simple list screen built from this system: each row shows a name, lagna and rashi, and a chevron. No extra design is needed beyond that list pattern.
6. Alerts card, standard card, padding 16, 12 gap: row with label Title 17 "Daily Alerts" on the left and a switch on the right, on state saffron, off state line2. Below, Body small 14 ink2: "Horoscope at 06:00 AM and muhurat alerts on festival days." The switch controls all daily alerts. Tapping the body text opens Notifications for per alert control.
7. Account rows, standard card, padding 0, 12 gap, rows 52 high with dividers: "Edit Birth Details" with a chevron, "Notification settings" with a chevron, "Help and support" with a chevron, "Sign out" in maroon text with no chevron. Each row is a button.
8. Footnote, 24 below the last card, centred, Caption 12 ink3: "Dharm Guru Shrinkhala. Pricing to be decided."
9. Bottom tabs: Profile active, Home, Kundli, Panchang, Consult.

## Components

• Identity card with avatar.
• Birth summary card with three rows.
• Plan card with status pill.
• Saved kundlis card.
• Alerts card with switch.
• Account rows card.

## Copy

All personal values below are sample data from the presentation.

• Title: "Profile"
• Edit action: "Edit"
• Name: "Aarav Sharma"
• Detail: "Meena Lagna, Kanya Rashi, Hasta Nakshatra"
• "Born", "14 March 1998, Jaipur"
• "Age", "28 years 8 months"
• "Tithi at Birth", "Krishna Dwitiya"
• "Plan", "Premium"
• Premium note: "Premium pricing is to be decided."
• Free note: "Daily horoscope, panchang, and one matching each day are free."
• Free action: "View premium"
• "Saved Kundlis", "4"
• Saved body: "Family charts saved for quick matching and reading."
• Saved action: "View saved kundlis"
• "Daily Alerts"
• Alerts body: "Horoscope at 06:00 AM and muhurat alerts on festival days."
• Account rows: "Edit Birth Details", "Notification settings", "Help and support", "Sign out"
• Footnote: "Dharm Guru Shrinkhala. Pricing to be decided."

## States

• Default, premium sample user: as above, plan pill "Premium", saved kundlis 4.
• Free user: plan pill "Free", free note and "View premium" action, saved kundlis 1, and the saved list shows the limit note "One saved kundli on the free plan. Premium saves unlimited family kundlis."
• Alerts off: switch off, alerts body stays, and a small info strip appears: "Daily alerts are off. Turn them on to get the morning horoscope."
• No kundli yet: identity card shows the account name only, birth summary card is replaced by an empty state with primary button "Create My Kundli", saved kundlis shows 0.
• Loading: cards show a soft line2 placeholder.
• Error: cards show "Profile could not be loaded." with a text button "Try again".
• Sign out: tapping "Sign out" opens a confirm dialog: title "Sign out?", body "Your saved kundlis stay in your account.", actions "Cancel" as text button and "Sign out" as maroon text button. No destructive filled button.

## Accessibility

• Switch has the label "Daily Alerts" and announces on and off.
• Status pill has the word "Premium" or "Free", never colour alone.
• Account rows are buttons with their label as the name.

## Data and gating

• Free: one saved kundli, daily alerts, free plan card.
• Premium: unlimited saved family kundlis, personal muhurat alerts, priority support.
• Sample data: name, birth summary, age, tithi at birth, plan, saved count 4, and alert time are the presentation sample values. Age is shown exactly as in the presentation, 28 years 8 months.

## Open question

• None on layout. The saved kundli list and the help screen are simple list screens built from this system and need no separate spec.
