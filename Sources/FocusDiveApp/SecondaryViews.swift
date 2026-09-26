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
}

struct LogbookView: View {
    @ObservedObject var model: FocusDiveViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if model.history.isEmpty {
                    ContentUnavailableView(
                        "No completed dives",
                        systemImage: "water.waves",
                        description: Text("Completed focus sessions will surface here.")
                    )
                } else {
                    List {
                        if !model.unlockedDiscoveries.isEmpty {
                            Section("Discoveries") {
                                ForEach(model.unlockedDiscoveries) { discovery in
                                    Label {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(discovery.name).font(.headline)
                                            Text(discovery.detail).font(.caption).foregroundStyle(.secondary)
                                        }
                                    } icon: {
                                        Image(systemName: discovery.symbol)
                                            .foregroundStyle(Color.diveAmber)
                                    }
                                }
                            }
                        }

                        Section("Dive profiles") {
                            ForEach(model.history) { entry in
                                VStack(alignment: .leading, spacing: 9) {
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
                                    ProgressView(value: entry.depthReachedMeters, total: 60)
                                        .tint(Color.diveCyan)
                                    TextField("Optional note", text: noteBinding(for: entry))
                                        .textFieldStyle(.roundedBorder)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dive log")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
        .frame(width: 660, height: 580)
    }

    private func noteBinding(for entry: DiveLogEntry) -> Binding<String> {
        Binding(
            get: { model.history.first(where: { $0.id == entry.id })?.note ?? "" },
            set: { model.updateNote(for: entry.id, note: $0) }
        )
    }
}

struct TaskListView: View {
    @ObservedObject var model: FocusDiveViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var editing = TaskListEditingState()

    var body: some View {
        NavigationStack {
            List {
                if let linkedTask {
                    Section("Linked to next focus dive") {
                        HStack {
                            Label(linkedTask.title, systemImage: "link")
                            Spacer()
                            Button("Unlink") { model.linkTask(nil) }
                        }
                    }
                }

                Section("Open tasks") {
                    if openTasks.isEmpty {
                        Text("No open tasks. Add one for your next dive.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(openTasks) { task in
                        taskRow(task)
                    }
                }

                if !completedTasks.isEmpty {
                    Section("Completed") {
                        ForEach(completedTasks) { task in
                            taskRow(task)
                        }
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        editing.editor = TaskEditorContext(task: nil)
                    } label: {
                        Label("New task", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: [.command])
                    .accessibilityIdentifier("new-task")

                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $editing.editor) { context in
                TaskEditorView(task: context.task) { title, details in
                    if let task = context.task {
                        try model.updateTask(id: task.id, title: title, details: details)
                    } else {
                        _ = try model.createTask(title: title, details: details)
                    }
                }
            }
            .alert("Task could not be updated", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(editing.operationError ?? "An unknown task error occurred.")
            }
        }
        .frame(width: 720, height: 620)
    }

    @ViewBuilder
    private func taskRow(_ task: DiveTask) -> some View {
        HStack(spacing: 14) {
            Button {
                perform {
                    try model.setTaskCompleted(!task.isCompleted, id: task.id)
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? Color.diveCyan : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Reopen \(task.title)" : "Complete \(task.title)")

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if !task.isCompleted {
                Button(model.selectedTaskID == task.id ? "Linked" : "Focus") {
                    model.linkTask(task.id)
                }
                .buttonStyle(.bordered)
                .disabled(model.selectedTaskID == task.id)
                .help("Use this task for the next focus dive")
            }

            Menu {
                Button("Edit") { editing.editor = TaskEditorContext(task: task) }
                Button(task.isCompleted ? "Reopen" : "Complete") {
                    perform { try model.setTaskCompleted(!task.isCompleted, id: task.id) }
                }
                Divider()
                Button("Delete", role: .destructive) {
                    perform { try model.deleteTask(id: task.id) }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
            .accessibilityLabel("Task actions for \(task.title)")
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .contain)
    }

    private var openTasks: [DiveTask] {
        model.tasks.items.filter { !$0.isCompleted }.sorted { $0.updatedAt > $1.updatedAt }
    }

    private var completedTasks: [DiveTask] {
        model.tasks.items.filter(\.isCompleted).sorted { $0.updatedAt > $1.updatedAt }
    }

    private var linkedTask: DiveTask? {
        guard let selectedTaskID = model.selectedTaskID else { return nil }
        return model.tasks.items.first { $0.id == selectedTaskID }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { editing.operationError != nil },
            set: { if !$0 { editing.operationError = nil } }
        )
    }

    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch TaskError.blankTitle {
            editing.operationError = "A task needs a title."
        } catch TaskError.notFound {
            editing.operationError = "That task no longer exists."
        } catch {
            editing.operationError = error.localizedDescription
        }
    }
}

private final class TaskListEditingState: ObservableObject {
    @Published var editor: TaskEditorContext?
    @Published var operationError: String?
}

private struct TaskEditorContext: Identifiable {
    let id = UUID()
    let task: DiveTask?
}

private final class TaskEditorEditingState: ObservableObject {
    @Published var title: String
    @Published var details: String
    @Published var errorMessage: String?

    init(title: String, details: String) {
        self.title = title
        self.details = details
    }
}

private struct TaskEditorView: View {
    let task: DiveTask?
    let save: (String, String) throws -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var editing: TaskEditorEditingState

    init(task: DiveTask?, save: @escaping (String, String) throws -> Void) {
        self.task = task
        self.save = save
        _editing = StateObject(
            wrappedValue: TaskEditorEditingState(
                title: task?.title ?? "",
                details: task?.details ?? ""
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(task == nil ? "New task" : "Edit task")
                .font(.system(size: 26, weight: .light, design: .rounded))

            TextField("Task title", text: $editing.title)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("task-title")

            TextField("Notes or activity details", text: $editing.details, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .accessibilityIdentifier("task-details")

            if let errorMessage = editing.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(Color.diveAmber)
            }

            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
                Button("Save") {
                    do {
                        try save(editing.title, editing.details)
                        dismiss()
                    } catch TaskError.blankTitle {
                        editing.errorMessage = "Enter a task title."
                    } catch {
                        editing.errorMessage = error.localizedDescription
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(editing.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("save-task")
            }
        }
        .padding(28)
        .frame(width: 460)
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
