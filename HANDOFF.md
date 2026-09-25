# Focus Dive Handoff

## Project state

Focus Dive is a native SwiftUI macOS 14+ MVP built with Swift 6. The Swift package is the source of truth; `project.yml` generates an Xcode project for app and UI testing. The MVP stores data locally and uses an ad-hoc signature for local app bundles.

## Run

```bash
swift run FocusDive
```

Build and open an app bundle:

```bash
./scripts/build-app.sh release
open "dist/Focus Dive.app"
```

The default window is 1440 × 900 and requires at least 1100 × 720. The menu-bar timer is available while the app runs.

## Test

Core unit tests:

```bash
swift test
```

App and UI tests:

```bash
brew install xcodegen
xcodegen generate
xcodebuild test \
  -project FocusDive.xcodeproj \
  -scheme FocusDive \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO
```

UI tests set `FOCUS_DIVE_UI_TESTING=1`, which isolates persistence in a temporary directory and suppresses notification permission requests.

## Extend

- Put deterministic timer, settings, session, and persistence behavior in `Sources/FocusDiveCore`.
- Keep AppKit, SwiftUI, Combine, and UserNotifications in `Sources/FocusDiveApp`.
- Add core behavior tests under `Tests/FocusDiveCoreTests` before wiring UI state.
- Add reusable dashboard UI to `DashboardComponents.swift`; keep modal and compact surfaces in `SecondaryViews.swift`.
- Extend visual tokens in `DesignSystem.swift` rather than scattering colors and panel styles.
- Preserve accessibility identifiers used by UI tests: `timer-display`, `primary-timer-control`, and `reset-timer-control`.
- Respect Reduce Motion in new continuous or progress-driven animation.
- Evolve persisted Codable models deliberately; existing data lives at `~/Library/Application Support/FocusDive/focus-dive.json`.

The settings model contains reserved ambience and completion-sound flags, but the current controls are disabled and the MVP intentionally produces no sound.

## Release

1. Update `CFBundleShortVersionString` and `CFBundleVersion` in `Resources/Info.plist`.
2. Update `Notes/Focus Dive/Changelog.md` and complete `Notes/Focus Dive/Release Checklist.md`.
3. Run `swift build` and `swift test`.
4. Generate the Xcode project and run the full `xcodebuild test` command above.
5. Build the release bundle with `./scripts/build-app.sh release`.
6. Launch `dist/Focus Dive.app` and smoke-test timer controls, settings, logbook, compact mode, menu-bar controls, persistence, and notifications.
7. Refresh the README dashboard screenshot if the interface changed.
8. For external distribution, replace the script's ad-hoc signature with a Developer ID signature, then notarize and staple the app. The repository does not currently automate signing, notarization, packaging, or publishing.

## Known boundaries

- The package manifest includes core unit tests but not UI tests; UI tests require the XcodeGen project.
- Completed focus sessions are logged; break sessions are not.
- Discoveries are derived from history count and are not stored separately.
- The mission field is attached to a session when it starts and is not persisted independently.
- Notification authorization failures are intentionally non-blocking.
- Persistence errors are currently ignored by the app layer.
