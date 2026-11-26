# Flow 05 Live Consult Flow

## Goal

A user with a question reaches a live astrologer by chat or by call in three taps, with the astrologer seeing the shared kundli, so the user never retypes birth details. The cost basis is always visible, and pricing stays "to be decided" until the client decides it.

## Screens involved

• `screens/03-home.md` for the consult banner
• `screens/12-live-consult-chat.md` for chat
• `screens/13-live-consult-call.md` for call
• `screens/14-premium-upgrade.md` for the premium gate
• `screens/22-content-moderation.md` for chat review on the admin side

## Flow, step by step

1. Entry: user taps "Consult" in the bottom tabs, or "Consult now" on the Home banner, or "Ask About a Remedy" on Remedies. All three entries land on the same consult list.
2. Consult list: astrologer rows show avatar with initials, name, languages, and a status pill "Online", "Busy", or "Offline". No rating is shown unless the admin panel supplies one. No name is invented.
3. Premium gate: a free user tapping "Chat" or "Call" is taken to the premium upgrade screen. No chat UI and no call UI is shown to a free user. A premium user proceeds.
4. Choice: user taps "Chat" to open the chat screen, or the phone icon to open the call screen. The choice is made on the list row, not after the session starts.
5. Chat: session strip reads "Chat consult. Pricing to be decided." with a timer counting up from "00:00". The kundli context card is pinned above the composer: "Sharing your kundli: Aarav Sharma, Meena Lagna, Kanya Rashi, born 14 March 1998, Jaipur." The user can hide it. Messages flow in bubbles. The astrologer sees the shared kundli.
6. Call: avatar, name, and status, then the timer on connect, then three controls: Mute, End, Speaker. End is the largest control at 72 size, maroon fill. The kundli context line reads "Sharing your kundli: Aarav Sharma, Meena Lagna, Kanya Rashi."
7. Switch: during a call, "Switch to chat" asks for confirmation, ends the call, and opens chat only if the astrologer is also available for chat.
8. End: ending a chat or a call shows a closing state with the duration and two actions, "Back to Consult" and "View history". The session appears under "Past consults" on the list, in read only mode.

## Flow rules

• Three taps maximum from Home to a live session: Home to Consult list, list to astrologer, astrologer to Chat or Call.
• Kundli is shared by the app, not retyped by the user. The context card or line is visible at the start of every session.
• Timer counts up from "00:00" in every session. No rate, no per minute figure, and no total is shown anywhere, because pricing is to be decided.
• Offline astrologer: the row shows "Offline now" in ink3 and no Chat or Call button. No session is started.
• No answer on a call: the screen shows "No answer." with "Try again" and "Chat instead". No invented wait time is shown.
• Moderation: chats are reviewable in the admin panel. The consult list carries one footnote: "Chats are reviewed for safety." Call audio recording is not in scope and is not designed here.

## Failure paths

• Chat fails to start: toast "Could not start the chat. Try again." User stays on the list.
• Call fails to start: toast "Could not start the call. Try again." User stays on the list.
• Message fails to send: bubble shows "Not sent. Tap to retry." Tapping retries once.
• Connection lost during a call: status reads "Connection lost. Reconnecting." Timer pauses. If the connection does not return, the call ends and the ended state shows with the duration so far.
• Offline during chat: strip at the top reads "You are offline. Messages will send when you are back online." Messages stay queued.

## Open questions

• Rate structure: confirm whether consult is priced by the minute, by session, or both, and in which currency, before any rate appears in this flow. The session strip will carry the decided basis.
• Call recording: confirm whether call audio is recorded. If yes, it needs a separate decision and a clear notice to both sides before the call starts. It is not designed here.
