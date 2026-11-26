# 15 Notifications

## Purpose

List every notification the app has sent, and let the user control which alerts arrive and when. One list, one settings entry, no duplicate controls.

## Source

Presentation section Five, Alerts Layer, and section Seven, Owner Scope push notifications. The user side timing, horoscope at 06:00 AM, is from the Profile mockup.

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Notifications" in H3 serif 18. Right side: text button "Settings" that opens the alert settings on this same screen, scrolled to the settings card. No separate settings screen is needed.
2. Today list, 16 below the top bar: section title H2 serif 22 "Today", then notification rows, each a standard card, padding 16, 12 gap:
   • Row layout: sun mark icon 20 saffron on the left, title Title 17 ink, body Body small 14 ink2 below the title, time Caption 12 ink3 on the right.
   • Sample rows, labelled sample data, using published content types only:
     • "Todays horoscope is ready", "Kanya: a strong day for money talks.", "06:00 AM"
     • "Shubh muhurat today", "09:42 AM to 11:15 AM is best for new beginnings.", "06:05 AM"
   • Tapping a horoscope row opens Daily Horoscope. Tapping a muhurat row opens Panchang. Tapping a consult row opens the consult list. Tapping a festival row opens Panchang.
3. Earlier list, 24 below the today list: section title H2 serif 22 "Earlier", then rows in the same pattern, newest first, with date text in Caption 12 ink3, for example "Yesterday". No more than 30 rows are loaded at once. A text button "Load more" at the foot loads the next 30.
4. Settings card, 24 below the earlier list, standard card, padding 16: title H3 18 "Alert settings", then four switch rows with dividers, each row label Title 17 ink on the left and switch on the right, with Body small 14 ink2 below the label:
   • "Daily horoscope", "Every morning at 06:00 AM"
   • "Shubh muhurat alerts", "On festival days and for personal events"
   • "Consult reminders", "Before a booked chat or call"
   • "Festival wishes", "On festival days"
   • Below the rows, a time row: label Title 17 "Horoscope time" on the left, value text button "06:00 AM" on the right that opens the platform time picker. Changing it updates the daily horoscope time for that user.
5. Footnote, 16 below the settings card, centred, Caption 12 ink3: "Daily alerts are free for every user."

## Components

• Notification rows with icon, title, body, and time.
• "Today" and "Earlier" sections.
• "Load more" text button.
• Alert settings card with four switches and a time picker row.

## Copy

• Title: "Notifications"
• Settings action: "Settings"
• Section titles: "Today", "Earlier"
• Sample row 1 title: "Todays horoscope is ready"
• Sample row 1 body: "Kanya: a strong day for money talks."
• Sample row 1 time: "06:00 AM"
• Sample row 2 title: "Shubh muhurat today"
• Sample row 2 body: "09:42 AM to 11:15 AM is best for new beginnings."
• Sample row 2 time: "06:05 AM"
• Load action: "Load more"
• Settings title: "Alert settings"
• Switch rows: "Daily horoscope", "Every morning at 06:00 AM"; "Shubh muhurat alerts", "On festival days and for personal events"; "Consult reminders", "Before a booked chat or call"; "Festival wishes", "On festival days"
• Time row: "Horoscope time", "06:00 AM"
• Footnote: "Daily alerts are free for every user."

## States

• Default: today rows plus earlier rows plus settings card, as above.
• Empty, no notifications yet: sun mark 48, title "No notifications yet", body "Your horoscope and muhurat alerts will appear here each morning.", no primary button. The settings card stays visible below.
• All switches off: the list still shows past notifications, and an info strip appears above the today list: "All alerts are off. Turn on daily horoscope to get the morning alert."
• Loading: rows show a soft line2 placeholder.
• Error: rows area shows "Notifications could not be loaded." with a text button "Try again". Settings card stays visible.
• Offline: cached notifications are shown with a small info strip: "Showing saved notifications."
• Notification permission off at system level: an info strip at the top says "Notifications are off in system settings." with a text button "Open settings" that opens the system settings for the app. The in app switches stay, but they have no effect until the system permission is on, and the strip says so.

## Accessibility

• Rows are buttons with title, body, and time as the accessible name.
• Switches announce on and off with their label.
• Time picker is the platform picker.

## Data and gating

• Free: daily notifications for horoscope and festival days.
• Premium: muhurat alerts for personal events like griha pravesh and vivah, controlled by the "Shubh muhurat alerts" switch.
• Sample data: the two today rows are sample values from the presentation home and panchang copy. No notification copy is invented beyond the four alert types listed in the presentation.

## Open question

• Default horoscope time 06:00 AM is from the presentation profile screen. Confirm whether the user can change it, as designed here, or whether it stays fixed.
