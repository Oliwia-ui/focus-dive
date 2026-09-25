# Release Checklist

## Scope and product

- [ ] Confirm release scope and known limitations.
- [ ] Update [[Changelog]].
- [ ] Verify default focus, short-break, and long-break durations.
- [ ] Replace `docs/images/focus-dive-dashboard.png` with a current screenshot.
- [ ] Review user-facing copy, empty states, and notification text.

## Version and metadata

- [ ] Update `CFBundleShortVersionString` in `Resources/Info.plist`.
- [ ] Increment `CFBundleVersion`.
- [ ] Verify bundle identifier and macOS 14 minimum version.
- [ ] Confirm app name and icon assets for the intended distribution channel.

## Automated verification

- [ ] Run `swift build`.
- [ ] Run `swift test`.
- [ ] Run `xcodegen generate`.
- [ ] Run the full `xcodebuild test` app and UI suite.
- [ ] Confirm CI passes on the release commit.

## Manual verification

- [ ] Start, pause, resume, reset, stop, skip, and complete each session kind.
- [ ] Verify the fourth completed focus session selects a long break.
- [ ] Verify automatic break start behavior.
- [ ] Verify mission text appears in the completed dive log.
- [ ] Verify settings and history survive relaunch.
- [ ] Verify logbook, weekly profile, streak, energy, and discovery states.
- [ ] Verify compact mode and menu-bar controls.
- [ ] Verify all documented keyboard shortcuts.
- [ ] Verify the notification permission and completion banner paths.
- [ ] Verify behavior with Reduce Motion enabled.
- [ ] Verify the minimum window size and common display scales.
- [ ] Verify VoiceOver labels and keyboard focus order.

## Package and distribute

- [ ] Run `./scripts/build-app.sh release`.
- [ ] Launch and inspect `dist/Focus Dive.app`.
- [ ] Replace ad-hoc signing with Developer ID signing for external distribution.
- [ ] Enable the required hardened runtime and entitlements.
- [ ] Notarize and staple the distributable app.
- [ ] Validate the final archive on a clean macOS 14+ account.
- [ ] Publish checksums and release notes with the artifact.

## After release

- [ ] Install the published artifact and repeat the launch smoke test.
- [ ] Confirm the download, signature, and notification behavior.
- [ ] Record follow-up issues and update [[Technical Decisions]] where policy changed.
