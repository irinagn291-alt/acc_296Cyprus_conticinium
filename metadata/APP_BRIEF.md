<!-- gf-brief source=aa4ad234321565f3232c59b06d54353737dd7b2290b0fcc65e67f32f20585743 written=2026-09-29T19:14:01+03:00 -->
# Conticinium

## What it is
Conticinium is a short evening rite on one canvas. A person keeps four pages in order — Reflect, Breathe, Ambient, then Rest — and Rest files a sealed night on this device. It is for people who want an ordered wind-down, not a sleep log and not a free-form breath hold.

## Launch and onboarding
A cold launch shows a blank system launch screen with no title, then the introduction if it has not been finished.

The introduction is three full-screen pages. It cannot be dragged away. Each page shows art, a title, a line, and a page mark. **Skip** is on every page.

1. **An evening in order**  
   **Four pages, one after another. Reflect, breathe, ambient, then rest.**  
   **Page 1 of 3**  
   **Next** goes to page 2. **Skip** ends the introduction.

2. **Keep, then turn**  
   **Keep the page you are on. Turn moves only after that mark is there.**  
   **Page 2 of 3**  
   **Next** goes to page 3. **Skip** ends the introduction.

3. **Rest seals the night**  
   **When the three pages hold a mark, rest files the night on this device.**  
   **Page 3 of 3**  
   **Continue** ends the introduction. **Skip** also ends it, and puts page lengths back to 90, 120, and 90 seconds with **Haptics** on.

After the introduction, **Tonight** is the home screen. On a new install it opens as the empty night: **Build tonight's rite**.

## Screens

### Tonight
There is no tab bar. **Tonight** stays on screen. A closed-book control (VoiceOver: **History**) opens **Sealed nights**. A gear control (VoiceOver: **Settings**) opens **Settings**.

Under the title is the streak:
- **No sealed night yet.**
- **1 sealed night.**
- **N sealed nights.** (N is the run of consecutive sealed nights ending today or yesterday.)

**Empty night (before the first keep)**  
- Headline: **Build tonight's rite**  
- Line: **Four pages, in order. You can skip a page if you must.**  
- **Begin with Reflect** starts the Reflect beat. It is dimmed while the beat is running or the mark is landing.  
- During the beat the cue word cycles **Inhale**, **Hold**, **Exhale**, **Settle**. **End early** keeps the page without waiting out the length.  
- After the first keep, this empty night is replaced by the four swipeable pages.

**If tonight cannot be shown**  
- **Tonight could not be read**  
- A note such as **A saved night could not be read. Tonight starts quiet.** or **Tonight could not be saved. The open night is still on screen.**  
- **Try again** reloads tonight.

**The four pages**  
Reflect, Breathe, Ambient, and Rest sit on one horizontal pager. A forward swipe or **Turn forward** moves only after the current page is kept. An early forward swipe or turn stays on the page, files a flutter mark, and shows **This page is not kept yet. It stays here.** A back swipe or turn over a kept page writes nothing.

Each page shows its name, a job title, a line, the page length as **N seconds** (not on Rest), then the controls. A list under the art names all four pages and their stage: **Waiting**, **Now**, **Kept**, or **Sealed**.

Job titles:
- Before keep: **Keep this page**
- After keep: **This page is kept**
- On Rest, before seal: **Rest seals the night**
- After seal: **This night is sealed**

If you land on a page that is not the current one:
- **This page already holds its mark.** (already kept)
- **Turn back here when you want this page.** (not kept yet)

When at least one night is sealed, the current page also shows **Last sealed night**, the date, and **1 flutter** or **N flutters**. Tapping it opens **Sealed nights**.

After Rest, the pager no longer turns. The current page shows **This night is sealed**, the notice **Tonight is sealed.**, and **Open history**, which opens **Sealed nights**.

### Reflect
- **Sit with the day. Keep this page, then turn forward.**
- Default length **90 seconds** (set in **Settings**).
- **Keep this page** starts the beat (same cues as above). Dimmed while the beat runs or the mark lands.
- **End early** appears during the beat and still keeps the page.
- After a full beat: **Page kept.** After **End early**: **Page kept. You can turn forward.**
- **Turn forward** goes to Breathe once Reflect is kept. If it is not kept, the page stays.

### Breathe
- **Follow the beat. Keep this page, then turn forward.**
- Default length **120 seconds**.
- Same **Keep this page**, **End early**, and **Turn forward** rules. Turn goes to Ambient.

### Ambient
- **Let the wash hold. Keep this page, then turn toward rest.**
- Default length **90 seconds**.
- A quiet tone plays while this page is current and the night is not sealed. It stops if you leave the page, leave the app, or seal the night.
- Same keep and turn rules. Turn goes to Rest.

### Rest
- **Rest once Reflect, Breathe, and Ambient are each kept.**
- No seconds line.
- **Rest** seals tonight when the three earlier pages show **Kept**. It is dimmed until then, and while the seal is landing.
- VoiceOver hint: **Seals tonight when Reflect, Breathe, and Ambient are each kept.**
- After seal: **Open history** instead of **Rest**.

### Sealed nights
Sheet over Tonight. Title **Sealed nights**. Close control (VoiceOver: **Close**) or a downward drag returns to Tonight.

**Empty**  
- **No sealed night yet**  
- **Keep the three pages, then rest. The mark will wait here.**  
- **Back to tonight** dismisses the sheet.

**List**  
Each row is a date (device medium date) and a count line such as **1 rest mark, 0 flutter marks** or **1 rest mark, 2 flutter marks** (singular **rest mark** / **flutter mark** when the count is 1). Rows are not tappable destinations.

