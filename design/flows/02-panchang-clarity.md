# Flow 02 Panchang Clarity

## Goal

A user opening Panchang in the morning can answer three questions in under ten seconds: what is todays tithi, when is the shubh muhurat, and when is rahu kaal. Everything else is secondary.

## Screens involved

• `screens/03-home.md` for the panchang snapshot and muhurat strip
• `screens/08-panchang.md` for the full panchang
• `screens/15-notifications.md` for muhurat alerts

## Flow, step by step

1. Morning alert arrives at 06:00 AM, sample time from the presentation, titled "Todays horoscope is ready" or "Shubh muhurat today". Tapping it opens Panchang.
2. Or the user opens Home and reads the tithi card, the nakshatra card, and the muhurat strip without opening Panchang.
3. Or the user taps the Panchang tab and lands on the full panchang screen.
4. Top of the screen: date line "Saturday, Jaipur" and city button "Jaipur". The city is visible before any value, so the user knows which city the times belong to.
5. Seven detail cards in a two by two grid: Tithi, Vaar, Nakshatra, Yoga, Karana, Sunrise, Sunset. Each card has one label and one value. No card holds two ideas.
6. Shubh Muhurat hero card: the largest element after the title, value "09:42 AM to 11:15 AM and 04:30 PM to 06:05 PM." with the two windows on separate lines.
7. Rahu Kaal strip: maroon left edge, label "Rahu Kaal", value "01:30 PM to 03:00 PM. Avoid starting new work in this window."
8. Festival notes button appears only if festival notes exist for the day. If none exist, the button is hidden, never shown disabled.

## Clarity rules

• One label and one value per card. No card shows a time range and a note together, except the muhurat hero card, which is allowed two windows because they are the same idea.
• Times are written in full, "09:42 AM to 11:15 AM", never as a range with a dash. This follows the no hyphen rule for visible copy.
• Nakshatra carries its end time in the same value, "Rohini till 04:12 PM", so the user does not need a second card.
• Muhurat is the hero. It is the only card with surface2 fill in light mode and the only card with an H2 value.
• Rahu Kaal is the warning. It is the only element with a maroon edge. It is text plus an edge, never colour alone.
• City is always visible. Changing the city reloads all six cards, the muhurat card, and the rahu kaal strip together. No card keeps the old city.

## Sample panchang used in this flow

Saturday, Jaipur. Tithi Shukla Panchami. Vaar Shanivaar. Nakshatra Rohini till 04:12 PM. Yoga Siddhi. Karana Bava. Sunrise 06:48 AM. Sunset 05:52 PM. Shubh Muhurat 09:42 AM to 11:15 AM and 04:30 PM to 06:05 PM. Rahu Kaal 01:30 PM to 03:00 PM. All sample data from the presentation.

## Failure paths

• No panchang published: six cards show "Not published yet", muhurat card shows "Shubh muhurat is not published yet." No times are invented.
• Load fails: same empty state with a toast "Could not load the panchang. Check your connection and try again."
• Offline: cached panchang is shown with an info strip "Showing saved panchang. Check your connection for todays update."

## Open question

• None on clarity. City list source is a build decision, left to the build lead.
