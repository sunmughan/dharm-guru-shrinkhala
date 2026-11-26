# 17 Manage Astrologers

## Purpose

Let the owner add astrologers, set rates, approve profiles, and control online slots, from one list. No astrologer name is invented in this design. Every name shown comes from the admin panel data.

## Source

Presentation section Seven, Owner Scope, "Manage astrologers. Add astrologers, set rates, approve profiles and control online slots."

## Layout, desktop

1. Left rail as in the admin dashboard, with "Astrologers" active.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Astrologers", plus a primary button on the right "Add astrologer", height 48, saffron fill.
3. Filter row, 16 below the title: search field on the left, placeholder "Search by name", plus a segmented control on the right: "All", "Online", "Offline", "Waiting approval". Default is "All".
4. Table card, 16 below the filter row, standard card, padding 0, radius 18: header row plus one row per astrologer. Columns: "Name", "Languages", "Status", "Rate", "Slots", "Action". Header labels Caption 12 semibold ink3. Each row is 64 high, divider 1px line.
   • Name cell: avatar pill 40 with initials plus name Title 17 ink and a second line Caption 12 ink3 with the astrologer short line supplied by the profile, for example languages are in the Languages column, not in the name cell.
   • Languages cell: Body 16 ink, comma separated list from the profile, for example "Hindi, English" only if the profile supplies those languages. No language is invented in this spec.
   • Status cell: status pill, "Online" in good green, "Offline" in ink3, "Waiting approval" in saffron2.
   • Rate cell: Body 16 ink, showing the rate as stored. Pricing is to be decided, so if no rate is set the cell shows "Rate to be decided" in Body small 14 ink3, never an invented rate.
   • Slots cell: Body 16 ink, for example "6 slots today" from the slot system.
   • Action cell: text button "View" that opens the astrologer detail.
5. Astrologer detail, opened from a row: a sheet on the right, 480 wide on desktop, full width on narrow screens, with the astrologer name, languages, status, rate, bio as supplied, and three sections: "Approval" with buttons "Approve" as primary and "Reject" as maroon text button, "Slots" with a list of online slots and an "Add slot" secondary button, and "Session history" with a simple list of past consults showing date and duration. No rating is shown unless the system supplies one.

## Add astrologer form

• Opened by "Add astrologer": a sheet with fields in order: "Full name", "Languages", "Short bio", "Rate", "Chat available" switch, "Call available" switch. Rate field help text: "Pricing is to be decided. Leave blank until rates are set."
• Primary button "Save astrologer" is disabled until name is filled. Saving creates the profile in "Waiting approval" status. Approval is a separate step, so a new astrologer never goes live by saving alone.

## Components

• Search field and status filter.
• Astrologer table with six columns.
• Detail sheet with approval, slots, and history.
• Add form sheet.

## Copy

• Title: "Astrologers"
• Primary: "Add astrologer"
• Search placeholder: "Search by name"
• Filters: "All", "Online", "Offline", "Waiting approval"
• Table headers: "Name", "Languages", "Status", "Rate", "Slots", "Action"
• Statuses: "Online", "Offline", "Waiting approval"
• Rate empty: "Rate to be decided"
• Row action: "View"
• Detail sections: "Approval", "Slots", "Session history"
• Approval actions: "Approve", "Reject"
• Slots action: "Add slot"
• Form labels: "Full name", "Languages", "Short bio", "Rate", "Chat available", "Call available"
• Rate help: "Pricing is to be decided. Leave blank until rates are set."
• Save: "Save astrologer"

## States

• Default: table filled from live data.
• Empty, no astrologers: table card shows sun mark 48, title "No astrologers yet", body "Add your first astrologer to open live consult.", primary button "Add astrologer".
• Waiting approval: status pill "Waiting approval", detail sheet shows the approval buttons. Approving changes the status to "Offline" until the astrologer sets slots and goes online.
• Rejected: status is removed from the main list and the profile moves to a "Rejected" view under the filter. The filter list in version 1 is All, Online, Offline, Waiting approval, and Rejected is reached from a text button at the foot of the table: "View rejected profiles".
• Loading: table shows a spinner and the words "Loading astrologers".
• Error: table shows "Astrologers could not be loaded." with a text button "Try again".
• Search, no result: table shows "No astrologer matches this search." with a text button "Clear search".

## Accessibility

• Table is a real table with header labels.
• Status is a word in a pill, never colour alone.
• Switches announce on and off with their label.

## Data and gating

• Owner scope only.
• No astrologer names, languages, rates, or ratings are invented in this design. Every value comes from the profile data.
• Pricing: rates are to be decided. The rate cell and the form say so plainly.

## Open question

• Rate structure: confirm whether rates are per minute, per session, or both, and in which currency, before the rate field is built with a final format. The presentation says "by the minute or by session" for consult, so the field must support both, but the exact format is open.
