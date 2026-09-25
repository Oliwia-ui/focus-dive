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

    private let store: JSONDiveStore
    private var ticker: Timer?

    init(store: JSONDiveStore = JSONDiveStore()) {
        self.store = store
        let snapshot = (try? store.load()) ?? AppSnapshot(settings: .standard, history: [])
        coordinator = SessionCoordinator(settings: snapshot.settings)
        history = snapshot.history
        mission = ""
        discovery = Self.discovery(for: snapshot.history.count)
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

    func toggleTimer() {
        if isRunning {
            coordinator.pause()
            ticker?.invalidate()
        } else {
            coordinator.mission = mission
            coordinator.start()
            startTicker()
        }
        objectWillChange.send()
    }

    func reset() {
        ticker?.invalidate()
        coordinator.reset()
        objectWillChange.send()
    }

    func skip() {
        ticker?.invalidate()
        coordinator.skip()
        objectWillChange.send()
    }

    func stop() {
        ticker?.invalidate()
        coordinator.stop()
        objectWillChange.send()
    }

    func updateSettings(_ settings: DurationSettings) {
        ticker?.invalidate()
        coordinator.updateSettings(settings)
        persist()
        objectWillChange.send()
    }

    func requestNotificationPermission() {
        guard Bundle.main.bundleIdentifier != nil else { return }
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
        if let entry = coordinator.tick() {
            history.insert(entry, at: 0)
            discovery = Self.discovery(for: history.count)
            persist()
            notifyCompletion()
        }
        if coordinator.timer.state != .running {
            ticker?.invalidate()
        }
        objectWillChange.send()
    }

    private func persist() {
        try? store.save(AppSnapshot(settings: coordinator.settings, history: history))
    }

    private func notifyCompletion() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let content = UNMutableNotificationContent()
        content.title = "Surface reached"
        content.body = "Your focus dive is complete. Take a quiet breath."
        content.sound = nil
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    private static func discovery(for count: Int) -> Discovery? {
        guard count > 0, count.isMultiple(of: 3) else { return nil }
        let discoveries = Discovery.catalog
        return discoveries[(count / 3 - 1) % discoveries.count]
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
