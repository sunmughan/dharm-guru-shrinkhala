# Dharm Guru Shrinkhala Design

Design lead deliverable, 26 November 2026. Source of truth: presentation artifact `dharm-guru-app-presentation`. Repo: `sunmughan/dharm-guru-shrinkhala`.

## How to read this folder

• `DESIGN-SYSTEM.md` is the single system for every screen. Read it first. No screen invents its own colour, type, spacing, or button.
• `screens/` holds one file per screen, user app first, then admin panel. Each file gives layout top to bottom, components, exact copy, states, and gating.
• `flows/` holds six UX flows: kundli chart readability, panchang clarity, matching, remedies, live consult, premium upgrade.
• Sample data is labelled "Sample data" in every file. The sample kundli is birth 14 March 1998, Jaipur, Surya in Meena lagna at 01° 24′. Pricing is "to be decided" everywhere. No astrologer names, no real horoscope predictions, and no prices are invented anywhere in this folder.

## Screen index

User app

1. `screens/01-splash.md` Splash
2. `screens/02-onboarding.md` Onboarding
3. `screens/03-home.md` Home
4. `screens/04-kundli-input-form.md` Kundli input form
5. `screens/05-kundli-chart.md` North Indian square kundli chart
6. `screens/06-planet-details.md` Planet details
7. `screens/07-daily-horoscope.md` Daily horoscope
8. `screens/08-panchang.md` Panchang
9. `screens/09-kundli-matching.md` Kundli matching
10. `screens/10-remedies.md` Remedies
11. `screens/11-profile.md` Profile
12. `screens/12-live-consult-chat.md` Live consult, chat
13. `screens/13-live-consult-call.md` Live consult, call
14. `screens/14-premium-upgrade.md` Premium upgrade
15. `screens/15-notifications.md` Notifications

Admin panel

16. `screens/16-admin-dashboard.md` Admin dashboard
17. `screens/17-manage-astrologers.md` Manage astrologers
18. `screens/18-publish-daily-horoscope.md` Publish daily horoscope content
19. `screens/19-subscriptions-and-payments.md` Subscriptions and payments
20. `screens/20-analytics-and-revenue.md` Analytics and revenue
21. `screens/21-push-notifications.md` Push notifications
22. `screens/22-content-moderation.md` Content moderation

## UX flows

1. `flows/01-kundli-chart-readability.md` Kundli chart readability
2. `flows/02-panchang-clarity.md` Panchang clarity
3. `flows/03-matching-flow.md` Matching flow
4. `flows/04-remedies-flow.md` Remedies flow
5. `flows/05-live-consult-flow.md` Live consult flow
6. `flows/06-premium-upgrade-flow.md` Premium upgrade flow

## Rules that apply to every file

• One clear hierarchy per screen. One primary action per screen.
• Generous white space. One idea per card.
• Free and premium gating follows the presentation exactly. Free: daily horoscope for all twelve rashi, basic kundli, full panchang, shubh muhurat with rahu kaal warning, one matching each day, general remedies, daily notifications. Premium: full planet detail, detailed matching with dosha analysis and written milan report, personal remedies plan, live consult by chat and call, yearly and monthly horoscope with dasha guidance, muhurat alerts for personal events, unlimited saved family kundlis, priority support.
• No hyphen and no em dash in visible copy.
• Open questions live only in `DESIGN-SYSTEM.md` section 16. Screen files do not add new open questions unless a screen cannot be built without the answer, in which case the question is listed at the foot of that screen file.
