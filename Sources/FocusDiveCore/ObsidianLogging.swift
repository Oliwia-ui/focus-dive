import Foundation

public enum ObsidianLogCategory: String, Sendable {
    case tasks = "Tasks"
    case sessions = "Sessions"
    case reflections = "Reflections"
}

public struct ObsidianEventRecord: Equatable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let eventType: String
    public let status: String
    public let taskOrActivity: String
    public let taskID: UUID?
    public let actualDurationSeconds: Int?

    public init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        eventType: String,
        status: String,
        taskOrActivity: String,
        taskID: UUID? = nil,
        actualDurationSeconds: Int? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
        self.status = status
        self.taskOrActivity = taskOrActivity
        self.taskID = taskID
        self.actualDurationSeconds = actualDurationSeconds
    }
}

public struct ObsidianMarkdownLogger: Sendable {
    private let vaultURL: URL
    private let timeZone: TimeZone

    public init(vaultURL: URL, timeZone: TimeZone = .current) {
        self.vaultURL = vaultURL
        self.timeZone = timeZone
    }

    public func append(
        _ record: ObsidianEventRecord,
        category: ObsidianLogCategory
    ) throws {
        let directory = vaultURL
            .appendingPathComponent("Focus Dive", isDirectory: true)
            .appendingPathComponent(category.rawValue, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let fileURL = directory.appendingPathComponent("\(dateString(record.timestamp)).md")
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let header = "# Focus Dive \(category.rawValue) — \(dateString(record.timestamp))\n\n"
            try Data(header.utf8).write(to: fileURL, options: .withoutOverwriting)
        }

        let handle = try FileHandle(forWritingTo: fileURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: Data(markdown(for: record).utf8))
    }

    private func markdown(for record: ObsidianEventRecord) -> String {
        let duration = record.actualDurationSeconds.map { "\($0) seconds" } ?? "n/a"
        let taskID = record.taskID?.uuidString ?? "n/a"
        return """
        ## \(timeString(record.timestamp)) · \(singleLine(record.eventType))

        - Date: \(dateString(record.timestamp))
        - Time: \(timeString(record.timestamp))
        - Timezone: \(timeZoneString(record.timestamp))
        - Event type: \(singleLine(record.eventType))
        - Status: \(singleLine(record.status))
        - Task/activity: \(singleLine(record.taskOrActivity))
        - Task ID: \(taskID)
        - Actual session duration: \(duration)
        - Event ID: \(record.id.uuidString)

        """
    }

    private func dateString(_ date: Date) -> String {
        formatter("yyyy-MM-dd").string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        formatter("HH:mm:ss").string(from: date)
    }

    private func timeZoneString(_ date: Date) -> String {
        formatter("zzz").string(from: date)
    }

    private func formatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }

    private func singleLine(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
