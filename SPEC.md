# Conticinium — Build Specification

> Portfolio app 140, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Mark tonight's four leaves, then seal the night.

| Field | Value |
| --- | --- |
| Product name | Conticinium |
| Bundle identifier | `com.conticinium.folio` |
| Domain | https://conticinium-folio.pro |
| Contact URL | https://conticinium-folio.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `ctn_` |
| User-Agent | `Conticinium/1.0 (iOS; +https://conticinium-folio.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Conticinium -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A nightwalker banks each leaf of tonight's folio then rests so the hush files as one sealed night.

### 2.1 User flow

1. Bank the open Breathe leaf on tonight's folio
2. Turn forward to Ambient once Breathe holds a LeafMark
3. Bank Ambient, then turn to Rest
4. Rest to write a RestMark and seal tonight
5. Open History as a sheet to see RestMarks and FlutterMarks by day
6. Open Settings as a sheet to set leaf durations and haptics

### 2.2 Essential behaviour

- Tonight's folio of four leaves: Reflect, Breathe, Ambient, Rest
- Bank writes a LeafMark on the current leaf with a short guided beat
- Turn advances only when the current leaf is banked; unmarked turn writes FlutterMark and springs back
- Rest seals the folio when three prior LeafMarks exist and freezes edits for the daykey
- Seed already banks Reflect so Breathe is the live opening leaf
- History lists sealed nights and flutter counts; local UserDefaults only

---

## 3. Uniqueness assignment for Conticinium

| Axis | Assigned value |
| --- | --- |
| Architecture | **Folio ADT fold (Open | Leafed | Rested); the night is a fold over Leaves; Bank writes a LeafMark on the current leaf; Turn advances only when that leaf holds a LeafMark; an unmarked Turn writes a FlutterMark and keeps the leaf; Rest writes a RestMark when Reflect, Breathe and Ambient each hold a LeafMark and folds Leafed to Rested; Rest early is refused; Bank on Rested is refused; empty folio writes Hush** |
| UI approach | **SwiftUI UIPageViewController representable · spritekit-accent** |
| Naming convention | **Conticinium / folio-leaf lexicon** |
| File organization | **By folio role (Folio, Leaf, Bank, LeafMark, FlutterMark, RestMark, Hush) · 028dd21c9d** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **refined · editorial-column · duotone** |
| Typography | **Charter** |
| Navigation pattern | **Folio-locked chrome (the ritual folio never leaves; History and Settings arrive as sheets; bank and turn fuse on Ritual) · 028dd21c9d** |
| AI art style | **Sumi-e ink wash · tactile** |
| Functional twist | **Bank-then-turn (Bank seats a LeafMark; Turn advances only on a banked leaf; Rest seals after three LeafMarks; unmarked Turn writes FlutterMark)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — bedtime_ritual

**Core** — A nightwalker banks each leaf of tonight's folio then rests so the hush files as one sealed night.

**Audience** — People who want a short ordered evening wind-down on one paged canvas, not a sleep tracker and not a free-form breath hold.

**User flow**

1. Bank the open Breathe leaf on tonight's folio
2. Turn forward to Ambient once Breathe holds a LeafMark
3. Bank Ambient, then turn to Rest
4. Rest to write a RestMark and seal tonight
5. Open History as a sheet to see RestMarks and FlutterMarks by day
6. Open Settings as a sheet to set leaf durations and haptics

**Essential features**

- Tonight's folio of four leaves: Reflect, Breathe, Ambient, Rest
- Bank writes a LeafMark on the current leaf with a short guided beat
- Turn advances only when the current leaf is banked; unmarked turn writes FlutterMark and springs back
- Rest seals the folio when three prior LeafMarks exist and freezes edits for the daykey
- Seed already banks Reflect so Breathe is the live opening leaf
- History lists sealed nights and flutter counts; local UserDefaults only

**Twist** — Bank-then-turn. Home is tonight's four-leaf folio. Bank writes a LeafMark on the current leaf. Turn advances only when that leaf holds a LeafMark; an unmarked Turn writes a FlutterMark and the page springs back. Rest writes a RestMark and seals the folio when Reflect, Breathe and Ambient each hold a LeafMark; Rest earlier is refused. Bank on a sealed folio is refused. Seed already banks Reflect so the opening Bank on Breathe is live. Home verb: rest-the-folio — not snuff-the-taper and not prime-the-bellows. History counts RestMarks and FlutterMarks, not hours slept.

**Why this is not a repeat** — Bedtime_ritual with a new home verb: bank leaves on a paged folio then rest, not Bobeche's cue-and-snuff taper, Diapason's prime-then-release bellows, or Auxesis's ascending breath rings. Family screens Ritual/History/Settings stay destinations under folio-locked sheets. Forced leftovers for ui/design/art are used; naming and architecture are newly proposed.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: One sequence canvas: reflect → breathe → ambient. Not a placeholder RootView.
- Invariant: Canonical order. Durations ~90/120/90s. Skip allowed. Cue(at elapsed). Procedural ambient, not shipped audio files. Streak on completed nights.
- Never: Shipping a title screen named after the app fails.
- Desk `bind_progress`: progress mixes stages + sewn sections. Exploded binding is the home.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Tonight is a Folio fold with three cases, Open, Leafed, and Rested, holding four Leaves in canonical order: Reflect, Breathe, Ambient, then Rest. Bank writes a LeafMark on the current leaf and is the only way a leaf becomes seated, and an empty Open folio writes Hush until the first Bank folds it to Leafed. Turn advances only when the current leaf already holds a LeafMark, and an unmarked Turn writes a FlutterMark and keeps that leaf. Rest writes a RestMark and folds Leafed to Rested only when Reflect, Breathe, and Ambient each hold a LeafMark, Rest earlier is refused, and Bank on a Rested folio is refused for that daykey. Durations stay near 90, 120, and 90 seconds for those three leaves, a cue is computed from elapsed time inside the guided beat, ending the beat early is the allowed skip and still writes the LeafMark, Ambient is procedural sound with no shipped audio file, and a streak counts nights that hold a RestMark. Views call Folio methods and never write marks themselves, and one unit test locks the fold, the refusal cases, the cue, and the streak.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

Wrap UIPageViewController in a SwiftUI UIViewRepresentable so Reflect, Breathe, Ambient, and Rest are real pages on Ritual. Confine SpriteKit to one accent scene behind the current leaf on that surface only: a tactile ink wash that settles when Bank succeeds. History, Settings, and Onboarding stay stock SwiftUI, using List, Form, Button, and sheet. A forward swipe or Turn on an unmarked leaf cancels the transition, writes FlutterMark, and springs the page back. Moving back over an already banked leaf writes nothing. Layout is one editorial column on a full-bleed page: measured type, a hairline rule, then the verb, airy, almost no boxes. On iPad the page uses the width and the column stays measured. Radii are 28 and 14, elevation is a hairline plus fill, and the primary control is a full-width filled capsule. Grouped reveals step 40 to 60 milliseconds and finish within 360. Reduce Motion shows the group at once and replaces the page spring with a fade. Bank uses a ButtonStyle with default, pressed, disabled, and loading. Reset uses a destructive style. Hits cover the whole control with contentShape and a 44 point minimum. VoiceOver labels every icon-only control. One haptic fires on a successful Bank or Rest, and none on Turn or on opening a sheet.

### 3.3 Naming contract

Convention: Conticinium / folio-leaf lexicon.

Examples to follow: `Folio`, `LeafMark`, `bankCurrentLeaf()`, `RestMark`

### 3.4 Dependency contract

Zero external dependencies. No Swift Package Manager entry, no CocoaPods, and no vendored source, and project.yml has no packages key. System frameworks are UIKit for the page controller, Core Graphics, SpriteKit for the single Ritual accent the ui axis requires, AVFoundation only to synthesize the Ambient leaf with no audio files and no capture session, and URLSession, which this product does not call. Do not add a camera usage description, a scanner, or a network catalog.

### 3.5 Navigation contract

Folio-locked chrome. Ritual is the permanent root and is not inside a TabView. History and Settings arrive only as sheets over that folio. Bank and Turn are fused on Ritual. They are not separate destinations and not tabs. After onboarding, read ProcessInfo arguments once. -ReviewScreen today leaves Ritual up, log presents the History sheet, and goals presents the Settings sheet. Those keys are launch arguments, not tabs.

### 3.6 Screen composition contract

Folio-root ritual (Ritual holds the paged leaves and Rest seal; History and Settings arrive as sheets; bank and page-turn fuse on Ritual; no tab bar). Physical screens are Onboarding, Ritual, History, and Settings. There is no tab bar and no screen whose title is the product name. Onboarding is three pages. Next or Continue sits at the bottom, full width. Skip writes durations of 90, 120, and 90 seconds and leaves haptics on. Ritual is the root and never leaves: four paged leaves, a measured column, a hairline rule, then Bank and Turn, with the Rest seal on the last leaf and the SpriteKit ink accent only here. Its Hush state is a full-height page with generated art, one headline, one line, and a full-width control that starts tonight. History is a sheet of sealed nights by daykey, listing RestMark and FlutterMark counts, with its own full-page empty state. Settings is a sheet for the three leaf durations, the haptics toggle, re-run onboarding, confirmed reset of all nights, and the contact link https://conticinium-folio.pro/contact-us. -ReviewScreen today stays on Ritual, log opens History, and goals opens Settings.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By folio role (Folio, Leaf, Bank, LeafMark, FlutterMark, RestMark, Hush) · 028dd21c9d**

```
Conticinium/
  Folio/Folio.swift
