# Dharm Guru Shrinkhala brand mark

## The mark

Om on a saffron sun disc, twelve rays around it, a gold rashi
ring with twelve ticks. One look says astrology and dharma.
No generic letterform, no emoji, no icon font.

## Colours

All colours are the design system tokens in
`design/DESIGN-SYSTEM.md`:

- Sun disc and rays: saffron `#F59E0B`
- Inner ring on the disc: deep saffron `#B45309`
- Rashi ring and ticks: gold `#C99A2E`
- Om glyph: ink `#14100C`
- Launcher background: ink `#14100C`

The mark is the one place the sun blend is used. No other
blend exists anywhere in the product.

## Files

- `dharm-guru-logo.svg`: master vector. Regenerate the PNGs
  from it with `~/workspace/build-dharm-guru-logo.py` when the
  mark changes.
- `dharm-guru-logo.png`: 1024 transparent, the Flutter asset
  used on the splash and onboarding screens.
- `dharm-guru-logo-foreground.png`: 1024 transparent, the mark
  scaled to the Android adaptive icon safe zone. Copied per
  density into `android/app/src/main/res/mipmap-*/` as
  `ic_launcher_foreground.png`.

## Launcher icons

- Android: adaptive icon in `mipmap-anydpi-v26/ic_launcher.xml`
  (foreground plus `@color/ic_launcher_background`), legacy
  `ic_launcher.png` in every `mipmap-*` density, same mark on
  the dark square for the user and the admin app.
- iOS: full `AppIcon.appiconset`, dark square master at 1024,
  no alpha.
- Small sizes: the disc and the Om stay readable down to 48,
  checked at `mipmap-mdpi`.

## Native launch

- Android `drawable/launch_background.xml` and
  `drawable-v21/launch_background.xml`: dark ink background
  with the mark centred, so there is no white flash before the
  Flutter splash.
- iOS `LaunchScreen.storyboard`: dark ink background with the
  mark centred from `LaunchImage.imageset`.
