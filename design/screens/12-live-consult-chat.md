# 12 Live Consult, Chat

## Purpose

Let the user chat with a live astrologer inside the app, with a clear start, a clear cost basis, and a full session history. Chat is premium, by the minute or by session, per the presentation. Pricing is to be decided, so no rate is shown.

## Source

Presentation section Five, Consult Layer and Premium Layer, and section Seven, User Scope premium.

## Layout, top to bottom

1. Top bar: back chevron on the left, astrologer name Title 17 semibold in the centre, with status Caption 12 good green "Online" below the name. Right side: phone icon button 44 tap area that opens the call screen. No astrologer name is invented in this spec. The name shown is the name from the astrologer list, supplied by the admin panel.
2. Session strip, info strip style, 12 below the top bar: "Chat consult. Pricing to be decided." plus the session timer in Body small 14 ink on the right, starting at "00:00". The timer counts up during the chat. No rate, no per minute figure, and no total appears anywhere, because pricing is to be decided.
3. Message list, flexible area, padding 16, messages in bubbles:
   • Astrologer messages: surface fill, line border, radius 18 with a 4 radius on the top left corner, ink text Body 16, max width 75 percent, left aligned.
   • User messages: saffron fill at 12 percent opacity wash in light mode, surface2 in dark mode, radius 18 with a 4 radius on the top right corner, ink text Body 16, max width 75 percent, right aligned. No solid saffron bubble with white text, so long chats stay calm to read.
   • Time stamps: Caption 12 ink3 below each bubble, for example "10:24 AM".
   • System messages, for example "Astrologer joined the chat", are centred Caption 12 ink3 with no bubble.
4. Kundli context card, pinned above the composer when the chat starts: standard card, padding 12, Body small 14 ink2: "Sharing your kundli: Aarav Sharma, Meena Lagna, Kanya Rashi, born 14 March 1998, Jaipur." with a text button "Hide" that collapses it. The astrologer sees the shared kundli, so the user does not have to retype birth details. The card is sample data when the sample kundli is in use.
5. Composer, foot, above the safe area: text field height 52, radius 999, fill surface, line2 border, placeholder "Type your question", plus a send button, pill 44, saffron fill, send icon in white light mode and #14100C dark mode. The send button is disabled when the field is empty.
6. No bottom tabs on this screen. Back returns to the consult list.

## Consult list, the screen before chat

The chat screen is reached from a consult list. That list is part of this spec because chat needs a starting point. List layout: top bar title "Consult", search field, then astrologer rows, each a standard card with avatar pill 40 with initials, name Title 17, languages Body small 14 ink2, status pill "Online" or "Busy", and a text button "Chat". No ratings are invented. If the admin panel supplies a rating, show it as stars plus "4 of 5" in text. If no rating exists, show nothing in that place, never a made up rating.

## Components

• Top bar with astrologer name, online status, and call button.
• Session strip with timer and pricing note.
• Message bubbles, user and astrologer.
• Kundli context card.
• Composer with send button.
• Consult list with astrologer rows.

## Copy

• Title: "Consult" on the list, astrologer name on the chat top bar.
• Online status: "Online"
• Busy status: "Busy"
• Session strip: "Chat consult. Pricing to be decided."
• Composer placeholder: "Type your question"
• Context card: "Sharing your kundli: Aarav Sharma, Meena Lagna, Kanya Rashi, born 14 March 1998, Jaipur." (Sample data)
• Context action: "Hide"
• System message: "Astrologer joined the chat"
• End action, in the top bar menu: "End chat"
• List action: "Chat"

## States

• Default, premium user: chat opens, timer runs, messages flow.
• Free user: tapping "Chat" on the list opens the premium upgrade screen, not the chat. No chat UI is shown to a free user.
• Astrologer offline: the list row shows "Busy" or "Offline" and the "Chat" button is replaced by the text "Offline now" in ink3. No chat is started.
• Waiting: after the user sends the first message, a system line shows "Waiting for the astrologer to reply." No invented reply time is shown.
• Astrologer typing: a small bubble with three dots in ink3, plus the text "Typing" in Caption 12 ink3.
• Message failed: the bubble shows a small maroon "Not sent. Tap to retry." below it. Tapping retries once.
• End chat: tapping "End chat" opens a confirm dialog: title "End this chat?", body "Your chat history stays saved.", actions "Cancel" and "End chat" as a maroon text button. After ending, the screen shows a closing card: "Chat ended. Thank you." with a primary button "Back to Consult" and a text button "View history".
• Session history: past chats are listed under "Past consults" on the consult list, each row showing the astrologer name, the date, and the duration. Tapping a row opens the chat in read only mode, with no composer.
• Offline: if the connection drops, a strip at the top says "You are offline. Messages will send when you are back online." Messages stay in the composer queue.
• Error: if chat fails to start, a toast says "Could not start the chat. Try again." and the user stays on the list.

## Accessibility

• Message bubbles are read in order with sender name and time.
• Timer is text, announced on request, not announced every second.
• Send button has the label "Send message".

## Data and gating

• Premium: live astrologer consult on chat and on call, by the minute or by session.
• Free: no live consult. The consult list is visible, but starting a chat opens the premium upgrade screen.
• Pricing: to be decided everywhere. No rate, no per minute figure, no session fee, and no total is shown.
• Sample data: the kundli context card uses the sample kundli. No astrologer names are invented.

## Moderation note

• Chats are reviewable in the admin panel under content moderation, per the owner scope. The user is told this once, in the consult list footnote: "Chats are reviewed for safety." No other moderation copy appears in the chat itself.