**If nights cannot be read**  
- **Nights could not be read**  
- The recovery note, or **A saved night could not be read.**  
- **Try again** reloads. **Back to tonight** dismisses.

### Settings
Sheet over Tonight. Title **Settings**. Close control (VoiceOver: **Close**) or a downward drag returns to Tonight.

If a recovery note is present, it appears at the top with **Try again**.

**Page lengths**  
Steppers from 30 to 240 seconds, in steps of 10:
- **Reflect** — **N seconds**
- **Breathe** — **N seconds**
- **Ambient** — **N seconds**

**Feel**  
- **Haptics** on/off. When on, a short tap fires after a page is kept and after the night is sealed. Not after a turn.

**This device**  
- **Show the introduction** closes Settings and shows the three introduction pages again.
- **Reset all nights** asks **Reset all nights?** with **Sealed nights and flutter marks on this device will be removed.** Choices: **Reset all nights** (removes them) and **Cancel**. After reset, Tonight shows **Every sealed night is gone from this device.** and returns to **Build tonight's rite**. Lengths go back to 90, 120, and 90 seconds. **Haptics** turns on. The introduction stays finished.
- **Contact** opens the support page.

## Features
- Four pages in order: **Reflect**, **Breathe**, **Ambient**, **Rest**
- **Keep this page** / **Begin with Reflect** — a timed beat with **Inhale**, **Hold**, **Exhale**, **Settle**
- **End early** — still keeps the page
- **Turn forward** and a forward swipe — move only after the page is kept
- A flutter mark when you turn or swipe forward too soon
- **Rest** — seals tonight after the three earlier pages are kept
- **Sealed nights** — rest marks and flutter marks by day, not hours slept
- Streak line on **Tonight**
- **Last sealed night** on the current page
- **Page lengths** for Reflect, Breathe, and Ambient
- **Haptics**
- A quiet tone on **Ambient**
- **Show the introduction**
- **Reset all nights**
- **Contact**
- Nights stay on this device

## Behaviours that can look like bugs
- **Turn forward** stays tappable before a keep. It does not advance. The page stays and shows **This page is not kept yet. It stays here.** Keep the page first (or use **End early**), then turn. A forward swipe does the same and springs back.
- **Rest** stays dimmed until Reflect, Breathe, and Ambient each show **Kept**. You only reach Rest by turning forward after Ambient is kept. If Rest is refused, the note is **Rest waits until Reflect, Breathe, and Ambient are each kept.**
- **Keep this page** and **Begin with Reflect** start a long beat (90 / 120 / 90 seconds by default). The primary control is dimmed until the beat ends. **End early** is the skip; it still keeps the page.
- After keep, the primary control becomes **Turn forward**. The page does not auto-advance.
- After **Rest**, tonight is frozen for that calendar day. Pages no longer swipe. Use **Open history**. A new empty night (**Build tonight's rite**) appears on the next calendar day.
- An unfinished night that is not sealed does not appear in **Sealed nights**. After midnight it is left behind; Tonight starts a new empty night.
- **Begin with Reflect** and **Keep this page** refuse a second keep: **This page is already kept. Turn forward.**
- On Rest, keep is refused: **This page seals the night. Rest when the earlier pages are kept.**
- After seal, keep is refused: **Tonight is sealed. Open History to see the mark.**
- **Turn forward** on Rest shows **This page is the end of tonight.**
- **Sealed nights** opens empty with **No sealed night yet** until the first Rest. **Back to tonight** returns.
- **Skip** on the introduction ends it immediately. **Skip** also resets lengths to 90, 120, and 90 seconds and turns **Haptics** on. Walking through **Next** / **Continue** does not reset lengths.
- The introduction cannot be dismissed by dragging. Finish with **Continue** or **Skip**.
- **Show the introduction** then **Skip** resets lengths and **Haptics**; **Continue** does not.
- Recovery notes such as **A saved night could not be read. Tonight starts quiet.** or **Tonight could not be saved. The open night is still on screen.** block a clean list until **Try again**, or they sit in Settings while Tonight is still usable.
- **The mark did not land. Keep this page again.** / **Rest did not seal. Try again in a moment.** / **The beat could not be read. Start it again.** — tap the same control again.
- A spinner can appear on **Keep this page**, **Begin with Reflect**, or **Rest** while the mark is landing.

## Starter content and resume
None on a new iPhone or iPad install. Tonight starts as **Build tonight's rite**. **Sealed nights** is empty.

The iOS Simulator can open with the introduction already finished, four sealed nights already in the list, and tonight already past Reflect (Breathe is the current page).

Kept pages and the current page resume if you leave and come back on the same calendar day. A beat that was still running does not resume after a full quit; start **Keep this page** again. After Rest, that night stays sealed until the next calendar day.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content, an account deletion flow, and an App Tracking Transparency prompt are all absent.

## Data and support
Nights, flutter marks, page lengths, and the haptics setting stay on this device. Onboarding says rest **files the night on this device.** Settings groups **Contact** under **This device**. **Contact** opens the support page.

## Scanning and health
The app does not scan barcodes or QR codes. It does not show medical, diagnostic, or product-health information, and there are no citations. **Sealed nights** counts rest marks and flutter marks, not hours slept. The Breathe page (and the empty-night beat) shows timed **Inhale**, **Hold**, **Exhale**, and **Settle** words as part of the rite.

## Platform
Copy is English only. Dates and numbers follow the device locale. Portrait only, light appearance, full screen. iPhone and iPad. Minimum iOS 17.0. Not for Mac or Apple Vision.

## Category
Health & Fitness
