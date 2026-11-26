# 14 Premium Upgrade

## Purpose

Explain what premium unlocks, in the exact words of the presentation, and let the user upgrade. Pricing is to be decided, so this screen shows no price, no trial length, and no currency. It never invents a price to fill the space.

## Source

Presentation section Five, Features and Layers, Premium Layer, and section Seven, User Scope premium.

## Layout, top to bottom

1. Top bar: close icon on the left, title "Premium" in H3 serif 18. No right action. Closing returns to the screen the user came from.
2. Hero, 16 below the top bar: sun mark 48 saffron, then title H1 serif 28 "Go deeper with Premium", then Body 16 ink2 "Depth, detail, and human guidance, built on your own kundli."
3. Benefit list, 24 below the hero, seven rows, each a standard card row with a saffron check mark 20 on the left and text on the right. Each row is Title 17 ink for the benefit name, with Body small 14 ink2 below it:
   • "Full planet detail", "Exact degrees, bhava reading, and swami analysis."
   • "Detailed matching", "Dosha analysis and a written milan report."
   • "Personal remedies plan", "Built from your own kundli."
   • "Live astrologer consult", "Chat and call inside the app."
   • "Yearly and monthly horoscope", "Dasha based guidance through the year."
   • "Muhurat alerts for personal events", "Griha pravesh, vivah, and more."
   • "Unlimited family kundlis", "Save every family chart, with priority support."
4. Pricing card, standard card, padding 20, 16 below the benefit list, centred: overline "Pricing" in Caption 12 semibold saffron2, value H2 serif 22 "To be decided", body Body small 14 ink2 "Premium pricing is to be decided. No payment is taken on this screen."
5. Primary button, foot, full width, 24 gap above it: "Upgrade to Premium". Because pricing is to be decided, this button is shown in a disabled state in version 1, with line fill and ink3 text, and a footnote below it explains why. Do not enable it with an invented price. When pricing is decided, the button becomes active and the pricing card shows the decided price.
6. Footnote, 12 below the button, centred, Caption 12 ink3: "Upgrade opens when pricing is decided. Your free plan stays as it is until then."
7. Text button, 12 below the footnote, centred: "Continue with Free". Tapping it closes the screen and returns to the previous screen.

## Components

• Hero with sun mark and title.
• Seven benefit rows with check marks.
• Pricing card with "To be decided".
• Disabled primary button in version 1.
• "Continue with Free" text button.

## Copy

• Title: "Premium"
• Hero title: "Go deeper with Premium"
• Hero body: "Depth, detail, and human guidance, built on your own kundli."
• Benefit rows: as listed in section 3 above, exactly as written.
• Pricing overline: "Pricing"
• Pricing value: "To be decided"
• Pricing body: "Premium pricing is to be decided. No payment is taken on this screen."
• Primary: "Upgrade to Premium"
• Footnote: "Upgrade opens when pricing is decided. Your free plan stays as it is until then."
• Secondary: "Continue with Free"

## States

• Default, free user: as above, primary button disabled, pricing card "To be decided".
• Premium user: this screen is not shown. A premium user tapping a premium entry goes straight to the feature. If a premium user opens this screen from Profile, it shows a confirmation card instead: "You are on Premium." with a text button "Back to Profile". No upgrade button.
• Pricing decided, future state: pricing card shows the decided price, primary button becomes active saffron fill, footnote changes to the decided terms supplied by the client. No other layout change.
• Error: if the upgrade action fails in the future active state, a toast says "Upgrade could not be completed. Try again." The user stays on this screen.
• Restore: if the platform supports restore, a text button "Restore purchase" sits below "Continue with Free" in the future active state only. It is hidden in version 1 because no purchase exists yet.

## Accessibility

• Benefit rows are a list, read in order, each with its check mark announced as "Included".
• Disabled button is announced as disabled, with the footnote explaining why.
• Pricing value "To be decided" is text, never a blank space or a zero price.

## Data and gating

• Free: everything on the free layer stays free. This screen never removes a free feature.
• Premium: the seven benefits above, exactly as listed in the presentation. No eighth benefit is added.
• Pricing: to be decided everywhere. No price, no trial length, no currency, and no discount is shown.

## Open question

• Pricing is the only open question on this screen, and it blocks the upgrade action. The screen is designed to wait for it honestly, with a disabled button and a clear note, rather than inventing a price.
