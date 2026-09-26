# Changelog

All notable project changes are recorded here.

## 2026-09-26 — Manual post-dive break choice

### Changed

- Kept completed sessions at `00:00`, zero metres, and the bright surface state instead of immediately replacing them with the next queue timer.
- Added explicit `Start Break` and `Start Focus Dive` completion actions while retaining a `Stay Surfaced` choice.
- Removed the automatic-break control and no longer starts breaks automatically, including for older saved settings that enabled it.
- Preserved the completed session kind and queue position until the user explicitly starts the next session.

### Verified

- Added regression coverage for completed focus and break sessions, manual queue advancement, and ignored automatic-break settings.

## 2026-09-26 — Make the fish school clearly visible

### Fixed

- Moved the fish school out of the heavily dimmed procedural-water layer that reduced its final opacity to roughly one third.
- Increased fish size and definition with restrained cyan edge light, dorsal fins, and visible eyes while keeping dark underwater silhouettes.
- Kept fish visible while idle and animated them only during an active session, with pause and Reduce Motion freezing their current positions.

### Verified

- Rebuilt and launched the signed app bundle; the fish school is visibly present before the timer starts.

## 2026-09-26 — Living underwater ambience

### Added

- Added a slow looping school of silhouetted fish with varied sizes, depths, speeds, and gentle vertical drift.
- Added a calm breathing cycle to the cyan surface glow and moving light shafts.
- Limited bubbles to actively running sessions so the scene communicates timer state instead of moving decoratively while idle.
- Preserved the current ambient frame across pause and resume instead of snapping fish and light rays back to their starting positions.

### Accessibility and performance

- Freezes ambient drift when macOS Reduce Motion is enabled.
- Slows the background refresh cadence while the timer is inactive.

### Verified

- All 19 core tests pass.
- The release app bundle builds, passes strict code-signature verification, launches, and exposes the active pause control after starting a focus session.

## 2026-09-26 — Photographic cavern background experiment

### Changed

- Bundled the supplied underwater cavern photograph as an application resource rather than depending on the temporary Hermes attachment path.
- Composited the photograph beneath the existing procedural ocean effects with aspect-fill cropping, restrained saturation, and navy edge gradients for dashboard legibility.
- Kept the procedural background as a fallback if the image resource cannot be loaded.
- Updated both the XcodeGen project definition and local app-bundle script to package the resource.

### Verified

- All 19 core tests pass.
- The release app bundle builds, contains the image resource, passes strict code-signature verification, and launches successfully.

## 2026-09-25 — Restore Xcode 16 compatibility

### Fixed

- Removed the compile-time dependency on the macOS 26-only SwiftUI glass API.
- Kept the premium translucent panel treatment using material, tint, reflection, and shadow APIs supported by the macOS 14 deployment toolchain.
- Restored Swift Package and Xcode project compilation on GitHub’s Xcode 16.4 runner.

## 2026-09-25 — Append-only Obsidian record writer

### Added

- Added a tested Markdown event writer for user-selected Obsidian vaults.
- Created predictable `Focus Dive/Tasks`, `Focus Dive/Sessions`, and `Focus Dive/Reflections` categories.
- Appended events to date-based Markdown files without replacing earlier records.
- Included local date, time, timezone, event type, status, task/activity, task identifier, actual duration, and a unique event identifier.
- Sanitized multiline values so one activity cannot corrupt subsequent Markdown fields.

### Verified

- Added tests proving multiple task events remain in one daily log and cancelled sessions include actual elapsed duration.

## 2026-09-25 — Task workspace and session linking

### Added

- Added a native task workspace for creating, viewing, editing, deleting, completing, and reopening tasks.
- Added dashboard, menu, and keyboard access to Tasks.
- Added a “Focus” action that links an open task to the next focus dive and fills the mission title.
- Stored the linked task identifier on completed focus-session records while retaining free-form mission descriptions.
- Added accessibility labels and stable identifiers for task creation and editing controls.

### Verified

- `swift build --product FocusDive` succeeds.
- All 17 core tests pass, including linked-task session history coverage.

## 2026-09-25 — Local task foundation

### Added

- Added a local task model with create, edit, complete, reopen, and delete operations.
- Persisted tasks in the existing JSON snapshot without changing the app architecture.
- Added backward-compatible decoding so existing user snapshots without tasks continue to load.
- Added view-model task operations so the upcoming task interface uses the same guarded persistence path as timer settings and history.

### Verified

- Added lifecycle, validation, persistence round-trip, and legacy-snapshot migration tests.

## 2026-09-25 — Editable session durations

### Changed

- Made every session queue row interactive with an accessible duration editor.
- Added bounded one-minute adjustments and useful presets for focus, short-break, and long-break sessions.
- Applied duration changes immediately while preserving an active countdown instead of resetting it.
- Refined dashboard panels with a restrained material-based glass treatment that compiles across the supported macOS toolchain.

### Verified

- Added regression coverage for duration changes while idle and while running.
- `swift test` passes all 13 tests.

## 2026-09-25 — MVP documentation baseline

### Added

- Native SwiftUI dashboard with ocean depth, ascent progress, session queue, weekly profile, streak, energy, and discoveries
- Focus, short-break, and long-break sequencing with configurable durations
- Mission naming, dive log, compact timer, menu-bar controls, keyboard commands, and local notifications
- Local JSON persistence for settings and completed focus history
- Swift Testing coverage for timer, settings, session completion, and persistence
- XCTest UI smoke coverage for start, pause, and reset
- Swift Package and XcodeGen build paths
- README, engineering handoff, and Obsidian project vault

### Known limitations

- Sound controls are reserved and disabled.
- Distribution signing, notarization, packaging, and publishing are not automated.
- Persistence errors are not surfaced in the UI.
- UI tests require a generated Xcode project.
