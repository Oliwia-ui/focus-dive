# Visual Design Tokens

Source of truth: `Sources/FocusDiveApp/DesignSystem.swift`.

## Color

| Token | Swift RGB | Approx. hex | Role |
| --- | --- | --- | --- |
| `diveAbyss` | `0.008, 0.035, 0.065` | `#020911` | Deep background |
| `diveNavy` | `0.018, 0.105, 0.170` | `#051B2B` | Background gradient |
| `diveCobalt` | `0.025, 0.280, 0.450` | `#064772` | Charts and depth accents |
| `diveCyan` | `0.350, 0.920, 0.980` | `#59EAF9` | Primary action and progress |
| `diveAqua` | `0.480, 0.780, 0.840` | `#7AC7D6` | Labels, borders, secondary text |
| `diveText` | `0.890, 0.970, 0.990` | `#E3F7FC` | Primary text |
| `diveMuted` | `0.480, 0.680, 0.780` | `#7AADC7` | Muted information |
| `diveAmber` | `0.960, 0.730, 0.320` | `#F5BA52` | Discovery reward |

Hex values are rounded references; Swift RGB values are authoritative.

## Typography

- Use the system typeface; prefer rounded design for timer, headings, and instrument labels.
- Timer: ultra-light, rounded, monospaced digits, responsive to available diameter.
- Section label: 12 pt, medium, rounded, uppercase, 3.2 pt tracking.
- Brand label: 13 pt, medium, rounded, uppercase, 7 pt tracking.
- Micro-labels: 8–10 pt, medium or semibold, uppercase with 1.2–3 pt tracking.
- Keep body and form text at native SwiftUI sizes where possible.

## Surfaces

`divePanel()` defines the shared panel treatment:

- Black at 22% opacity
- Ultra-thin material at 18% opacity
- Continuous 16 pt corner radius
- 1 pt aqua border at 28% opacity
- Black shadow: 18 pt radius, 8 pt vertical offset

Capsule fields use a subtler black fill and aqua outline. Circular controls use cyan outlines, low-opacity fills, and glow only for active emphasis.

## Layout

- Default window: 1440 × 900
- Minimum dashboard: 1100 × 720
- Outer horizontal inset: 28 pt
- Dashboard column gap: 28 pt
- Right rail width: 330 pt
- Depth gauge width: 118 pt
- Main timer maximum: 610 × 610 pt
- Compact timer width: 320 pt

## Motion and depth

- Background particles, light rays, bubbles, progress, and numeric transitions reinforce ascent.
- Depth maps linearly from 60 m at full remaining time to 0 m at completion.
- Reduce Motion freezes continuous drift and removes progress animation.
- Glow communicates active or rewarded state; avoid applying it to every element.

## Voice

Use short, quiet, nautical language: *dive*, *surface*, *mission*, *depth*, *discovery*. Avoid alarmist countdown copy, shame, or competitive ranking.
