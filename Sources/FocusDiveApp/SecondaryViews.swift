import FocusDiveCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: FocusDiveViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("Dive settings")
                .font(.system(size: 28, weight: .light, design: .rounded))
            Form {
                Stepper(
                    "Focus dive: \(model.settings.focusMinutes) min",
                    value: integerBinding(\.focusMinutes, range: 1...120),
                    in: 1...120
                )
                Stepper(
                    "Short break: \(model.settings.shortBreakMinutes) min",
                    value: integerBinding(\.shortBreakMinutes, range: 1...30),
                    in: 1...30
                )
                Stepper(
                    "Long break: \(model.settings.longBreakMinutes) min",
                    value: integerBinding(\.longBreakMinutes, range: 1...60),
                    in: 1...60
                )
                Toggle("Automatically begin surface breaks", isOn: booleanBinding(\.automaticallyStartBreaks))
                Section("Sound architecture") {
                    Toggle("Underwater ambience", isOn: .constant(false))
                        .disabled(true)
                    Toggle("Completion sound", isOn: .constant(false))
                        .disabled(true)
                    Text("Sound controls are reserved for a future release. The MVP remains silent.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(28)
        .frame(width: 480, height: 470)
    }

    private func integerBinding(_ keyPath: WritableKeyPath<DurationSettings, Int>, range: ClosedRange<Int>) -> Binding<Int> {
        Binding(
            get: { model.settings[keyPath: keyPath] },
            set: { value in
                var settings = model.settings
                settings[keyPath: keyPath] = min(max(value, range.lowerBound), range.upperBound)
                model.updateSettings(settings)
            }
        )
    }

    private func booleanBinding(_ keyPath: WritableKeyPath<DurationSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { model.settings[keyPath: keyPath] },
            set: { value in
                var settings = model.settings
                settings[keyPath: keyPath] = value
                model.updateSettings(settings)
            }
        )
    }
}

struct LogbookView: View {
    let history: [DiveLogEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if history.isEmpty {
                    ContentUnavailableView(
                        "No completed dives",
                        systemImage: "water.waves",
                        description: Text("Completed focus sessions will surface here.")
                    )
                } else {
                    List(history) { entry in
                        HStack(spacing: 16) {
                            Image(systemName: "water.waves")
                                .foregroundStyle(Color.diveCyan)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.taskName).font(.headline)
                                Text(entry.completedAt.formatted(date: .abbreviated, time: .shortened))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(entry.durationSeconds / 60) min")
                                Text("\(Int(entry.depthReachedMeters)) m")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Dive log")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
        .frame(width: 620, height: 520)
    }
}

struct CompactTimerView: View {
    @ObservedObject var model: FocusDiveViewModel

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().stroke(Color.diveCyan.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: max(0.002, 1 - model.progress))
                    .stroke(Color.diveCyan, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%02d:%02d", model.remainingSeconds / 60, model.remainingSeconds % 60))
                    .font(.system(size: 28, weight: .light, design: .rounded)).monospacedDigit()
                Text(model.currentKind.title.uppercased())
                    .font(.system(size: 8, weight: .medium)).tracking(2)
                    .foregroundStyle(Color.diveAqua)
            }
            Spacer()
            Button(action: model.toggleTimer) {
                Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                    .frame(width: 36, height: 36)
                    .background(Color.diveCyan.opacity(0.16), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .foregroundStyle(Color.diveText)
        .background(Color.diveAbyss)
        .frame(width: 320)
    }
}