Folio/FolioFold.swift
Leaf/Leaf.swift
Bank/Bank.swift
LeafMark/LeafMark.swift
FlutterMark/FlutterMark.swift
RestMark/RestMark.swift
Hush/Hush.swift
Ritual/RitualView.swift
Ritual/FolioPageRepresentable.swift
Ritual/InkAccentScene.swift
History/HistorySheet.swift
Settings/SettingsSheet.swift
Store/FolioChartStore.swift
Design/TypeScale.swift
DesignTokens.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Ritual
A first-class screen for **Ritual**. Must render empty, populated and error states.

### 5.3 History
A first-class screen for **History**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **RitualSession** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **refined · editorial-column · duotone**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#E7E9EF` | Screen background |
| `surface` | `#F4F3F6` | Cards, rows, sheets |
| `ink` | `#141A2A` | Primary text and icons |
| `accent` | `#4229C2` | Primary action, key figure, progress fill |
| `muted` | `#4E5974` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Conticinium/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Charter**

Charter is the only family, reached through one type accessor with at most six steps: display, title, headline, body, caption, and micro. Charter-Bold sets the short leaf title, usually one or two lines and never more than four. Charter-Roman sets the measured body near 17pt. Charter-Italic is the single playful moment and is used only for the current leaf name. Durations, streak counts, and flutter counts go through NumberFormatter with monospaced digits, not a second family. Dynamic Type scales every step, custom sizes use ScaledMetric, and headlines stay unclipped at the largest accessibility size. Do not substitute SF Pro, New York, or a rounded system face.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **28pt** for cards, sheets and primary surfaces; **14pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **hairline+fill** — a 1pt hairline border plus a flat fill tint, reused everywhere a surface sits above another.

