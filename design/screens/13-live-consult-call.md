# 13 Live Consult, Call

## Purpose

Let the user call a live astrologer inside the app, with a clear start, a clear timer, and a simple end. Call is premium, by the minute or by session, per the presentation. Pricing is to be decided, so no rate is shown.

## Source

Presentation section Five, Consult Layer and Premium Layer, and section Seven, User Scope premium.

## Layout, top to bottom

1. Full screen, fill bg2 light #FDEBD0, dark #1D1710. No image, no blend, no pattern.
2. Centre, 48 top gap: avatar pill 96 with astrologer initials, saffron pair fill, initials in white light mode and #14100C dark mode, Title 17 semibold in the avatar at 32 size. No astrologer name is invented. The name shown is the name from the astrologer list, supplied by the admin panel.
3. Below the avatar, 16 gap: astrologer name H1 serif 28, centred.
4. Below the name, 8 gap: status Caption 12 semibold good green "Online" or, during a call, the timer in Title 17 semibold ink, starting at "00:00" and counting up.
5. Below the status, 8 gap: Body small 14 ink2, centred: "Call consult. Pricing to be decided."
6. Kundli context line, 24 below, centred, Body small 14 ink2: "Sharing your kundli: Aarav Sharma, Meena Lagna, Kanya Rashi." (Sample data)
7. Call controls, foot, 48 above the safe area, centred row with three controls, 24 gap:
   • Mute: pill 56, surface fill, line2 border, mute icon 24 ink. Active mute state is saffron fill with white icon in light mode and #14100C icon in dark mode, plus the label "Muted" in Caption 12 below it.
   • End call: pill 72, maroon fill #7C2D12 light and #FDBA74 dark, phone down icon in white light mode and #14100C dark mode, 28 size. This is the only maroon filled control in the app, and it is used only here because ending a call must be found at once.
   • Speaker: pill 56, surface fill, line2 border, speaker icon 24 ink. Active speaker state is saffron fill, same as mute.
   • Labels below each control in Caption 12 ink2: "Mute", "End", "Speaker".
8. No bottom tabs on this screen. No composer. No chat link during a call, except a text button "Switch to chat" below the controls that ends the call and opens chat only if the astrologer is also available for chat. That switch asks for confirmation first.

## Call flow states on this screen

• Outgoing, ringing: status reads "Calling", timer hidden, end call control active, mute and speaker disabled with ink3 icons.
• Connected: status becomes the timer "00:00" counting up, mute and speaker enabled.
• Astrologer busy or no answer: after the ringing period set by the call system, the screen shows "No answer." with a primary button "Try again" and a text button "Chat instead". No invented wait time is shown.
• Call ended by the astrologer: screen shows "Call ended." with duration in Body 16 ink, for example "Call duration 12 minutes 30 seconds.", primary button "Back to Consult", text button "View history".
• Call ended by the user: same ended state, same copy, with the duration from the timer.
• Connection lost: status reads "Connection lost. Reconnecting." in maroon, timer pauses, controls stay, and the call resumes if the connection returns within the period set by the call system. If it does not return, the call ends and the ended state shows.
• Error: if the call fails to start, a toast says "Could not start the call. Try again." and the user stays on the consult list.

## Components

• Large avatar with initials.
• Name, status, and timer.
• Pricing note line.
• Kundli context line.
• Three call controls: mute, end, speaker.

## Copy

• Status ringing: "Calling"
• Status connected: timer, for example "00:00"
• Pricing line: "Call consult. Pricing to be decided."
• Context line: "Sharing your kundli: Aarav Sharma, Meena Lagna, Kanya Rashi." (Sample data)
• Control labels: "Mute", "End", "Speaker"
• Muted state: "Muted"
• No answer: "No answer."
• No answer actions: "Try again", "Chat instead"
• Ended title: "Call ended."
• Ended duration: "Call duration 12 minutes 30 seconds." (Example format only, real duration comes from the timer)
• Ended actions: "Back to Consult", "View history"
• Connection lost: "Connection lost. Reconnecting."
• Switch action: "Switch to chat"

## Accessibility

• End call is the largest control, 72 size, and is announced as "End call".
• Timer is text, announced on request, not announced every second.
• Mute and speaker announce their on and off state.

## Data and gating

• Premium: live astrologer consult on chat and on call, by the minute or by session.
• Free: tapping "Call" on the consult list opens the premium upgrade screen, not the call screen.
• Pricing: to be decided everywhere. No rate, no per minute figure, no session fee, and no total is shown on this screen or after the call.
• Sample data: the kundli context line uses the sample kundli. No astrologer names are invented.

## Moderation note

• Call history, duration, and timing are recorded for session history in the admin panel. Call audio recording is not in the presentation scope and is not designed here. If the client wants recording, it needs a separate decision and a clear notice to both sides before the call starts.
