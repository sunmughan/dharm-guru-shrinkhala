# 02 Onboarding

## Purpose

Explain the value in three simple steps and move the user to sign in. Sign in is by phone OTP and by Google, per the architecture. One account holds every saved kundli.

## Source

Presentation section Three, second phone mockup, and section Six, Firebase Auth.

## Layout, top to bottom

1. Top bar: no title. Right side only: text button "Skip" in saffron2, 44 tap height. Skip moves to sign in, not to Home, because a kundli needs an account to save.
2. Hero area, 32 top gap: sun mark 48, saffron, centred left aligned with the title below it. Layout is left aligned, not centred, after the hero mark, so the steps read like a list.
3. Title, H1 serif 28: "Know your stars in one minute"
4. Steps, 24 gap below the title, three rows, each row 16 gap:
   • Row 1, label "Step one": "Share your birth details once and your kundli stays saved forever."
   • Row 2, label "Step two": "Read your horoscope and panchang every morning with one tap."
   • Row 3, label "Step three": copy is not in the presentation mockup. Use "Talk to an astrologer live when you want a human answer." This is the third step of the journey in the presentation flow, Consult Astrologer Live, so it is drawn from the plan, not invented as a feature.
   • Each row: number in a 32 pill, saffron fill, white text in light mode and #14100C text in dark mode, then label Caption 12 semibold saffron2 above the step text Body 16 ink.
5. Page dots, 24 gap: three dots, active dot saffron and 24 wide pill, inactive dots line2 and 8 round. This screen shows all three steps on one page, so the dots mark progress through the three step rows as the user scrolls, and on a tall phone all three rows are visible at once with all dots lit in order. Simpler build: show one step per page with swipe, dots show page 1 of 3. Either build is acceptable, pick the swipe build so the dots have a real job.
6. Primary button, foot, full width, height 52: "Begin My Journey"
7. Secondary button, 12 below the primary: "I Have an Account"
8. Footnote, 12 below the secondary, centred, Caption 12 ink3: "Sign in with phone OTP or Google."

## Components

• Step row: number pill plus label plus text. No icon, no image.
• Primary button: saffron fill, per the design system.
• Secondary button: surface fill with line2 border.
• Dots: as above, 8 size, active 24 wide.

## Copy

• Title: "Know your stars in one minute"
• Step one label: "Step one"
• Step one text: "Share your birth details once and your kundli stays saved forever."
• Step two label: "Step two"
• Step two text: "Read your horoscope and panchang every morning with one tap."
• Step three label: "Step three"
• Step three text: "Talk to an astrologer live when you want a human answer."
• Primary: "Begin My Journey"
• Secondary: "I Have an Account"
• Skip: "Skip"
• Footnote: "Sign in with phone OTP or Google."

## States

• Default: page 1 of 3, "Begin My Journey" moves to the next step, on page 3 it moves to sign in.
• "I Have an Account": moves straight to sign in, skipping the remaining steps.
• "Skip": moves straight to sign in.
• Sign in screen itself is not in the presentation mockups. It follows the same system: one phone field with OTP, one Google button, same spacing and buttons. See the note at the foot of this file.
• Error: if sign in fails, the sign in screen shows the error, not this screen.

## Accessibility

• Step numbers are text, so a screen reader reads "Step one" in order.
• Dots have the text "Page 1 of 3" as their accessible label.
• Buttons meet the 44 tap target and the 52 height.

## Data and gating

• No sample data. No kundli is shown yet.
• No premium mention on this screen. Premium is introduced only on Home and on the premium upgrade screen.

## Build note

• Sign in screen: not a numbered screen in this set because the presentation shows onboarding moving to sign in without a mockup. Build it from this system: title "Welcome back" for returning users and "Create your account" for new users, phone field, "Send OTP" primary button, divider with the word "or", Google button as secondary, footnote "One account holds every saved kundli." No other copy.
