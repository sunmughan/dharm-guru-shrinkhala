# 08 Panchang

## Purpose

Show the complete daily panchang with tithi, vaar, nakshatra, yoga, karana, and shubh muhurat, in plain language a family can read at a glance. The shubh muhurat is the largest element after the date. The rahu kaal warning is unmissable but calm.

## Source

Presentation section Three, eighth phone mockup, and section Four, Panchang Wireframe.

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Todays Panchang" in H3 serif 18. Right side: text button "Jaipur" with a chevron, showing the city for the panchang. Tapping it opens city choice. The sample city is Jaipur.
2. Date line, Body 16 ink2, 8 below the top bar: "Saturday, Jaipur". The date itself is the device date in words, for example "Saturday". No year is shown in the line because the top bar already carries the screen title and the device date is clear from context. If the client wants the full date, add it here in the same line.
3. Two by two grid of detail cards, 16 gap, each standard card padding 16, label Caption 12 ink3 above value Title 17 ink:
   • "Tithi", "Shukla Panchami"
   • "Vaar", "Shanivaar"
   • "Nakshatra", "Rohini till 04:12 PM"
   • "Yoga", "Siddhi"
   • Second row continues the grid with "Karana", "Bava", and a sixth card "Sunrise", "06:48 AM", plus "Sunset", "05:52 PM". Layout is a two column grid, so the six cards flow as three rows of two.
4. Shubh Muhurat hero card, 16 below the grid, padding 20, fill surface2 light and surface dark, radius 18: overline "Shubh Muhurat" in Caption 12 semibold saffron2, value H2 serif 22 "09:42 AM to 11:15 AM and 04:30 PM to 06:05 PM." in ink, body Body small 14 ink2 below: "Best for new beginnings." The two windows are on separate lines inside the value, first window then second window, so neither wraps awkwardly.
5. Rahu Kaal strip, 12 below the hero card, info strip style with a maroon left edge 3 wide: label "Rahu Kaal" in Caption 12 semibold maroon, value Body small 14 ink "01:30 PM to 03:00 PM. Avoid starting new work in this window."
6. Text button, centred, 16 below the strip: "View festival notes" if festival notes exist for the day. If none exist, this button is hidden, never shown disabled. Festival notes content is published in the admin panel.
7. Bottom tabs: Panchang active, Home, Kundli, Consult, Profile.

## Components

• City button in the top bar.
• Seven detail cards in a two by two grid.
• Shubh Muhurat hero card.
• Rahu Kaal warning strip.
• Festival notes text button, conditional.

## Copy

All values below are sample data from the presentation, for Saturday in Jaipur.

• Title: "Todays Panchang"
• City: "Jaipur"
• Date line: "Saturday, Jaipur"
• "Tithi", "Shukla Panchami"
• "Vaar", "Shanivaar"
• "Nakshatra", "Rohini till 04:12 PM"
• "Yoga", "Siddhi"
• "Karana", "Bava"
• "Sunrise", "06:48 AM"
• "Sunset", "05:52 PM"
• Shubh Muhurat label: "Shubh Muhurat"
• Shubh Muhurat value: "09:42 AM to 11:15 AM and 04:30 PM to 06:05 PM."
• Rahu Kaal label: "Rahu Kaal"
• Rahu Kaal value: "01:30 PM to 03:00 PM. Avoid starting new work in this window."
• Festival action: "View festival notes"

## States

• Default: as above, with todays published panchang for the chosen city.
• City change: tapping "Jaipur" opens a city list. Choosing a city reloads the six cards, the muhurat card, and the rahu kaal strip. The city name in the top bar and in the date line updates together.
• Loading: detail cards show a soft line2 placeholder. The muhurat card shows a spinner and the words "Loading todays panchang".
• Empty: if no panchang is published for the day, the six cards show "Not published yet" in Body small 14 ink3, and the muhurat card shows "Shubh muhurat is not published yet." No times are invented.
• Error: same empty state with a toast "Could not load the panchang. Check your connection and try again."
• Offline: cached panchang is shown with a small info strip at the top: "Showing saved panchang. Check your connection for todays update."

## Accessibility

• Times are text, not images, and are announced in full.
• The rahu kaal warning is text plus a maroon edge, never colour alone.
• The muhurat card is the largest text on the screen after the title, so it is found first by sight and by screen reader order.

## Data and gating

• Free: full panchang with tithi, vaar, nakshatra, yoga, and karana, plus shubh muhurat and rahu kaal warning.
• Premium: muhurat alerts for personal events like griha pravesh and vivah. The alert setting lives in Profile and in Notifications, not on this screen.
• Sample data: every value above is the presentation sample panchang.

## Open question

• None on layout. City list source is a build decision, not a design decision, and is left to the build lead.
