# Flow 06 Premium Upgrade Flow

## Goal

A free user who hits a premium feature understands what premium unlocks, sees that pricing is to be decided, and is never pushed into a payment that does not exist yet. The upgrade screen waits honestly for pricing, with a disabled button and a clear note, rather than inventing a price.

## Screens involved

• `screens/14-premium-upgrade.md` for the upgrade screen itself
• Every screen with a premium gate: planet details, daily horoscope weekly view, matching full report, remedies personal plan, live consult chat and call, profile plan card

## Flow, step by step

1. Trigger: user taps a premium feature. Triggers are: "See Planet Details" depth beyond the basic chart, "Read Weekly Horoscope" or "Weekly" on horoscope, "View Full Milan Report" on matching, "Ask About a Remedy" on remedies, "Chat" or "Call" on the consult list, "View premium" on profile or on planet details.
2. Upgrade screen opens, with the close icon returning to the screen the user came from. The screen does not replace the previous screen. Closing returns exactly where the user was.
3. User reads the hero: "Go deeper with Premium" and "Depth, detail, and human guidance, built on your own kundli."
4. User reads the seven benefit rows, each with a saffron check mark:
   • Full planet detail, exact degrees, bhava reading, and swami analysis.
   • Detailed matching, dosha analysis and a written milan report.
   • Personal remedies plan, built from your own kundli.
   • Live astrologer consult, chat and call inside the app.
   • Yearly and monthly horoscope, dasha based guidance through the year.
   • Muhurat alerts for personal events, griha pravesh, vivah, and more.
   • Unlimited family kundlis, save every family chart, with priority support.
5. User reads the pricing card: overline "Pricing", value "To be decided", body "Premium pricing is to be decided. No payment is taken on this screen."
6. Version 1 end state: primary button "Upgrade to Premium" is disabled, with line fill and ink3 text. Footnote reads "Upgrade opens when pricing is decided. Your free plan stays as it is until then." User taps "Continue with Free" to close and return.
7. Future state, when pricing is decided: pricing card shows the decided price, primary button becomes active saffron fill, footnote changes to the decided terms supplied by the client, and tapping the button starts the platform purchase flow. No other layout change.
8. After purchase, future state: the user returns to the screen that triggered the upgrade, and the premium feature opens directly. The upgrade screen is not shown again to a premium user. If a premium user opens it from Profile, it shows "You are on Premium." with a text button "Back to Profile".

## Flow rules

• The free layer never shrinks. Daily horoscope for all twelve rashi, basic kundli, full panchang, shubh muhurat with rahu kaal warning, one matching each day, general remedies, and daily notifications stay free after the upgrade screen is shown.
• The score on matching is free. The written milan report is premium. The chart is free. Full planet degrees are premium. The daily horoscope is free. The weekly view is premium. The general remedies are free. The personal plan is premium.
• No price, no trial length, no currency, and no discount is shown anywhere in this flow until the client decides pricing.
• No dark pattern: no countdown, no "only a few left", no pre checked box, no close icon hidden. Close is always visible at the top left.
• One upgrade screen for every trigger. No trigger gets its own special paywall copy. The benefit list is the same seven rows every time.

## Failure paths

• Upgrade action fails, future active state: toast "Upgrade could not be completed. Try again." User stays on the upgrade screen.
• Purchase interrupted, future active state: user returns to the upgrade screen with the same state. No charge is assumed. The app checks the real purchase state before showing any premium feature.
• Restore, future active state: text button "Restore purchase" sits below "Continue with Free". It is hidden in version 1 because no purchase exists yet.

## Open question

• Pricing is the only open question in this flow, and it blocks the upgrade action. The client must decide price, trial length, currency, and plan lengths before the button is enabled. No price is invented in this design.
