import Foundation

public enum TimerState: String, Codable, Sendable {
    case idle
    case running
    case paused
    case completed
}

public struct DiveTimer: Equatable, Sendable {
    public let durationSeconds: Int
    public private(set) var remainingSeconds: Int
    public private(set) var state: TimerState = .idle
    private var anchorDate: Date?
    private var anchorRemainingSeconds: Int?

    public init(duration: Int) {
        precondition(duration > 0, "Duration must be positive")
        durationSeconds = duration
        remainingSeconds = duration
    }

    public var progress: Double {
        1 - (Double(remainingSeconds) / Double(durationSeconds))
    }

    public var depthMeters: Double {
        60 * (Double(remainingSeconds) / Double(durationSeconds))
    }

    public func continuousProgress(at date: Date = .now) -> Double {
        1 - (continuousRemainingSeconds(at: date) / Double(durationSeconds))
    }

    public func continuousDepthMeters(at date: Date = .now) -> Double {
        60 * (continuousRemainingSeconds(at: date) / Double(durationSeconds))
    }

    public mutating func start(at date: Date = .now) {
        guard state != .completed, state != .running else { return }
        anchorDate = date
        anchorRemainingSeconds = remainingSeconds
        state = .running
    }

    public mutating func pause(at date: Date = .now) {
        guard state == .running else { return }
        remainingSeconds = remainingSeconds(at: date)
        anchorDate = nil
        anchorRemainingSeconds = nil
        state = .paused
    }

    public mutating func reset() {
        remainingSeconds = durationSeconds
        anchorDate = nil
        anchorRemainingSeconds = nil
        state = .idle
    }

    public func remainingSeconds(at date: Date) -> Int {
        guard state == .running, let anchorDate, let anchorRemainingSeconds else { return remainingSeconds }
        let elapsed = max(0, Int(date.timeIntervalSince(anchorDate)))
        return max(0, anchorRemainingSeconds - elapsed)
    }

    private func continuousRemainingSeconds(at date: Date) -> Double {
        guard state == .running, let anchorDate, let anchorRemainingSeconds else {
            return Double(remainingSeconds)
        }
        let elapsed = max(0, date.timeIntervalSince(anchorDate))
        return max(0, Double(anchorRemainingSeconds) - elapsed)
    }

    @discardableResult
    public mutating func tick(at date: Date = .now) -> Bool {
        guard state == .running else { return false }
        let updatedRemaining = remainingSeconds(at: date)
        remainingSeconds = updatedRemaining
        guard updatedRemaining == 0 else { return false }
        state = .completed
        anchorDate = nil
        anchorRemainingSeconds = nil
        return true
    }
}
