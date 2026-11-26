# Dharm Guru Shrinkhala Design System

Version 1.0. Date 26 November 2026. Status: design lead draft for client review.
Source: presentation artifact `dharm-guru-app-presentation`. Every token below is taken from that presentation. Nothing here invents a new colour, a new feature, or a new price.

## 1. Idea in one line

Saffron carries action and blessing, deep ink carries text and the chart lines, and warm sand carries rest. Serif headings feel like a printed panchang while rounded body type keeps daily use friendly on any phone.

## 2. Colour tokens

All values are exact hex values from the presentation. Light tokens first, dark tokens second. Use the token name in code, never a raw hex value in a screen file.

| Token | Light | Dark | Use |
| --- | --- | --- | --- |
| `color.bg` | #FFF7E8 | #14100C | App background |
| `color.bg2` | #FDEBD0 | #1D1710 | Secondary background, top band, gentle wash |
| `color.surface` | #FFFFFF | #201913 | Cards, sheets, dialogs |
| `color.surface2` | #FFF3DE | #2A2118 | Soft card, selected chip, chart legend wash |
| `color.ink` | #211712 | #F7EBD7 | Primary text, chart lines |
| `color.ink2` | #5B4A3A | #D8C4A6 | Secondary text |
| `color.ink3` | #8A7460 | #A68F73 | Caption text, inactive icons |
| `color.saffron` | #D96C00 | #F59E0B | Primary action, active state, chart accent |
| `color.saffron2` | #B45309 | #FBBF24 | Text link, pressed action, small saffron text |
| `color.maroon` | #7C2D12 | #FDBA74 | Deep accent, secondary border on flow cards, warning text in dark use only with care |
| `color.gold` | #C99A2E | #E3B94E | Stars, lucky detail, thin rule on premium cards |
| `color.line` | #EBD9BC | #3A2E20 | Card border, divider |
| `color.line2` | #DCC49A | #54432C | Stronger border, input border, chip border |
| `color.good` | #2F7D4F | #7BC796 | Success, good match, on state |
| `color.phonebg` | #FFFDF8 | #1B1510 | Screen background inside a phone frame in presentation only |

### 2.1 Brand mark pair

The brand mark and the avatar use one flat pair only: #F59E0B to #B45309. This is the single permitted blend in the whole product, and it is used only for the sun mark and for an avatar with initials. No other blend is permitted anywhere. No screen background uses a blend. No card uses a blend.

### 2.2 Light usage

1. Page background is `color.bg`.
2. Cards sit on `color.surface` with a 1px `color.line` border.
3. Primary text is `color.ink`. Secondary text is `color.ink2`. Captions are `color.ink3`.
4. Primary buttons are `color.saffron` fill with white text.
5. The kundli chart uses `color.ink` lines on `color.surface`, with `color.saffron` only for the lagna marker and the active cell edge.

### 2.3 Dark usage

1. Page background is `color.bg` dark value #14100C.
2. Cards sit on `color.surface` dark value #201913 with a 1px `color.line` dark value #3A2E20 border.
3. Primary text is #F7EBD7. Secondary text is #D8C4A6. Captions are #A68F73.
4. Primary buttons are `color.saffron` dark value #F59E0B fill with #14100C text. White text on #F59E0B is not permitted because contrast is weak.
5. The kundli chart uses #F7EBD7 lines on #201913, with `color.saffron` dark value #F59E0B only for the lagna marker.
6. Shadows are soft black at 45 percent opacity. Light shadows use maroon at 10 percent opacity, exactly as in the presentation.

### 2.4 Colour rules

• Saffron is for action, blessing, and one focal point per screen. Never use saffron for body text.
• Maroon is for a secondary accent only, never for a full button or a full card.
• Gold is for stars and lucky details only.
• Green `color.good` is for success and good match states only, never for decoration.
• No other colour is introduced. Festival art, if the client supplies it later, must sit inside a card and must not change these tokens.

## 3. Type

### 3.1 Families

• Headings: Georgia, fallback Times New Roman, serif. In Flutter use a serif family with Georgia as the preferred face and the platform serif as fallback.
• Body and UI: system rounded sans. Stack: ui rounded, system-ui, Segoe UI, Roboto, Helvetica, Arial, sans-serif. In Flutter use the platform system font.
• Numbers in the chart and in planet degrees use the body family, tabular figures on, so columns align.

