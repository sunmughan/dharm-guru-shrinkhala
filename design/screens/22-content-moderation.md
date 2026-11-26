# 22 Content Moderation

## Purpose

Let the owner review astrologer chats, user reports, and remedy content before anything reaches users, and act on each item once, with a clear record.

## Source

Presentation section Seven, Owner Scope, "Content moderation. Review astrologer chats, user reports and remedy content before anything reaches users."

## Layout, desktop

1. Left rail as in the admin dashboard, with "Moderation" active.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Content Moderation", plus a count line Body 16 ink2 on the right: "3 items waiting" with the real count from the system, or "All clear" when the count is zero.
3. Filter row, 16 below the title: segmented control on the left: "All", "Chats", "Reports", "Remedies". Default is "All". Search field on the right, placeholder "Search by user or astrologer".
4. Queue list, 16 below the filter row: one card per item, standard card, padding 16, 12 gap:
   • Card top row: type pill on the left, "Chat", "Report", or "Remedy", in Caption 12 semibold, plus time Caption 12 ink3 on the right, from the system.
   • Card title: Title 17 ink, showing who the item is about, for example a user name and an astrologer name from the record, never invented.
   • Card body: Body 16 ink, the reported text or the remedy text as stored, quoted exactly. Long text is cut after three lines with a text button "Read full text" that expands the card.
   • Card foot, action row, 12 below the body: three buttons in a row, secondary style, height 44: "Approve", "Remove", "Escalate". "Remove" is a maroon text button, not a filled button. Tapping any action opens a confirm dialog with the item title in the dialog body, then the card leaves the queue and moves to the decided list.
5. Decided list, 24 below the queue: section title H2 serif 22 "Decided", then rows in a simple table card, each row 52 high: item title Title 17 ink on the left, decision status pill on the right: "Approved" in good green, "Removed" in maroon, "Escalated" in saffron2, plus the decider name and time in Caption 12 ink3 below the title. No more than 30 rows load at once, with a text button "Load more" at the foot.

## Review detail

• Chat review: tapping a chat item opens a read only view of that chat in a sheet, 560 wide on desktop, with the messages in order, the kundli context line if shared, and the same three actions at the foot. The reviewer cannot type in the chat.
• Report review: tapping a report item opens a sheet with the report reason as stored, the reported content quoted, and the reporter name as stored, plus the same three actions.
• Remedy review: tapping a remedy item opens a sheet with the remedy text as written, the kundli it was written for, and the same three actions. Approving a remedy publishes it to the remedies screen. Removing it keeps it out of the app.

## Components

• Filter segmented control and search field.
• Queue cards with type pill, quoted text, and three actions.
• Review sheets for chat, report, and remedy.
• Decided table with decision pills.

## Copy

• Title: "Content Moderation"
• Count line: "3 items waiting" as a pattern with the real count, or "All clear"
• Filters: "All", "Chats", "Reports", "Remedies"
• Search placeholder: "Search by user or astrologer"
• Type pills: "Chat", "Report", "Remedy"
• Expand action: "Read full text"
• Actions: "Approve", "Remove", "Escalate"
• Decided title: "Decided"
• Decision pills: "Approved", "Removed", "Escalated"
• Load action: "Load more"
• Confirm dialog pattern: title "Approve this item?", body with the item title, actions "Cancel" and "Approve". The same pattern applies to Remove and Escalate, with the verb changed.

## States

• Default: queue filled from live data, decided list below.
• Empty queue: queue area shows sun mark 48, title "Nothing waiting", body "New chats, reports, and remedies will appear here for review.", no primary button.
• All clear: count line reads "All clear".
• Loading: queue shows a spinner and the words "Loading moderation queue".
• Error: queue shows "Moderation queue could not be loaded." with a text button "Try again".
• Search, no result: queue shows "No item matches this search." with a text button "Clear search".
• Action done: toast "Item approved." or "Item removed." or "Item escalated.", with the real verb, and the card moves to the decided list.
• Escalated: the item stays visible in the decided list with status "Escalated" and a note showing who it was escalated to, from the system. No escalation target is invented in this design.

## Accessibility

• Queue cards are articles with a heading, so a screen reader moves through them in order.
• Decision is a word in a pill, never colour alone.
• Confirm dialogs state the item title in words before the action runs.

## Data and gating

• Owner scope only. No user sees this screen.
• No names, no report reasons, and no remedy text are invented in this design. Every value comes from the record.
• Sample data: none. The queue shows live records only.

## Open question

• Escalation target: confirm who an escalated item goes to, and whether escalation sends a notification, before the Escalate action ships with a final target. No target is invented in this file.
