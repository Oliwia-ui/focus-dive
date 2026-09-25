# Changelog

All notable project changes are recorded here.

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
- Refined dashboard panels with restrained native glass treatment on macOS 26 and a material fallback on macOS 14–15.

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
