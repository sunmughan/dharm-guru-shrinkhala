# 21 Push Notifications

## Purpose

Let the owner send horoscope alerts, festival wishes, and offer messages to all users or to one segment, with a clear audience, a clear message, and a record of what was sent.

## Source

Presentation section Seven, Owner Scope, "Push notifications. Send horoscope alerts, festival wishes and offer messages to all users or to one segment."

## Layout, desktop

1. Left rail as in the admin dashboard, with "Notifications" active.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Push Notifications", plus a primary button on the right "New notification", height 48, saffron fill.
3. Compose card, 16 below the title, standard card, padding 20, shown when "New notification" is tapped, otherwise hidden:
   • Field 1, "Title", text field, height 52, placeholder "Todays horoscope is ready".
   • Field 2, "Message", large text area, height 120, placeholder "Kanya: a strong day for money talks."
   • Field 3, "Audience", segmented control: "All users", "Free users", "Premium users". Default is "All users".
   • Field 4, "Type", segmented control: "Horoscope alert", "Festival wish", "Offer message". Default is "Horoscope alert".
   • Field 5, "Send time", segmented control: "Send now", "Send at 06:00 AM". Default is "Send now". No other time is offered in version 1, because the morning habit time in the presentation is 06:00 AM.
   • Field 6, "Open screen", a select field with options "Home", "Daily Horoscope", "Panchang", "Consult". Default is "Home". Tapping the notification in the app opens that screen.
   • Foot of the compose card: secondary button "Save draft" on the left, primary button "Send now" on the right. When "Send at 06:00 AM" is chosen, the primary button reads "Schedule for 06:00 AM". Sending opens a confirm dialog: title "Send this notification?", body "This goes to All users." with the real audience in the body, actions "Cancel" and "Send" as the primary button.
4. Sent list, 16 below the compose card, standard card, padding 0, radius 18: header row plus one row per sent notification. Columns: "Title", "Audience", "Type", "Sent at", "Status". Header labels Caption 12 semibold ink3. Each row is 52 high, divider 1px line.
   • Title cell: Title 17 ink, with the message in Body small 14 ink2 below it.
   • Audience cell: Body 16 ink, "All users", "Free users", or "Premium users".
   • Type cell: Body 16 ink, "Horoscope alert", "Festival wish", or "Offer message".
   • Sent at cell: Body 16 ink, date and time from the system.
   • Status cell: status pill, "Sent" in good green, "Scheduled" in saffron2, "Failed" in maroon, "Draft" in ink3.
5. Drafts sit at the top of the sent list with status "Draft" and a text button "Edit" that reopens the compose card with the draft filled in.

## Components

• Compose card with six fields.
• Confirm dialog for sending.
• Sent list table with five columns.

## Copy

• Title: "Push Notifications"
• Primary: "New notification"
• Field labels: "Title", "Message", "Audience", "Type", "Send time", "Open screen"
• Title placeholder: "Todays horoscope is ready"
• Message placeholder: "Kanya: a strong day for money talks."
• Audiences: "All users", "Free users", "Premium users"
• Types: "Horoscope alert", "Festival wish", "Offer message"
• Send times: "Send now", "Send at 06:00 AM"
• Open screens: "Home", "Daily Horoscope", "Panchang", "Consult"
• Actions: "Save draft", "Send now", "Schedule for 06:00 AM"
• Confirm title: "Send this notification?"
• Confirm body pattern: "This goes to All users." with the real audience in place of All users.
• Confirm actions: "Cancel", "Send"
• Table headers: "Title", "Audience", "Type", "Sent at", "Status"
• Statuses: "Sent", "Scheduled", "Failed", "Draft"
• Draft action: "Edit"

## States

• Default: sent list filled from live data, compose card hidden until "New notification" is tapped.
• Empty, nothing sent: sent list shows sun mark 48, title "No notifications sent yet", body "Send your first horoscope alert or festival wish.", primary button "New notification".
• Draft saved: toast "Draft saved." and the draft appears at the top of the list with status "Draft".
• Scheduled: row shows status "Scheduled" and the scheduled time in the Sent at column. A scheduled row has a text button "Cancel" that removes the schedule with a confirm dialog.
• Failed: row shows status "Failed" in maroon, with a text button "Retry" that reopens the compose card with the same values.
• Sending: "Send now" shows a spinner and is disabled until the send completes.
• Error: if sending fails, a toast says "Could not send. Try again." The compose card stays open with the values kept.
• Offer message: the type "Offer message" is in the presentation, so it is offered here. No offer copy is invented. The owner writes the offer text. If no offer exists, the owner simply does not choose this type.

## Accessibility

• Compose fields have visible labels above each field.
• Status is a word in a pill, never colour alone.
• Confirm dialog states the real audience in words before sending.

## Data and gating

• Owner scope only.
• No notification copy is invented in this design. The placeholders above are sample text from the presentation home copy, used only as placeholders in empty fields, never sent as content.
• Sample data: none in the sent list. The list shows live records only.

## Open question

• Send time: version 1 offers "Send now" and "Send at 06:00 AM" only. Confirm whether other send times are needed before a time picker is added.
