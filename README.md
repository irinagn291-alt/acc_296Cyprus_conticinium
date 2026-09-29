# Conticinium

Conticinium is a short bedtime folio for people who want an ordered evening wind-down on one paged canvas. It is not a sleep tracker and not a free-form breath hold. You bank each leaf of tonight, then rest so the night files as one seal.

## Architecture

Tonight is a folio fold with three cases: Open, Leafed, and Rested. The night holds four leaves in canonical order: Reflect, Breathe, Ambient, Rest. An empty Open folio carries Hush until the first Bank folds it to Leafed. Bank is the only way a leaf becomes seated. Turn advances only when the current leaf already holds a LeafMark. An unmarked Turn writes a FlutterMark and keeps that leaf. Rest writes a RestMark and folds Leafed to Rested only when Reflect, Breathe, and Ambient each hold a LeafMark. Rest earlier is refused. Bank on a Rested folio is refused for that daykey.

The fold suits this product because the evening is one sequence with a seal, not a bag of records. Views call folio methods and never write marks themselves. One chart root in UserDefaults stores sessions, durations, haptics, and onboarding under a single key, with a debounced save after each mark.

## Why someone would pick this

Bank, then turn. Home is tonight's four-page evening. The next tap reads Keep this page, which seats the mark. If you turn too early, the page springs back and a flutter is filed. Rest is available only after the three earlier marks. History counts rest marks and flutter marks, not hours slept.

## Screens

Ritual is the permanent root. History and Settings arrive as sheets. There is no tab bar. Onboarding is three pages. Skip writes 90, 120, and 90 second leaves and leaves haptics on. `-ReviewScreen today` stays on Ritual, `log` opens History, and `goals` opens Settings. Those keys are launch arguments.

## Art

Style: Sumi-e ink wash, tactile. Section 13 images are filled by a later asset step. Prompts live in SPEC.md section 13.2. Each set is named with the `ctn_` prefix: `ctn_AppIcon`, `ctn_Splash`, `ctn_Onboarding1`, `ctn_Onboarding2`, `ctn_Onboarding3`, `ctn_EmptyHome`, `ctn_EmptyList`, `ctn_CardBackdrop`, `ctn_ControlFace`, `ctn_TwistHero`, `ctn_SuccessMark`, `ctn_HeaderDecor`, `ctn_LeafReflect`, `ctn_LeafBreathe`, `ctn_LeafAmbient`, `ctn_LeafRest`, `ctn_HushFold`.

Base prompt: Sumi-e ink wash on bare paper, one loaded brush, wet edge bleeding into dry tooth, tactile pressure from a heavy stroke to a hairline, a single solid subject seated in a wide unpainted field, no letters and no words.

## How this differs

Bedtime ritual with a paged folio. Bank seats a leaf, Turn advances only on that mark, Rest seals after three LeafMarks. It is not a taper you snuff, not bellows you prime, and not ascending breath rings.

## Build

```bash
cd apps/Conticinium
xcodegen generate
xcodebuild build-for-testing -scheme Conticinium -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

Zero external packages. System frameworks only: SwiftUI, UIKit, SpriteKit on Ritual, AVFoundation for a procedural ambient tone, and Core Graphics.
