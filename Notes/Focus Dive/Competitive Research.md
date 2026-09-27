# Competitive Research

## Purpose

This note identifies the smallest set of proven behaviours worth carrying into the two local macOS apps: **Mind Space** (tasks) and **Focus Dive** (timed focus). Sources are first-party product pages or support documentation, checked 2026-09-27.

## To Do patterns

| Product | Official evidence | Useful lesson | Deliberately not copying |
| --- | --- | --- | --- |
| [Things](https://culturedcode.com/things/support/articles/4001304/) | Inbox is a staging area for unprocessed thoughts; Today is intended to contain only work for the current day; Logbook retains completed/cancelled items. Projects provide context. | Mind Space needs Inbox, a deliberately short Today list, projects, and a completed history. The “capture now, organise later” principle directly supports its floating-thought canvas. | Calendar sync, repeating work, tags, cloud sync, email capture, and its exact visual language. |
| [Todoist](https://www.todoist.com/help/todoist/features/introduction-to-tasks-080OAXric) | A task without a project goes to Inbox by default; completed tasks can be restored. [Projects](https://www.todoist.com/help/todoist/features/introduction-to-projects-TLTjNftLM) can have colours, sections, and dates, and feed Today/Upcoming. | Preserve safe capture, completion/reopening, project membership, and a quiet colour cue. | Collaboration, teams, filters, priority flags, boards, calendar views, and subscription-only functionality. |
| [Apple Reminders](https://support.apple.com/en-euro/guide/reminders/remne4b02adc/mac) | Reminders support notes, tags, date/location fields, standard lists, and Smart Lists. [Smart Lists](https://support.apple.com/guide/reminders/create-custom-smart-lists-remnfec66479/7.0/mac/27) gather items by criteria while originals stay in their lists. | Keep task details optional and support simple list-based organisation. This validates the native-macOS, low-friction direction. | iCloud dependence, sharing/assignment, grocery automation, location reminders, and complex saved filters. |

**Mind Space conclusion.** The essential model is: quick Inbox capture → optional project grouping → intentional Today choice → completion/reopen history. Mind Space’s custom contribution is to make that model spatial: loose items float as thoughts; a saved project is a constellation/galaxy; the “Make It Make Sense” transition resolves the same data into normal lists. It must remain local, editable, and functional—not a decorative replacement for task management.

## Focus-timer patterns

| Product | Official evidence | Useful lesson | Deliberately not copying |
| --- | --- | --- | --- |
| [Forest](https://forestapp.cc/) | A selected focus length grows a tree in real time; completing it keeps the tree as a visible record. Its wider product includes blockers, statistics, social sessions, sounds, and real-tree planting. | Focus Dive can make elapsed effort spatial and rewarding: the dive/ascent visual is a calm visual record of a completed session. | Blocking other apps, accounts, social/group challenges, currency, real-world rewards, and heavy gamification. |
| [Pomofocus](https://pomofocus.io/) | Its core flow is a 25-minute task timer and 5-minute break, repeated in cycles; it also offers adjustable focus/break settings, reports, task templates, and project time tracking. | Keep the core start → focus → break flow clear; permit adjustable durations and attach a short mission/description to a session. | Ads/premium tiers, templates, browser-first UX, webhooks, Todoist integration, extensive reports, and background sound controls. |
| [Toggl Track](https://support.toggl.com/en/articles/2206984-how-do-i-create-a-time-entry) | Time entries can be created manually or from a running timer, with description, project, tags, start/end times, and duration. | A completed Focus Dive entry should retain factual session data: description, timestamps, actual active duration, and optional future task ID. | Billing, clients, team permissions, invoicing, timesheets, and enterprise reporting. |

**Focus Dive conclusion.** The essential model is one mission at a time, configurable focus/break durations, reliable start/pause/stop/completion, persistent session history, and an honest record of actual time. Its custom concept is the dive: time becomes depth, ascent, light, and surfacing—not points or pressure.

## Shared product decisions

- Both apps are personal, offline-first native macOS tools with no account, cloud dependency, ads, or collaboration.
- Both append rather than overwrite human-readable activity records in a user-selected Obsidian vault: Mind Space writes task events; Focus Dive writes focus start/completion/cancellation events.
- A stable task ID is the future bridge: Focus Dive may later reference a Mind Space task without embedding a timer inside the To Do app.
- Keep optional detail hidden until needed. A title is enough to capture a task; a mission/description is enough to start a focus session.
