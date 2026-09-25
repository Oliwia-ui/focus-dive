# Changelog

All notable project changes are recorded here.

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
