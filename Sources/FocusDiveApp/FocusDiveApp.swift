import AppKit
import SwiftUI

@main
struct FocusDiveApp: App {
    @StateObject private var model = FocusDiveViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if model.isCompact {
                    CompactTimerView(model: model)
                } else {
                    FocusDiveDashboard(model: model)
                }
            }
            .preferredColorScheme(.dark)
            .sheet(isPresented: $model.showSettings) {
                SettingsView(model: model)
            }
            .sheet(isPresented: $model.showLogbook) {
                LogbookView(model: model)
            }
            .sheet(isPresented: $model.showTasks) {
                TaskListView(model: model)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1_440, height: 900)
        .commands {
            CommandGroup(after: .newItem) {
                Button(model.isRunning ? "Pause Dive" : "Start Dive") {
                    model.toggleTimer()
                }
                .keyboardShortcut(.space, modifiers: [.command])

                Button("Reset Dive") { model.reset() }
                    .keyboardShortcut("r", modifiers: [.command])

                Button("Skip Session") { model.skip() }
                    .keyboardShortcut(.rightArrow, modifiers: [.command, .option])

                Divider()

                Button("Dive Settings…") { model.showSettings = true }
                    .keyboardShortcut(",", modifiers: [.command])
                Button("Open Dive Log") { model.showLogbook = true }
                    .keyboardShortcut("l", modifiers: [.command])
                Button("Open Tasks") { model.showTasks = true }
                    .keyboardShortcut("t", modifiers: [.command])
                Button("Toggle Mini Timer") { model.isCompact.toggle() }
                    .keyboardShortcut("m", modifiers: [.command, .shift])
            }
        }

        MenuBarExtra {
            VStack(alignment: .leading, spacing: 10) {
                Text(model.currentKind.title)
                    .font(.headline)
                Text(String(format: "%02d:%02d", model.remainingSeconds / 60, model.remainingSeconds % 60))
                    .font(.system(.title2, design: .monospaced))
                Divider()
                Button(model.isRunning ? "Pause" : "Start") { model.toggleTimer() }
                Button("Reset") { model.reset() }
                Button("Skip") { model.skip() }
                Divider()
                Button("Settings…") { model.showSettings = true }
                Button("Tasks…") { model.showTasks = true }
                Button("Quit Focus Dive") { NSApplication.shared.terminate(nil) }
            }
            .padding(8)
        } label: {
            Label(
                String(format: "%02d:%02d", model.remainingSeconds / 60, model.remainingSeconds % 60),
                systemImage: "water.waves"
            )
        }
        .menuBarExtraStyle(.menu)
    }
}