### 3.2 Scale

| Style | Size | Weight | Line height | Use |
| --- | --- | --- | --- | --- |
| Display | 32 | 700 serif | 1.15 | Splash wordmark, one hero number only |
| H1 | 28 | 700 serif | 1.2 | Screen title on home and chart |
| H2 | 22 | 700 serif | 1.2 | Section title inside a screen |
| H3 | 18 | 700 serif | 1.25 | Card title |
| Title | 17 | 600 sans | 1.3 | List row title, dialog title |
| Body | 16 | 400 sans | 1.55 | Main reading text |
| Body small | 14 | 400 sans | 1.5 | Secondary reading text |
| Caption | 12 | 600 sans | 1.4 | Labels, meta, table header |
| Overline | 11 | 700 sans | 1.4 | Eyebrow label, uppercase, letter spacing 0.08em |

### 3.3 Type rules

• One serif heading per screen at most in the top area. Everything below it is sans.
• Minimum body size is 14. Chart rashi labels are 13 minimum, planet abbreviations are 14 semibold minimum, so elders can read the chart without zoom.
• Headings are sentence case, never all caps, except the 11 point overline label.
• Copy is plain and simple. No horoscope prediction is written by design. All prediction copy comes from published content in the admin panel.
• No hyphen and no em dash in any visible copy. Write "09:42 AM to 11:15 AM" not a range with a dash. This rule applies to every screen file in this folder.

## 4. Spacing grid

Base unit is 4. All spacing uses multiples of 4.

| Token | Value | Use |
| --- | --- | --- |
| `space.1` | 4 | Tight gap inside a chip |
| `space.2` | 8 | Gap between label and value, icon and text |
| `space.3` | 12 | Gap between cards in a tight list |
| `space.4` | 16 | Screen side padding, gap between sections |
| `space.5` | 20 | Card inner padding on large cards |
| `space.6` | 24 | Gap between major sections |
| `space.8` | 32 | Gap before a primary action at the foot of a form |
| `space.12` | 48 | Top breathing space on splash and empty states |

Rules: screen side padding is 16 on phones. Card padding is 16, or 20 on a hero card. Section gap is 16. Nothing is flush to the screen edge except the top band wash and the bottom tab bar.

## 5. Corner radius

| Token | Value | Use |
| --- | --- | --- |
| `radius.card` | 18 | Cards, chart frame, sheets content |
| `radius.small` | 14 | Small cards, inputs, chart cells are square inside the chart frame, see section 9 |
| `radius.pill` | 999 | Buttons, chips, tabs, avatar |
| `radius.sheet` | 24 top only | Bottom sheets |

The kundli chart itself has radius 16 on its outer frame. The twelve bhava cells inside it are square, with 1px ink lines, because the North Indian square chart is a geometric figure, not a card grid.

## 6. Buttons

### 6.1 Primary

• Fill `color.saffron`, text white in light mode and #14100C in dark mode.
• Height 52, pill radius, full width on forms, content width plus 32 side padding on cards.
• Label 16 semibold, one action per screen as the primary.
• Pressed state: fill `color.saffron2` in light mode, #FBBF24 in dark mode.
• Disabled state: fill `color.line`, text `color.ink3`, no saffron.

### 6.2 Secondary

• Fill `color.surface`, 1px `color.line2` border, text `color.ink`.
• Height 52, pill radius.
• Use for the second action only, for example "I Have an Account" on onboarding.

### 6.3 Text button

• No fill, no border, text `color.saffron2`, 16 semibold, minimum tap area 44 by 44.
• Use for "View", "See all", "Edit", and similar low weight actions.

### 6.4 Destructive

• Text button in maroon, used only in admin for "Remove" and in profile for "Sign out" and "Delete saved kundli". No filled red button exists in this system.

### 6.5 Button rules

• Minimum tap target is 44 by 44 everywhere.
• One primary button per screen. A second primary button on the same screen is a design fault.
• Button copy is a verb phrase: "Generate My Kundli", "View Full Milan Report", "Start Chat", "Publish Now".
• Loading state keeps the button size, shows a spinner in place of the label, and disables taps.

## 7. Cards

### 7.1 Standard card

