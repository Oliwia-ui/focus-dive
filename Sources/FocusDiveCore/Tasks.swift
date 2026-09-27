import Foundation

public enum TaskError: Error, Equatable, Sendable {
    case blankTitle
    case notFound
}

public struct DiveTask: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var details: String
    public let createdAt: Date
    public var updatedAt: Date
    public var completedAt: Date?

    public var isCompleted: Bool { completedAt != nil }

    public init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        createdAt: Date,
        updatedAt: Date,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
}

public struct TaskCollection: Codable, Equatable, Sendable {
    public private(set) var items: [DiveTask]

    public init(items: [DiveTask] = []) {
        self.items = items
    }

    @discardableResult
    public mutating func create(
        title: String,
        details: String = "",
        at date: Date = .now
    ) throws -> DiveTask {
        let normalizedTitle = try validatedTitle(title)
        let task = DiveTask(
            title: normalizedTitle,
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: date,
            updatedAt: date
        )
        items.append(task)
        return task
    }

    public mutating func update(
        id: UUID,
        title: String,
        details: String,
        at date: Date = .now
    ) throws {
        let index = try index(for: id)
        items[index].title = try validatedTitle(title)
        items[index].details = details.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].updatedAt = date
    }

    public mutating func complete(id: UUID, at date: Date = .now) throws {
        let index = try index(for: id)
        items[index].completedAt = date
        items[index].updatedAt = date
    }

    public mutating func reopen(id: UUID, at date: Date = .now) throws {
        let index = try index(for: id)
        items[index].completedAt = nil
        items[index].updatedAt = date
    }

    @discardableResult
    public mutating func delete(id: UUID) throws -> DiveTask {
        let index = try index(for: id)
        return items.remove(at: index)
    }

    private func index(for id: UUID) throws -> Int {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            throw TaskError.notFound
        }
        return index
    }

    private func validatedTitle(_ title: String) throws -> String {
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { throw TaskError.blankTitle }
        return normalized
    }
}
