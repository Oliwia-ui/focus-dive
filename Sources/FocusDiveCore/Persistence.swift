import Foundation

public struct DiveLogEntry: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let completedAt: Date
    public let durationSeconds: Int
    public let taskName: String
    public let depthReachedMeters: Double
    public var note: String

    public init(
        id: UUID = UUID(),
        completedAt: Date,
        durationSeconds: Int,
        taskName: String,
        depthReachedMeters: Double,
        note: String
    ) {
        self.id = id
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.taskName = taskName
        self.depthReachedMeters = depthReachedMeters
        self.note = note
    }
}

public struct AppSnapshot: Codable, Equatable, Sendable {
    public var settings: DurationSettings
    public var history: [DiveLogEntry]
    public var tasks: [DiveTask]

    public init(
        settings: DurationSettings,
        history: [DiveLogEntry],
        tasks: [DiveTask] = []
    ) {
        self.settings = settings
        self.history = history
        self.tasks = tasks
    }

    private enum CodingKeys: String, CodingKey {
        case settings
        case history
        case tasks
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decode(DurationSettings.self, forKey: .settings)
        history = try container.decode([DiveLogEntry].self, forKey: .history)
        tasks = try container.decodeIfPresent([DiveTask].self, forKey: .tasks) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(settings, forKey: .settings)
        try container.encode(history, forKey: .history)
        try container.encode(tasks, forKey: .tasks)
    }
}

public struct JSONDiveStore: Sendable {
    private let fileURL: URL

    public init(directory: URL? = nil) {
        let base = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FocusDive", isDirectory: true)
        fileURL = base.appendingPathComponent("focus-dive.json")
    }

    public func save(_ snapshot: AppSnapshot) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(snapshot).write(to: fileURL, options: .atomic)
    }

    public func load() throws -> AppSnapshot {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return AppSnapshot(settings: .standard, history: [])
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AppSnapshot.self, from: Data(contentsOf: fileURL))
    }
}
