# 04 Kundli Input Form

## Purpose

Collect name, date of birth, time of birth, and place of birth, then build the chart. Four details are enough for a full birth chart. Nothing more is asked at the start.

## Source

Presentation section Three, fourth phone mockup, and section Two, "Core input".

## Layout, top to bottom

1. Top bar: back chevron on the left, title "Create Your Kundli" in H3 serif 18. No right action.
2. Intro, Body 16 ink2, 8 below the top bar: "Four details are enough for a full birth chart."
3. Form, 24 gap below the intro, fields in order with 16 gap between fields:
   • Full Name. Text field, placeholder "Aarav Sharma" as sample text in the field when empty, shown in ink3. Label "Full Name" above, "Required" at the right of the label.
   • Date of Birth. Date field, value "14 March 1998" in the sample. Opens the platform date picker. No typed date entry is required; the picker is the input.
   • Time of Birth. Time field, value "06:25 AM" in the sample. Opens the platform time picker.
   • Place of Birth. Search field, value "Jaipur, Rajasthan" in the sample. Typing shows suggestions below the field. Selecting a suggestion fills the place.
4. Helper strip, info strip style, 16 below the last field: "Place search fills latitude and longitude on its own so the chart stays accurate." No latitude or longitude field is shown.
5. Primary button, foot, full width, 32 gap above it: "Generate My Kundli"
6. Footnote, 12 below the button, centred, Caption 12 ink3: "Your kundli stays saved to your account."

## Components

• Four fields per the design system input pattern, height 52, radius 14, line2 border, saffron focus border.
• Date picker and time picker: platform pickers, no custom calendar art.
• Place search: suggestion list in a surface card below the field, each row with place name Title 17 and region Caption 12 ink3.
• Primary button, disabled until all four fields have values.

## Copy

• Title: "Create Your Kundli"
• Intro: "Four details are enough for a full birth chart."
• Field labels: "Full Name", "Date of Birth", "Time of Birth", "Place of Birth"
• Helper: "Place search fills latitude and longitude on its own so the chart stays accurate."
• Primary: "Generate My Kundli"
• Footnote: "Your kundli stays saved to your account."
• Sample values, labelled sample data: "Aarav Sharma", "14 March 1998", "06:25 AM", "Jaipur, Rajasthan"

## States

• Default, empty: all fields empty, primary button disabled with line fill and ink3 text.
• Filling: each completed field keeps its value in ink. The primary button stays disabled until the fourth field is filled.
• Place search, typing: suggestion list appears. No suggestion means the list shows "No place found. Check the spelling and try again." in Body small 14.
• Place search, selected: field shows the place, helper strip stays.
• Validation: name empty on submit is not possible because the button is disabled. If a field is cleared after filling, the button disables again. No error colour is needed for this flow.
• Unknown time of birth: the presentation does not cover this case. The form has no "time unknown" option in version 1. This is listed as an open question at the foot of this file. Do not add the option without client approval.
• Generating: button shows a spinner and the label stays "Generate My Kundli". The screen does not move until the chart is ready. A second tap is ignored.
• Error: if chart creation fails, a toast says "Could not create your kundli. Check your connection and try again." The entered values stay in the fields.
• Success: moves to the kundli chart screen with the new chart.
• Edit: the same form is reused for "Edit Birth Details" from Profile, with the saved values filled in and the primary button reading "Update My Kundli".

## Accessibility

• Labels are above fields and are read with the field.
• Pickers are platform pickers, so they carry platform accessibility.
• The disabled button is announced as disabled, not hidden.

## Data and gating

• Free: one personal kundli can be created and saved. This is the free scope in the presentation.
• Premium: unlimited saved family kundlis. The form itself is the same. The limit is enforced only when a free user tries to save a second kundli, with a message that opens the premium upgrade screen.
• Sample data: the four values above are the presentation sample values.

## Open question

• Unknown time of birth: confirm whether version 1 needs a "time unknown" path, and if so what the chart shows when time is missing. No design for it exists in this folder.
