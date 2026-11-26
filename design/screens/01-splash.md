# 01 Splash

## Purpose

Open the app with the brand mark and set a calm sacred tone in two seconds. No action is asked here. No content is read here.

## Source

Presentation section Three, first phone mockup. Presentation copy: "Opens the app with the brand mark and sets a calm sacred tone in two seconds."

## Layout, top to bottom

1. Full screen fill `color.bg` light #FFF7E8, dark #14100C. No image, no blend, no pattern.
2. Centre, vertical middle: sun mark, 64 size, saffron #D96C00 light, #F59E0B dark. One mark only.
3. Below the mark, 24 gap: wordmark "Dharm Guru" in Display serif 32, ink.
4. Below the wordmark, 8 gap: tagline "Your kundli. Your guidance. Every single day." in Body 16, ink2, centred.
5. Below the tagline, 12 gap: three small dots in a row, centre dot saffron, outer dots line2. These are a calm loading mark, not a carousel control.
6. Foot, 48 above the safe area: no button, no link, no version text.

## Components

• Sun mark: drawn mark, flat saffron, no blend. Same mark as the app icon.
• Wordmark: serif only. Never set the wordmark in sans.
• Tagline: one line on wide phones, two lines centred on narrow phones. Never more than two lines.

## Copy

• Wordmark: "Dharm Guru"
• Tagline: "Your kundli. Your guidance. Every single day."
• No other visible copy.

## States

• Default: shown for up to two seconds while the app checks sign in state, then moves on. No progress bar.
• Signed in user: Splash moves to Home.
• Signed out user: Splash moves to Onboarding.
• Saved kundli exists: Splash moves to Home, not to the input form.
• Slow load: after two seconds the dots keep their calm pulse and the tagline stays. No error is shown until the load fails, then a toast says "Could not open the app. Check your connection and try again." with a single "Try again" text button.
• Offline at launch: same slow load state. Cached Home is shown if a kundli is saved, per the architecture note that Firestore caching keeps the kundli ready on weak networks.

## Accessibility

• Wordmark contrast is ink on bg in both modes.
• The sun mark is decorative and has no text equivalent needed. The wordmark is the accessible name.
• No motion beyond the gentle dot pulse. No flashing.

## Data and gating

• No data is shown. No free or premium state is shown.
• No sample data on this screen.

## Open question

• None. This screen is fully decided by the presentation.
