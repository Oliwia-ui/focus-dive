# User Flows

## Start a focus dive

1. Launch Focus Dive.
2. Optionally enter a mission.
3. Press `Space` or select Start.
4. Observe the countdown, progress ring, and ascent from 60 m.
5. Pause and resume as needed.
6. On completion, receive a local banner and advance to a surface break.
7. The completed focus dive appears in the logbook and activity summaries.

## Control an active session

- **Pause:** preserve remaining time and stop the ticker.
- **Reset:** restore the current session's configured duration.
- **Stop:** return the current session to a fresh idle timer without advancing.
- **Skip:** advance to the next focus or break kind without creating a log entry.

## Follow the session cycle

```text
Focus → Short break → Focus → Short break → Focus → Short break → Focus → Long break
```

A completed focus session advances to a short break, except every fourth completed focus session advances to a long break. Completing or skipping a break returns to focus. When automatic breaks are enabled, a newly selected break starts immediately.

## Change durations

1. Open Dive Settings with `Command-,` or the sliders button.
2. Adjust focus, short-break, or long-break duration.
3. Optionally enable automatic surface breaks.
4. Close the sheet.
5. The active session resets to the new duration and settings are saved locally.

## Review progress

1. Open the Dive Log with `Command-L` or the waveform button.
2. Review mission, completion time, duration, and depth for each completed focus dive.
3. Return to the dashboard to view the seven-day profile and streak.

## Use compact or menu-bar controls

- Toggle the compact timer with `Command-Shift-M`.
- Use the menu-bar item to start, pause, reset, skip, open settings, or quit.
- Toggle compact mode again to return to the dashboard.

## Discovery reward

Every third completed focus dive reveals the next item in the rotating discovery catalog. The current discovery is derived from completed history rather than persisted separately.