• Fill `color.surface`, 1px `color.line` border, radius 18, padding 16, soft shadow as in section 2.
• Card title is H3 serif 18. Card body is Body 16 or Body small 14.
• One card holds one idea: horoscope, tithi, muhurat, remedy, astrologer. Never stack two ideas in one card.

### 7.2 Hero card

• Fill `color.surface2` in light mode, `color.surface` in dark mode, 1px `color.line2` border, radius 18, padding 20.
• Used once per screen at most, for the horoscope of the day on Home and for the match score on Matching.
• Hero card carries the gold star row where a rating is shown.

### 7.3 Info strip

• Fill `color.surface2`, radius 14, padding 12, Body small 14, ink2 text.
• Used for notes such as "Place search fills latitude and longitude on its own so the chart stays accurate" and for Rahu Kaal warnings.

### 7.4 Card rules

• Generous white space is mandatory. If a card needs a third action, split it into two cards.
• No card uses a blend, a photo background, or a decorative pattern.
• Dividers inside a card are 1px `color.line`, never a heavy rule.

## 8. Inputs and forms

• Field height 52, radius 14, fill `color.surface`, 1px `color.line2` border, padding 12 left and right.
• Label is Caption 12 semibold in `color.ink2`, placed above the field with an 8 gap.
• Value text is Body 16 in `color.ink`.
• Focus state: border `color.saffron`, 2px, plus a soft saffron wash at 8 percent opacity outside the border. No other focus treatment.
• Error state: border maroon, message in maroon Body small 14 below the field, with the field label unchanged.
• Helper text is Caption 12 in `color.ink3` below the field.
• Date and time fields open the platform picker. Place uses search with suggestions. The form never asks for latitude and longitude by hand.
• Required fields are marked by the word "Required" in Caption 12, never by a red star alone.

## 9. Kundli chart

This is the visual heart of the app and it has its own strict rules. See `screens/05-kundli-chart.md` and `flows/01-kundli-chart-readability.md` for the full spec.

• Outer frame: square, radius 16, 1px `color.ink` border, fill `color.surface`.
• Twelve bhavas in the classic North Indian square layout. Fixed geometry, never a list and never a circle.
• Each bhava shows the rashi name in 13 semibold ink2 at the top of the cell, and planet abbreviations in 14 semibold ink in the centre.
• Lagna cell carries a small saffron diamond marker and the word "Lagna" in saffron2.
• No colour fill inside a bhava cell. No gradient. No emoji. Planet symbols are two letter abbreviations: Su, Mo, Ma, Me, Ju, Ve, Sa, Ra, Ke, plus As for Lagna.
• The chart is readable at 320 width. If a cell would hold more than three planet abbreviations, the cell shows the first three and a "+1" count in Caption 12, and the full list sits directly below the chart.

## 10. Tabs and navigation

### 10.1 Bottom tabs, user app

Five tabs, fixed order: Home, Kundli, Panchang, Consult, Profile.
• Bar height 64 plus safe area, fill `color.surface`, top border 1px `color.line`.
• Icon 24, label 11 semibold below the icon.
• Active tab: icon and label in `color.saffron`. Inactive tab: icon and label in `color.ink3`.
• A small saffron dot above the Consult icon marks an active consult only. No badge counts are invented.

### 10.2 Top bar

• Height 56, title H3 serif 18 on the left, one action icon on the right at most.
• No top bar carries more than one action. Extra actions live in the screen body.

### 10.3 Segmented control

• Used for Free Layer and Premium Layer on the features view, and for Lagna Chart and Moon Chart on the chart screen.
• Pill container in `color.surface2`, selected segment in `color.surface` with a 1px `color.line2` border and saffron text, unselected segment in ink2 text.
• Height 40, label 14 semibold.

### 10.4 Admin navigation

• Left rail on wide screens, 240 wide, fill `color.surface`, with the same five plus two pattern: Dashboard, Astrologers, Daily Content, Subscriptions, Analytics, Notifications, Moderation.
• Active item has a 3px saffron bar on its left edge and saffron text. Inactive items are ink2.
• On narrow screens the rail becomes a top bar with a menu button. The order never changes.

## 11. Chips, stars, and status

