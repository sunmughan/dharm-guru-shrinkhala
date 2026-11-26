# 20 Analytics and Revenue

## Purpose

Show daily users, kundlis created, consult minutes, and earnings in clear charts, so growth decisions use real data. No figure is invented in this design. Every number comes from Analytics and from the payments system.

## Source

Presentation section Six, Analytics, and section Seven, Owner Scope, "View analytics and revenue. Daily users, kundlis created, consult minutes and earnings in clear charts."

## Layout, desktop

1. Left rail as in the admin dashboard, with "Analytics" active.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Analytics and Revenue", plus a range segmented control on the right: "Today", "7 days", "30 days". Default is "7 days" on this screen, because a single day gives no trend.
3. Four stat cards in a row, 16 below the title, each standard card padding 20, same pattern as the dashboard: label Caption 12 semibold ink3 above value H2 serif 22 ink, plus a change line Body small 14 ink2 below in words, for example "Up from the previous 7 days" with the real change from the system. Cards: "Daily users", "Kundlis created", "Consult minutes", "Earnings". Earnings shows the amount and currency from the payments system. If no payment has been taken yet, the card shows "No payments yet" in Body small 14 ink3, never a zero with a currency that implies a price.
4. Charts area, 16 below the stat cards, two columns:
   • Left chart card, wide, title H3 18 "Kundlis created", simple line chart in saffron, axes in Caption 12 ink3, no blend fill under the line. Below the chart, a text summary in Body small 14 ink2 with the real total for the range.
   • Right chart card, narrow, title H3 18 "Daily users", simple bar chart in saffron at 70 percent opacity, axes in Caption 12 ink3. Below the chart, a text summary in Body small 14 ink2 with the real total for the range.
5. Second charts row, 16 below, two columns:
   • Left chart card, title H3 18 "Consult minutes", simple line chart in saffron, same pattern, with a text summary below.
   • Right chart card, title H3 18 "Earnings", simple bar chart in saffron at 70 percent opacity, same pattern, with a text summary below. If no payment has been taken yet, this card shows "No payments yet." and no bars.
6. Events table, 16 below the charts, standard card, padding 0, radius 18: title H3 18 "Key events" in a header area with padding 16, then rows with dividers, each row 52 high: event name Title 17 ink on the left, count Body 16 ink semibold on the right. Events are the Analytics events from the presentation: "Screen views", "Kundli creation", "Consult bookings". No other event is listed until the build adds it. Each row is text only, no chart.

## Components

• Range segmented control.
• Four stat cards.
• Four chart cards, two line and two bar.
• Key events table with three rows.

## Copy

• Title: "Analytics and Revenue"
• Range labels: "Today", "7 days", "30 days"
• Stat labels: "Daily users", "Kundlis created", "Consult minutes", "Earnings"
• Earnings empty: "No payments yet"
• Chart titles: "Kundlis created", "Daily users", "Consult minutes", "Earnings"
• Events title: "Key events"
• Event names: "Screen views", "Kundli creation", "Consult bookings"

## States

• Default: all cards filled from live data for the chosen range.
• Empty, new product: stat cards show "No data yet" in Body small 14 ink3, chart cards show "No data in this range.", events table shows "No events yet."
• Loading: chart cards show a spinner and the words "Loading".
• Error: chart cards show "Could not load." with a text button "Try again".
• Range change: tapping "Today", "7 days", or "30 days" reloads all four stat cards, all four charts, and the events table together. No card keeps the old range.

## Accessibility

• Every chart has a text summary below it with the real total, so the chart is never the only way to read the number.
• Stat values are text, not colour, and the change line is words.
• Bar and line charts use saffron only, with axes in ink3, so they stay readable in both modes.

## Data and gating

• Owner scope only.
• No numbers are invented in this design. Every value comes from Analytics or from the payments system.
• Sample data: none. This screen shows live data only.

## Open question

• None on layout. Event list is fixed to the three events named in the presentation until the build adds more.
