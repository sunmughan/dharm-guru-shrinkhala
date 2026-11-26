# 18 Publish Daily Horoscope Content

## Purpose

Let the owner write and schedule horoscope and panchang content for every rashi, and publish it so it reaches users the moment it is published. This is the content engine behind Home, Daily Horoscope, and Panchang.

## Source

Presentation section Seven, Owner Scope, "Publish daily content. Write and schedule horoscope and panchang content for every rashi."

## Layout, desktop

1. Left rail as in the admin dashboard, with "Daily Content" active.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Daily Content", plus a primary button on the right "New content", height 48, saffron fill.
3. Date and type row, 16 below the title: date picker on the left showing the content date, plus a segmented control on the right: "Horoscope", "Panchang". Default is "Horoscope".
4. Horoscope view: a grid of twelve rashi cards, three columns on desktop, one column on narrow screens, each standard card padding 16:
   • Card top: rashi name H3 serif 18 on the left, status pill on the right: "Published" in good green, "Draft" in saffron2, "Not started" in ink3.
   • Card body: the horoscope text in Body 16 ink if written, or "No content yet." in Body small 14 ink3 if empty.
   • Card foot: four area values in a two by two mini grid, Caption 12 ink3 label above Body small 14 ink value: Career, Money, Health, Love. If any value is empty, it shows a dash in ink3, never an invented word.
   • Card foot second line: "Lucky Number" and "Lucky Colour" in Body small 14 ink2.
   • Tapping a card opens the editor for that rashi.
5. Panchang view: one form card, standard card, padding 20, with fields in order: "Date", "City", "Tithi", "Vaar", "Nakshatra", "Nakshatra till", "Yoga", "Karana", "Sunrise", "Sunset", "Shubh Muhurat start", "Shubh Muhurat end", "Second Shubh Muhurat start", "Second Shubh Muhurat end", "Rahu Kaal start", "Rahu Kaal end", "Festival notes". Each field is a text field per the design system input pattern. No value is prefilled except the date and city from the row above.
6. Editor, opened from a rashi card: a sheet on the right, 560 wide on desktop, full width on narrow screens, with the rashi name as title, then fields: "Horoscope text" as a large text area, height 160, plus "Career", "Money", "Health", "Love" as short fields, plus "Lucky Number" and "Lucky Colour" as short fields, plus a status line showing "Last saved" time. Foot of the sheet: secondary button "Save draft" on the left, primary button "Publish" on the right. Publishing one rashi publishes only that rashi. A "Publish all" secondary button sits at the top of the grid and publishes every rashi that has a saved draft.

## Components

• Date picker and content type segmented control.
• Twelve rashi cards with status pills.
• Panchang form card with fifteen fields.
• Rashi editor sheet with text area and seven short fields.
• Save draft and Publish buttons.

## Copy

• Title: "Daily Content"
• Primary: "New content"
• Types: "Horoscope", "Panchang"
• Statuses: "Published", "Draft", "Not started"
• Empty card body: "No content yet."
• Editor labels: "Horoscope text", "Career", "Money", "Health", "Love", "Lucky Number", "Lucky Colour"
• Panchang labels: "Date", "City", "Tithi", "Vaar", "Nakshatra", "Nakshatra till", "Yoga", "Karana", "Sunrise", "Sunset", "Shubh Muhurat start", "Shubh Muhurat end", "Second Shubh Muhurat start", "Second Shubh Muhurat end", "Rahu Kaal start", "Rahu Kaal end", "Festival notes"
• Actions: "Save draft", "Publish", "Publish all"
• Saved line: "Last saved" plus the time from the system.

## States

• Default: grid shows the status of each rashi for the chosen date.
• All published: each card shows "Published", and the "Publish all" button is hidden.
• Draft: card shows "Draft", and the editor shows the saved draft text.
• Not started: card shows "Not started" and "No content yet."
• Saving: "Save draft" shows a spinner and is disabled until the save completes.
• Publishing: "Publish" shows a spinner, then the card status changes to "Published" and a toast says "Published. Users see it now."
• Error: if publishing fails, a toast says "Could not publish. Try again." The draft stays saved.
• Past date: content for a past date is read only, with an info strip: "This date is in the past. Content is read only." No editing, no publishing.
• Scheduled: scheduling is the date picker itself. Content written for a future date is a draft until published. No separate schedule time is designed, because the presentation says write and schedule, and the date is the schedule. If the client wants a publish time as well as a date, see the open question below.

## Accessibility

• Rashi cards are buttons with the rashi name and status as the label.
• Text area has a visible label and a character count in Caption 12 ink3.
• Status is a word in a pill, never colour alone.

## Data and gating

• Owner scope only.
• No horoscope copy is written in this design. All horoscope text is written by the owner in this editor.
• Sample data: none. The editor starts empty. The sample horoscope copy in the user screens is sample data for design only and must not be copied into published content without owner approval.

## Open question

• Publish time: confirm whether content for a future date publishes at a fixed morning time, for example 06:00 AM, or publishes the moment the owner taps Publish. No time field is designed until this is settled.
