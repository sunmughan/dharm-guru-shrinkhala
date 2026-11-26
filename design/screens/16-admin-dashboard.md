# 16 Admin Dashboard

## Purpose

Give the owner one calm view of the day: users, kundlis created, consult minutes, and earnings, with a clear path to each admin task. This is a web admin panel, not a phone screen.

## Source

Presentation section Six, "What the team runs", and section Seven, Owner Scope, analytics and revenue, plus Remote Config feature control.

## Layout, desktop, left to right

1. Left rail, 240 wide, fill surface, full height: top, sun mark 32 plus "Dharm Guru" in serif 18, then nav items in fixed order, each 44 high, icon 20 plus label 15 semibold: "Dashboard" active, "Astrologers", "Daily Content", "Subscriptions", "Analytics", "Notifications", "Moderation". Active item has a 3px saffron bar on its left edge and saffron text. Inactive items are ink2. Foot of the rail: "Admin" in Caption 12 ink3, plus a text button "Sign out" in maroon.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Dashboard", date line Body 16 ink2 "Today", with a date picker on the right for the range. The range control is a segmented control: "Today", "7 days", "30 days". Default is "Today".
3. Four stat cards in a row, 16 gap, each standard card padding 20: label Caption 12 semibold ink3 above value H2 serif 22 in ink, plus a small change line Body small 14 ink2 below, for example "Daily users", value shown as a number from Analytics, change "Up from yesterday" in text only, no invented figure in this spec. Cards: "Daily users", "Kundlis created", "Consult minutes", "Earnings". Earnings value shows the currency and amount from the payments system. No amount is invented in this spec. If no payment has been taken yet, the card shows "No payments yet" in Body small 14 ink3, never a zero with a currency that implies a price.
4. Two column area, 16 gap, below the stat cards:
   • Left column, wide: chart card titled "Kundlis created" with a simple line chart in saffron on a surface card, axes in Caption 12 ink3, no blend fill under the line. The chart shows the selected range.
   • Right column, narrow: "Needs attention" card, a list of up to five rows, each a text button row: astrologer profiles waiting for approval, content waiting for review, user reports waiting for moderation. Each row shows a count from the system and a chevron. If nothing needs attention, the card shows "All clear. Nothing needs attention."
5. Quick actions row, 16 below the two column area: four secondary buttons in a row: "Publish todays horoscope", "Add astrologer", "Send notification", "Review reports". Each opens the matching admin screen.
6. Feature control card, 16 below the quick actions: title H3 18 "Feature control", body Body small 14 ink2 "Turn features on or off with Remote Config without shipping an app update.", then switch rows for the features controlled by Remote Config. The exact feature list is supplied by the build, not invented here. Each row shows the feature name Title 17 and a switch.

## Layout, narrow screen

• Left rail becomes a top bar with a menu button. Tapping it opens the nav as a sheet.
• Stat cards stack two by two, then one by one on the narrowest width.
• Two column area stacks, chart first, needs attention second.

## Components

• Left rail navigation, fixed order.
• Range segmented control.
• Four stat cards.
• Line chart card.
• Needs attention card.
• Quick actions row.
• Feature control card with switches.

## Copy

• Title: "Dashboard"
• Nav: "Dashboard", "Astrologers", "Daily Content", "Subscriptions", "Analytics", "Notifications", "Moderation"
• Range labels: "Today", "7 days", "30 days"
• Stat labels: "Daily users", "Kundlis created", "Consult minutes", "Earnings"
• Earnings empty: "No payments yet"
• Chart title: "Kundlis created"
• Attention title: "Needs attention"
• Attention empty: "All clear. Nothing needs attention."
• Quick actions: "Publish todays horoscope", "Add astrologer", "Send notification", "Review reports"
• Feature title: "Feature control"
• Feature body: "Turn features on or off with Remote Config without shipping an app update."
• Rail foot: "Admin", "Sign out"

## States

• Default: all cards filled from live data.
• Loading: stat cards show a soft line2 placeholder, chart card shows a spinner and the words "Loading".
• Empty, new product: stat cards show "No data yet" in Body small 14 ink3, chart card shows "No kundlis created in this range.", needs attention card shows "All clear. Nothing needs attention."
• Error: stat cards show "Could not load." with a text button "Try again" in the card.
• No permission: if the signed in admin lacks a permission, that card shows "You do not have access to this section." and its quick action is hidden. No admin role list is invented here.

## Accessibility

• Nav items are buttons with their label as the name. Active item is announced as current page.
• Stat values are text, not colour, and the change line is words, not an arrow alone.
• Chart has a text summary below it, for example "Kundlis created in this range: 42." with the real number from the system.

## Data and gating

• Owner scope only. No user sees this screen.
• Earnings and payments data come from the subscriptions and payments screen. No figure is invented in this design.
• Sample data: none. Dashboard numbers are live only. This file shows no sample numbers.

## Open question

• Feature control list: confirm the exact Remote Config flags with the build lead before the switches are drawn with final labels. No flag is invented in this file.
