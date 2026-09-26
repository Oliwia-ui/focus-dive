import AppKit
import Combine
import FocusDiveCore
import Foundation
import UserNotifications

@MainActor
final class FocusDiveViewModel: ObservableObject {
    @Published private(set) var coordinator: SessionCoordinator
    @Published private(set) var history: [DiveLogEntry]
    @Published private(set) var tasks: TaskCollection
    @Published var mission: String
    @Published var showSettings = false
    @Published var showLogbook = false
    @Published var showTasks = false
    @Published var isCompact = false
    @Published var selectedTaskID: UUID?
    @Published var discovery: Discovery?
    @Published var completionNotice: CompletionNotice?
    @Published var persistenceError: String?

    private let store: JSONDiveStore
    private var ticker: Timer?
    private var persistenceWritable = true

    init(store: JSONDiveStore? = nil) {
        let resolvedStore: JSONDiveStore
        if let store {
            resolvedStore = store
        } else if ProcessInfo.processInfo.environment["FOCUS_DIVE_UI_TESTING"] == "1" {
            resolvedStore = JSONDiveStore(
                directory: FileManager.default.temporaryDirectory
                    .appendingPathComponent("FocusDiveUITests-\(ProcessInfo.processInfo.processIdentifier)")
            )
        } else {
            resolvedStore = JSONDiveStore()
        }
        self.store = resolvedStore

        let snapshot: AppSnapshot
        do {
            snapshot = try resolvedStore.load()
            persistenceError = nil
        } catch {
            snapshot = AppSnapshot(settings: .standard, history: [])
            persistenceError = "Saved dive data could not be read. The original file has been left untouched."
            persistenceWritable = false
        }

        coordinator = SessionCoordinator(settings: snapshot.settings)
        history = snapshot.history
        tasks = TaskCollection(items: snapshot.tasks)
        mission = ""
        selectedTaskID = nil
        discovery = Self.discovery(for: snapshot.history.count)
        completionNotice = nil
    }

    var settings: DurationSettings { coordinator.settings }
    var timer: DiveTimer { coordinator.timer }
    var currentKind: SessionKind { coordinator.currentKind }
    var remainingSeconds: Int { timer.remainingSeconds }
    var isRunning: Bool { timer.state == .running }
    var timerState: TimerState { timer.state }
    var depth: Double { timer.depthMeters }
    var progress: Double { timer.progress }
    var completedToday: Int {
        history.filter { Calendar.current.isDateInToday($0.completedAt) }.count
    }
    var focusEnergy: Int { max(1, 3 - min(2, completedToday / 2)) }
    var unlockedDiscoveries: [Discovery] {
        Array(Discovery.catalog.prefix(min(Discovery.catalog.count, history.count / 3)))
    }

    func toggleTimer() {
        if timer.state == .completed {
            startNextSession()
            return
        }
        if isRunning {
            coordinator.pause()
            ticker?.invalidate()
        } else {
            completionNotice = nil
            coordinator.mission = mission
            coordinator.linkedTaskID = selectedTaskID
            coordinator.start()
            startTicker()
        }
        objectWillChange.send()
    }

    func startNextSession() {
        completionNotice = nil
        coordinator.startNextSession()
        startTicker()
        objectWillChange.send()
    }

    func staySurfaced() {
        completionNotice = nil
        objectWillChange.send()
    }

    func reset() {
        ticker?.invalidate()
        completionNotice = nil
        coordinator.reset()
        objectWillChange.send()
    }

    func skip() {
        ticker?.invalidate()
        completionNotice = nil
        coordinator.skip()
        if coordinator.timer.state == .running {
            startTicker()
        }
        objectWillChange.send()
    }

    func stop() {
        ticker?.invalidate()
        completionNotice = nil
        coordinator.stop()
        objectWillChange.send()
    }

    func updateSettings(_ settings: DurationSettings) {
        ticker?.invalidate()
        coordinator.updateSettings(settings)
        if coordinator.timer.state == .running {
            startTicker()
        }
        persist()
        objectWillChange.send()
    }

    func minutes(for kind: SessionKind) -> Int {
        switch kind {
        case .focus: settings.focusMinutes
        case .shortBreak: settings.shortBreakMinutes
        case .longBreak: settings.longBreakMinutes
        }
    }

