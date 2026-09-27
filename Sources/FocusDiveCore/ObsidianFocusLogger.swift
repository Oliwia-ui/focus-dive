import Foundation

public enum FocusLogEventType: String, Codable, Sendable {
    case started = "focus_session_started"
    case completed = "focus_session_completed"
    case cancelled = "focus_session_cancelled"
}

public struct FocusLogEvent: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let type: FocusLogEventType
    public let activity: String
    public let actualDurationSeconds: Int

    public init(
        id: UUID = UUID(),
        timestamp: Date,
        type: FocusLogEventType,
        activity: String,
        actualDurationSeconds: Int
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.activity = activity
        self.actualDurationSeconds = max(0, actualDurationSeconds)
    }
}

public protocol FocusEventLogging: Sendable {
    @discardableResult
    func append(_ event: FocusLogEvent) throws -> URL
}

public final class ObsidianFocusLogger: FocusEventLogging, @unchecked Sendable {
    private let vaultURL: URL
    private let timeZone: TimeZone
    private let lock = NSLock()

    public init(vaultURL: URL, timeZone: TimeZone = .current) {
        self.vaultURL = vaultURL
        self.timeZone = timeZone
    }

    @discardableResult
    public func append(_ event: FocusLogEvent) throws -> URL {
        try lock.withLock {
            let date = formatted(event.timestamp, format: "yyyy-MM-dd")
            let directory = vaultURL
                .appendingPathComponent("Productivity Log", isDirectory: true)
                .appendingPathComponent("Focus", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

            let fileURL = directory.appendingPathComponent("\(date).md")
            let isNewFile = !FileManager.default.fileExists(atPath: fileURL.path)
            if isNewFile {
                guard FileManager.default.createFile(atPath: fileURL.path, contents: nil) else {
                    throw CocoaError(.fileWriteUnknown)
                }
            }

            let handle = try FileHandle(forWritingTo: fileURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            var markdown = isNewFile ? "## \(date)\n\n" : ""
            markdown += render(event)
            try handle.write(contentsOf: Data(markdown.utf8))
            try handle.synchronize()
            return fileURL
        }
    }

    private func render(_ event: FocusLogEvent) -> String {
        let time = formatted(event.timestamp, format: "HH:mm:ss")
        let duration = "\(event.actualDurationSeconds / 60)m \(event.actualDurationSeconds % 60)s"
        return [
            "- \(time) \(timeZone.identifier) | \(event.type.rawValue)",
            "  - id: \(event.id.uuidString)",
            "  - status: \(status(for: event.type))",
            "  - activity: “\(sanitized(event.activity))”",
            "  - actual_duration_seconds: \(event.actualDurationSeconds)",
            "  - actual_duration: \(duration)",
            "",
        ].joined(separator: "\n")
    }

    private func status(for type: FocusLogEventType) -> String {
        switch type {
        case .started: "running"
        case .completed: "completed"
        case .cancelled: "cancelled"
        }
    }

    private func formatted(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private func sanitized(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\r\n", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
    }
}
