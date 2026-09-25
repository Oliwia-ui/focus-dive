import Foundation

public struct SessionTickResult: Equatable, Sendable {
    public let didComplete: Bool
    public let completedKind: SessionKind?
    public let logEntry: DiveLogEntry?

    public static let noChange = SessionTickResult(didComplete: false, completedKind: nil, logEntry: nil)
}

public final class SessionCoordinator {
    public private(set) var settings: DurationSettings
    public private(set) var timer: DiveTimer
    public private(set) var currentKind: SessionKind = .focus
    public private(set) var completedFocusSessions = 0
    public private(set) var queuePosition = 0
    public var mission = ""

    public init(settings: DurationSettings = .standard) {
        self.settings = settings
        timer = DiveTimer(duration: settings.duration(for: .focus))
    }

    public func start(at date: Date = .now) {
        timer.start(at: date)
    }

    public func pause(at date: Date = .now) {
        timer.pause(at: date)
    }

    public func reset() {
        timer.reset()
    }

    public func stop() {
        timer = DiveTimer(duration: settings.duration(for: currentKind))
    }

    @discardableResult
    public func tick(at date: Date = .now) -> SessionTickResult {
        guard timer.tick(at: date) else { return .noChange }
        let completedKind = currentKind
        let entry = completeCurrentSession(at: date)
        return SessionTickResult(didComplete: true, completedKind: completedKind, logEntry: entry)
    }

    @discardableResult
    public func completeCurrentSession(at date: Date = .now) -> DiveLogEntry? {
        let completedKind = currentKind
        let entry: DiveLogEntry?
        if completedKind == .focus {
            completedFocusSessions += 1
            entry = DiveLogEntry(
                completedAt: date,
                durationSeconds: settings.duration(for: .focus),
                taskName: mission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled focus dive" : mission,
                depthReachedMeters: 60,
                note: ""
            )
        } else {
            entry = nil
        }
        advance(after: completedKind)
        return entry
    }

    public func skip() {
        advance(after: currentKind)
    }

    public func updateSettings(_ settings: DurationSettings) {
        let shouldRefreshIdleTimer = timer.state == .idle
        self.settings = settings
        if shouldRefreshIdleTimer {
            timer = DiveTimer(duration: settings.duration(for: currentKind))
        }
    }

    private func advance(after kind: SessionKind) {
        queuePosition = (queuePosition + 1) % 4
        currentKind = [.focus, .shortBreak, .focus, .longBreak][queuePosition]
        timer = DiveTimer(duration: settings.duration(for: currentKind))
        if settings.automaticallyStartBreaks && currentKind != .focus {
            timer.start()
        }
    }
}
