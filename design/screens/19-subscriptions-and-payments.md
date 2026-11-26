# 19 Subscriptions and Payments

## Purpose

Let the owner control premium plans, trials, and payments from one place. Pricing is to be decided, so this screen shows plans without invented prices and payments without invented amounts.

## Source

Presentation section Seven, Owner Scope, "Manage subscriptions. Control premium plans, trials and payments from one place. Pricing is to be decided."

## Layout, desktop

1. Left rail as in the admin dashboard, with "Subscriptions" active.
2. Main area, max width 1200, padding 24: title H1 serif 28 "Subscriptions and Payments", plus a primary button on the right "New plan", height 48, saffron fill.
3. Plans row, 16 below the title: plan cards in a row, each standard card padding 20, width 320:
   • Card top: plan name H3 serif 18 on the left, status pill on the right: "Active" in good green, "Draft" in saffron2, "Paused" in ink3.
   • Card body: price line H2 serif 22, showing "To be decided" in version 1, never an invented price. Below, Body small 14 ink2 with the plan length as stored, for example "Monthly" only if the plan supplies it. Below that, a benefit list in Body small 14 ink, one line per benefit, using the seven premium benefits from the premium upgrade screen.
   • Card foot: text button "Edit plan" and text button "Pause" or "Resume" in maroon for pause.
   • In version 1, with pricing to be decided, the plans row shows one card titled "Premium" with price "To be decided" and status "Draft". No second plan is invented.
4. Trials card, 16 below the plans row, standard card, padding 20: title H3 18 "Trials", body Body small 14 ink2 "Trial length is to be decided.", plus a switch row "Trials on" with a switch. In version 1 the switch is off and disabled, with the note "Turn on trials when trial length is decided." No trial length field is shown until the length is decided.
5. Payments table, 16 below the trials card, standard card, padding 0, radius 18: header row plus one row per payment. Columns: "Date", "User", "Plan", "Amount", "Status". Header labels Caption 12 semibold ink3. Each row is 52 high, divider 1px line.
   • Date cell: Body 16 ink, date and time from the payment record.
   • User cell: Body 16 ink, user name as stored, never a full phone number or email in the table. Tapping the name opens the user detail in a sheet, which is a simple read only view built from this system.
   • Plan cell: Body 16 ink, plan name.
   • Amount cell: Body 16 ink semibold, amount and currency from the payment record.
   • Status cell: status pill, "Paid" in good green, "Failed" in maroon, "Refunded" in ink3, "Pending" in saffron2.
6. Filter row above the table: search field "Search by user" on the left, plus a segmented control on the right: "All", "Paid", "Failed", "Refunded", "Pending". Default is "All".

## Components

• Plan cards with status pills and edit actions.
• Trials card with a disabled switch in version 1.
• Payments table with five columns and a filter row.

## Copy

• Title: "Subscriptions and Payments"
• Primary: "New plan"
• Plan name, version 1: "Premium"
• Plan price, version 1: "To be decided"
• Plan statuses: "Active", "Draft", "Paused"
• Plan actions: "Edit plan", "Pause", "Resume"
• Trials title: "Trials"
• Trials body: "Trial length is to be decided."
• Trials switch: "Trials on"
• Trials note: "Turn on trials when trial length is decided."
• Table headers: "Date", "User", "Plan", "Amount", "Status"
• Payment statuses: "Paid", "Failed", "Refunded", "Pending"
• Search placeholder: "Search by user"
• Filters: "All", "Paid", "Failed", "Refunded", "Pending"

## States

• Default, no payments yet: plans row shows the Premium draft card, trials card as above, payments table shows "No payments yet." with no rows. No zero amount row is invented.
• Plan active: status pill "Active", pause action visible.
• Plan paused: status pill "Paused", resume action visible, and the premium upgrade screen in the app shows the plan as unavailable until resumed. That app behaviour is noted here, not designed twice.
• Payment failed: status pill "Failed" in maroon, row action "View" opens the payment detail sheet with the failure note from the payment system.
• Refund: payment detail sheet has a maroon text button "Refund" that opens a confirm dialog: title "Refund this payment?", body "The amount returns to the user. This cannot be undone.", actions "Cancel" and "Refund" as a maroon text button.
• Loading: table shows a spinner and the words "Loading payments".
• Error: table shows "Payments could not be loaded." with a text button "Try again".

## Accessibility

• Table is a real table with header labels.
• Status is a word in a pill, never colour alone.
• Disabled switch is announced as disabled, with the note explaining why.

## Data and gating

• Owner scope only.
• No prices, no trial lengths, no payment amounts, and no user contact details are invented in this design. Every value comes from the plan or the payment record.
• Pricing: to be decided everywhere on this screen.

## Open question

• Plan structure: confirm how many plans exist, their lengths, and their prices, before the plans row is built with final cards. Version 1 shows one Premium draft card only.
• Refund policy: confirm who can refund and whether a refund needs a second approval, before the refund button ships.