Primary control: **filled capsule** — the primary CTA is a full-width filled `Capsule`, never a bare text link or a plain `.plain` button.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI UIPageViewController representable · spritekit-accent**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI UIPageViewController representable · spritekit-accent** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **editorial** (Editorial: measure, rules, type hierarchy, almost no boxes.)

Reference system: **refined** — steal rhythm and restraint, not their colours or logos.

Mood: **Carefully curated, modern minimal style with elegant serif typography and understated, sophisticated palettes.**.

Home rhythm (`editorial-column`, airy): One measured column, a rule, then the verb. Almost no boxes.

Editorial: measure, rules, type hierarchy, almost no boxes. Layout `editorial-column`, density airy. Kit 28/14, hairline+fill, filled capsule. Palette recipe `duotone`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Soft rounded UI type, one playful moment, no serif. Reference type feel: editorial.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

Persist with UserDefaults and Codable. One FolioChart root, schemaVersion 1, is JSON-encoded under the single key ctn.folio.v1. It holds each daykey fold, its Leaves, LeafMarks, FlutterMarks, RestMarks, Hush, the three durations, the haptics flag, and the onboarding flag. Daykey is an Int in YYYYMMDD form, derived with Calendar.current.startOfDay. Saves debounce after each Bank, FlutterMark, or Rest, and flush when scenePhase becomes inactive or background and after reset. The UI talks only to the store seam. resetAllData() removes the key and is reachable from Settings. A corrupt payload falls back to an empty Hush folio instead of crashing. This FolioChart is the one chart root from the persistence axis. Do not declare Island, Book, Session, Run, or Rhumb types. The folio-leaf records are the stored model. Simulator seed runs once behind ctn.demo.v1, marks onboarding complete, banks Reflect, opens Breathe with Bank enabled, and writes several prior Rested nights so History is already in use. Never seed on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Conticinium/1.0 (iOS; +https://conticinium-folio.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.healthcare-fitness`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.healthcare-fitness
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Bank-then-turn (Bank seats a LeafMark; Turn advances only on a banked leaf; Rest seals after three LeafMarks; unmarked Turn writes FlutterMark)

The home surface is tonight's folio, and the next tap is Bank on the open leaf, then Rest once the night can seal. Bank seats a LeafMark through a short guided beat, and ending that beat early still seats the mark, which is the allowed skip. Turn advances only on a banked leaf, and an unmarked Turn writes a FlutterMark and springs the page back so the canonical order cannot be swiped past. Rest writes a RestMark and seals the daykey only after Reflect, Breathe, and Ambient each hold a LeafMark, Rest before that is refused, and Bank on a sealed folio is refused. Simulator seed banks Reflect behind ctn.demo.v1 so Breathe is the live opening leaf and Bank is enabled, while the refused Rest and sealed-folio cases stay unit-test fixtures. History lists RestMarks and FlutterMarks by day and never hours slept, a sleep score, or a free-form breath hold.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Sumi-e ink wash · tactile**


Base prompt, reused and extended for every asset:

```
Sumi-e ink wash on bare paper, one loaded brush, wet edge bleeding into dry tooth, tactile pressure from a heavy stroke to a hairline, a single solid subject seated in a wide unpainted field, no letters and no words.
```

All 17 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `ctn_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `ctn_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `ctn_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `ctn_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `ctn_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `ctn_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `ctn_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `ctn_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `ctn_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `ctn_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `ctn_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Bank-then-turn (Bank seats a LeafMark; Turn advances only on a banked leaf; Rest seals after three LeafMarks; unmarked Turn writes FlutterMark)' feature screen. |
| 11 | `ctn_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `ctn_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |
| 13 | `ctn_LeafReflect` | 1024x1024 | **required cutout** | Sumi-e cutout of a single paper leaf with one still vertical brush mark, solid subject, no text. |
| 14 | `ctn_LeafBreathe` | 1024x1024 | **required cutout** | Sumi-e cutout of a single paper leaf with one long horizontal brush stroke, solid subject, distinct from the still leaf, no text. |
| 15 | `ctn_LeafAmbient` | 1024x1024 | **required cutout** | Sumi-e cutout of a single paper leaf carrying a soft dispersed wash, solid subject, no text. |
| 16 | `ctn_LeafRest` | 1024x1024 | **required cutout** | Sumi-e cutout of a single paper leaf closed under a small seal, solid subject, no text. |
| 17 | `ctn_HushFold` | 1024x1024 | **required cutout** | Sumi-e cutout of an untouched folded folio, closed and waiting, solid subject, no text. |

### Prompt per asset

**`ctn_AppIcon`** — 1024x1024

```
Sumi-e ink wash emblem of a closed folio seen from above, one leaf edge lifting, solid subject filling the canvas edge to edge, opaque, no text, no letters, no rounded mask.
```

**`ctn_Splash`** — 1290x2796

```
Tall sumi-e ink wash field with a wide quiet band through the middle and one folded folio low in the frame, opaque paper, no text, no letters.
```

**`ctn_Onboarding1`** — 1024x1536

```
Sumi-e ink wash of a seated figure beside an open folio, the whole rite readable in one glance, solid subject centered, paper tooth, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_Onboarding2`** — 1024x1536

```
Sumi-e ink wash of a hand pressing one paper leaf flat to seat it, mid gesture, solid subject centered, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_Onboarding3`** — 1024x1536

```
Sumi-e ink wash of a small stack of sealed folios, several finished nights accumulated, solid subject centered, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_EmptyHome`** — 1024x1024

```
Sumi-e ink wash of a closed folded paper folio waiting to be opened, solid opaque subject, ceramic-still and heavy, not glass, not a hollow frame, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_EmptyList`** — 1024x1024

```
Sumi-e ink wash of one blank unbound sheet with no marks on it, solid paper subject centered, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_CardBackdrop`** — 1200x800

```
Wide abstract sumi-e wash, soft grain, low contrast, filling the whole canvas so type can sit on it, no object, no text.
```

**`ctn_ControlFace`** — 512x512

```
Sumi-e ink wash of a round tactile seal face used to bank a leaf, solid centered subject, no text, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_TwistHero`** — 1024x1024

```
Sumi-e ink wash of an open folio with one leaf pressed flat and the next leaf curled back, solid centered subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_SuccessMark`** — 512x512

```
Sumi-e ink wash of a small pressed leaf seal, a quiet confirmation mark, solid centered subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_HeaderDecor`** — 1200x600

```
One wide horizontal sumi-e brush stroke, a single rule across the canvas, opaque, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_LeafReflect`** — 1024x1024

```
Sumi-e cutout of a single paper leaf with one still vertical brush mark, solid subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_LeafBreathe`** — 1024x1024

```
Sumi-e cutout of a single paper leaf with one long horizontal brush stroke, solid subject, distinct from the still leaf, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_LeafAmbient`** — 1024x1024

```
Sumi-e cutout of a single paper leaf carrying a soft dispersed wash, solid subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_LeafRest`** — 1024x1024

```
Sumi-e cutout of a single paper leaf closed under a small seal, solid subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`ctn_HushFold`** — 1024x1024

```
Sumi-e cutout of an untouched folded folio, closed and waiting, solid subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`ctn.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `ConticiniumTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Conticinium/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Conticinium -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Folio ADT fold (Open | Leafed | Rested); the night is a fold over Leaves; Bank writes a LeafMark on the current leaf; Turn advances only when that leaf holds a LeafMark; an unmarked Turn writes a FlutterMark and keeps the leaf; Rest writes a RestMark when Reflect, Breathe and Ambient each hold a LeafMark and folds Leafed to Rested; Rest early is refused; Bank on Rested is refused; empty folio writes Hush** with no leakage across layers.
- [ ] UI approach matches **SwiftUI UIPageViewController representable · spritekit-accent**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Folio-locked chrome (the ritual folio never leaves; History and Settings arrive as sheets; bank and turn fuse on Ritual) · 028dd21c9d**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Charter** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Conticinium
xcodegen generate
xcodebuild build-for-testing -scheme Conticinium -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.conticinium.folio/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Conticinium -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.conticinium.folio/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Conticinium -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.conticinium.folio/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