• Chip: pill radius, height 32, padding 7 left and right 13, 1px `color.line2` border, fill `color.surface`, label 13 semibold ink2. Selected chip: fill `color.saffron`, border saffron, text white in light mode and #14100C in dark mode.
• Stars: gold #C99A2E light and #E3B94E dark, size 16, five stars, filled or outline only. A rating is written as "4 of 5" in text next to the stars for screen readers.
• Status pill: radius 999, height 28, padding 4 top and bottom, 10 left and right, label 12 semibold. Good is `color.good` text on a `color.good` wash at 12 percent opacity. Waiting is saffron2 text on a saffron wash at 12 percent opacity. Blocked is maroon text on a maroon wash at 12 percent opacity.
• No status is shown by colour alone. The word is always present.

## 12. Icons

• Line icons only, stroke 1.5, size 24 for navigation, 20 for list rows, 16 for inline use.
• Icon colour follows text colour in the same row. Active navigation uses saffron. Inactive uses ink3.
• No emoji as icons. No filled icon set. The sun mark is a drawn mark, used only on Splash, on empty states, and in the top band of the presentation, never as a repeating decoration.
• Named icons in specs: home, chart, calendar, chat, phone, person, bell, search, chevron, star, sun, moon, plus, check, alert. If Flutter has no exact match, use the closest line icon and note it in the build log. Do not draw a new icon set.

## 13. Motion and feedback

• Duration 200 ms for taps and tab changes, 300 ms for sheets and screen transitions. No bounce, no long fade.
• Haptic: light tap on primary button press only.
• Loading: a single saffron spinner, 24 size, centred, with the words "Loading" in Caption 12 below it. No skeleton shimmer with a blend.
• Toast: dark ink pill, white text in light mode, surface text in dark mode, 14 semibold, shown for 3 seconds at the foot of the screen above the tab bar.
• Empty state: sun mark 48, H3 title, Body small explanation, one primary button. No illustration library.

## 14. Accessibility

• Text contrast: ink on surface and saffron2 text on surface meet the standard contrast target in both modes. White text on light saffron #D96C00 is the only white on saffron pair permitted.
• Minimum tap target 44 by 44. Chart cells are not tap targets for small text; the "See Planet Details" button below the chart is the tap target.
• Every image and every star row has a text equivalent.
• Dynamic type is supported. Layouts wrap instead of clipping when text grows.
• Dark mode follows the system setting. There is no in app theme switch in version 1. That choice is open for client input, see section 16.

## 15. Sample data rule

Sample data is labelled "Sample data" wherever it appears in a screen spec, and the app must label it the same way until real data replaces it. The one sample kundli used across every screen is:

• Name: Aarav Sharma. Sample name from the presentation.
• Birth: 14 March 1998, 06:25 AM, Jaipur, Rajasthan.
• Lagna Meena, Rashi Kanya, Nakshatra Hasta, Tithi at Birth Krishna Dwitiya, Age 28 years 8 months as shown in the presentation.
• Surya in Meena lagna at 01° 24′. Full planet table is in `screens/06-planet-details.md`.
• Second sample name for matching only: Priya, Karka Lagna.

No other names, no real horoscope predictions, and no prices appear anywhere in this design folder.

## 16. Open questions for the client

These are the only decisions this system leaves open. Nothing else is undecided by design.

1. Pricing. Premium pricing is to be decided. No price, no trial length, and no currency is shown in any screen.
2. In app theme switch. Dark mode follows the system setting in this draft. Confirm if a manual switch is wanted.
3. Language. All copy in this folder is English. Confirm if Hindi copy is wanted in version 1, and who supplies it.
4. Astrologer identity. No astrologer names appear in this design. Confirm how astrologer profiles are supplied and approved.
5. Chart variant. The Moon Chart segment is shown as a switcher on the chart screen, following the wireframe note "Chart Switcher". Confirm if Moon Chart ships in version 1 or in a later phase.
6. Notification timing. The horoscope alert time 06:00 AM is from the presentation profile screen. Confirm the default time and whether the user can change it.

## 17. File map

• This file: `design/DESIGN-SYSTEM.md`
• Screen specs: `design/screens/01-splash.md` to `design/screens/22-content-moderation.md`
• UX flows: `design/flows/01-kundli-chart-readability.md` to `design/flows/06-premium-upgrade-flow.md`
• Index: `design/README.md`