    func updateDuration(for kind: SessionKind, minutes: Int) {
        var updated = settings
        switch kind {
        case .focus:
            updated.focusMinutes = min(max(minutes, 1), 120)
        case .shortBreak:
            updated.shortBreakMinutes = min(max(minutes, 1), 30)
        case .longBreak:
            updated.longBreakMinutes = min(max(minutes, 1), 60)
        }
        updateSettings(updated)
    }

    func updateNote(for entryID: UUID, note: String) {
        guard let index = history.firstIndex(where: { $0.id == entryID }) else { return }
        history[index].note = note
        persist()
    }

    @discardableResult
    func createTask(title: String, details: String = "") throws -> DiveTask {
        let task = try tasks.create(title: title, details: details)
        persist()
        return task
    }

    func updateTask(id: UUID, title: String, details: String) throws {
        try tasks.update(id: id, title: title, details: details)
        persist()
    }

    func setTaskCompleted(_ isCompleted: Bool, id: UUID) throws {
        if isCompleted {
            try tasks.complete(id: id)
        } else {
            try tasks.reopen(id: id)
        }
        persist()
    }

    func deleteTask(id: UUID) throws {
        try tasks.delete(id: id)
        if selectedTaskID == id {
            selectedTaskID = nil
        }
        persist()
    }

    func linkTask(_ id: UUID?) {
        selectedTaskID = id
        guard let id, let task = tasks.items.first(where: { $0.id == id }) else { return }
        mission = task.title
    }

    func requestNotificationPermission() {
        guard ProcessInfo.processInfo.environment["FOCUS_DIVE_UI_TESTING"] != "1",
              Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        let result = coordinator.tick()
        if let entry = result.logEntry {
            history.insert(entry, at: 0)
            discovery = Self.discovery(for: history.count)
        }
        if result.didComplete, let completedKind = result.completedKind {
            completionNotice = CompletionNotice(kind: completedKind)
            persist()
            notifyCompletion(for: completedKind)
        }
        if coordinator.timer.state != .running {
            ticker?.invalidate()
        }
        objectWillChange.send()
    }

    private func persist() {
        guard persistenceWritable else { return }
        do {
            try store.save(
                AppSnapshot(
                    settings: coordinator.settings,
                    history: history,
                    tasks: tasks.items
                )
            )
            persistenceError = nil
        } catch {
            persistenceError = "Focus Dive could not save your latest changes."
            persistenceWritable = false
        }
    }

    private func notifyCompletion(for kind: SessionKind) {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let content = UNMutableNotificationContent()
        content.title = kind == .focus ? "Surface reached" : "Break complete"
        content.body = kind == .focus
            ? "Your focus dive is complete. Take a quiet breath."
            : "Your surface break is complete. Ready for the next dive?"
        content.sound = nil
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        )
    }

    private static func discovery(for count: Int) -> Discovery? {
        guard count > 0, count.isMultiple(of: 3) else { return nil }
        let discoveries = Discovery.catalog
        return discoveries[(count / 3 - 1) % discoveries.count]
    }
}

struct CompletionNotice: Equatable {
    let kind: SessionKind

    var title: String { kind == .focus ? "Dive Complete" : "Break Complete" }
    var detail: String {
        kind == .focus
            ? "You reached the surface. Start a break when you are ready."
            : "Your next focus dive is ready when you are."
    }
    var actionTitle: String { kind == .focus ? "Start Break" : "Start Focus Dive" }
}

struct Discovery: Identifiable, Equatable {
    let id: String
    let name: String
    let symbol: String
    let detail: String

    static let catalog = [
        Discovery(id: "moon-jelly", name: "Moon jelly", symbol: "aqi.medium", detail: "A quiet drifter found near the surface."),
        Discovery(id: "nautilus", name: "Nautilus", symbol: "fossil.shell", detail: "A living spiral from deeper water."),
        Discovery(id: "manta", name: "Manta ray", symbol: "bird.fill", detail: "A wide shadow gliding through cobalt."),
        Discovery(id: "angler", name: "Anglerfish", symbol: "fish.fill", detail: "A patient light in the midnight zone.")
    ]
}
