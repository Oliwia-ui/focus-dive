import AppKit
import Combine
import FocusDiveCore
import Foundation
import UserNotifications

@MainActor
final class FocusDiveViewModel: ObservableObject {
    @Published private(set) var coordinator: SessionCoordinator
    @Published private(set) var history: [DiveLogEntry]
    @Published var mission: String
    @Published var showSettings = false
    @Published var showLogbook = false
    @Published var isCompact = false
    @Published var discovery: Discovery?
    @Published var completionNotice: CompletionNotice?
    @Published var persistenceError: String?
    @Published private(set) var vaultPath: String?
    @Published private(set) var vaultMessage: String?

    private let store: JSONDiveStore
    private var logger: (any FocusEventLogging)?
    private var pendingLogEvents: [FocusLogEvent]
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
        mission = ""
        discovery = Self.discovery(for: snapshot.history.count)
        completionNotice = nil
        vaultPath = snapshot.vaultPath
        pendingLogEvents = snapshot.pendingLogEvents
        logger = snapshot.vaultPath.map { ObsidianFocusLogger(vaultURL: URL(fileURLWithPath: $0)) }

        if logger != nil {
            retryPendingLogEvents()
        }
    }

    var settings: DurationSettings { coordinator.settings }
    var timer: DiveTimer { coordinator.timer }
    var currentKind: SessionKind { coordinator.currentKind }
    var remainingSeconds: Int { timer.remainingSeconds }
    var isRunning: Bool { timer.state == .running }
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
        if isRunning {
            coordinator.pause()
            ticker?.invalidate()
        } else {
            let wasPaused = timer.state == .paused
            completionNotice = nil
            coordinator.mission = mission
            coordinator.start()
            if currentKind == .focus, !wasPaused {
                record(.started, actualDurationSeconds: 0)
            }
            startTicker()
        }
        objectWillChange.send()
    }

    func reset() {
        cancelCurrentFocusSessionIfNeeded()
        ticker?.invalidate()
        completionNotice = nil
        coordinator.reset()
        objectWillChange.send()
    }

    func skip() {
        cancelCurrentFocusSessionIfNeeded()
        ticker?.invalidate()
        completionNotice = nil
        coordinator.skip()
        if coordinator.timer.state == .running {
            startTicker()
        }
        objectWillChange.send()
    }

    func stop() {
        cancelCurrentFocusSessionIfNeeded()
        ticker?.invalidate()
        completionNotice = nil
        coordinator.stop()
        objectWillChange.send()
    }

    func updateSettings(_ settings: DurationSettings) {
        ticker?.invalidate()
        coordinator.updateSettings(settings)
        persist()
        objectWillChange.send()
    }

    func updateNote(for entryID: UUID, note: String) {
        guard let index = history.firstIndex(where: { $0.id == entryID }) else { return }
        history[index].note = note
        persist()
    }

    func requestNotificationPermission() {
        guard ProcessInfo.processInfo.environment["FOCUS_DIVE_UI_TESTING"] != "1",
              Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }

    func chooseVault() {
        let panel = NSOpenPanel()
        panel.title = "Choose your Obsidian vault"
        panel.prompt = "Use This Vault"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }

        vaultPath = url.path
        logger = ObsidianFocusLogger(vaultURL: url)
        vaultMessage = "Logging to \(url.lastPathComponent)"
        retryPendingLogEvents()
        persist()
    }

    func retryPendingLogEvents() {
        guard let logger else {
            vaultMessage = "Choose an Obsidian vault to write activity records."
            return
        }

        var remaining: [FocusLogEvent] = []
        for event in pendingLogEvents {
            do {
                try logger.append(event)
            } catch {
                remaining.append(event)
            }
        }
        pendingLogEvents = remaining
        vaultMessage = remaining.isEmpty
            ? "Obsidian logging is up to date."
            : "\(remaining.count) event(s) still need to be written to Obsidian."
        persist()
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
            record(.completed, actualDurationSeconds: entry.durationSeconds)
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
            try store.save(AppSnapshot(
                settings: coordinator.settings,
                history: history,
                vaultPath: vaultPath,
                pendingLogEvents: pendingLogEvents
            ))
            persistenceError = nil
        } catch {
            persistenceError = "Focus Dive could not save your latest changes."
            persistenceWritable = false
        }
    }

    private func cancelCurrentFocusSessionIfNeeded() {
        guard currentKind == .focus,
              timer.state == .running || timer.state == .paused else { return }
        let activeDuration = max(0, timer.durationSeconds - timer.remainingSeconds(at: .now))
        record(.cancelled, actualDurationSeconds: activeDuration)
    }

    private func record(_ type: FocusLogEventType, actualDurationSeconds: Int) {
        let activity = coordinator.mission.trimmingCharacters(in: .whitespacesAndNewlines)
        let event = FocusLogEvent(
            timestamp: .now,
            type: type,
            activity: activity.isEmpty ? "Untitled focus dive" : activity,
            actualDurationSeconds: actualDurationSeconds
        )

        do {
            guard let logger else { throw VaultNotConfigured() }
            try logger.append(event)
            vaultMessage = "Activity recorded in Obsidian."
        } catch {
            pendingLogEvents.append(event)
            vaultMessage = "Session saved locally. Obsidian logging needs attention."
        }
        persist()
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

    private struct VaultNotConfigured: Error {}
}

struct CompletionNotice: Equatable {
    let kind: SessionKind

    var title: String { kind == .focus ? "Surface reached" : "Break complete" }
    var detail: String {
        kind == .focus
            ? "A quiet focus dive is now in your logbook."
            : "Your next focus dive is ready when you are."
    }
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
