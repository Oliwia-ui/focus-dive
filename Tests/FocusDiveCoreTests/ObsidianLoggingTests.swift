import Foundation
import Testing
@testable import FocusDiveCore

@Test func obsidianLoggerCreatesPredictableFoldersAndAppendOnlyRecords() throws {
    let vault = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let logger = ObsidianMarkdownLogger(
        vaultURL: vault,
        timeZone: TimeZone(secondsFromGMT: 0)!
    )
    let taskID = UUID()

    try logger.append(
        ObsidianEventRecord(
            timestamp: Date(timeIntervalSince1970: 100),
            eventType: "task-created",
            status: "open",
            taskOrActivity: "Prepare prototype",
            taskID: taskID
        ),
        category: .tasks
    )
    try logger.append(
        ObsidianEventRecord(
            timestamp: Date(timeIntervalSince1970: 200),
            eventType: "task-completed",
            status: "completed",
            taskOrActivity: "Prepare prototype",
            taskID: taskID
        ),
        category: .tasks
    )

    let fileURL = vault
        .appendingPathComponent("Focus Dive/Tasks", isDirectory: true)
        .appendingPathComponent("1970-01-01.md")
    let markdown = try String(contentsOf: fileURL, encoding: .utf8)

    #expect(markdown.components(separatedBy: "## ").count - 1 == 2)
    #expect(markdown.contains("Event type: task-created"))
    #expect(markdown.contains("Event type: task-completed"))
    #expect(markdown.contains("Timezone: GMT"))
    #expect(markdown.contains("Task/activity: Prepare prototype"))
    #expect(markdown.contains(taskID.uuidString))
}

@Test func obsidianSessionRecordIncludesActualDurationAndCancellationStatus() throws {
    let vault = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let logger = ObsidianMarkdownLogger(
        vaultURL: vault,
        timeZone: TimeZone(secondsFromGMT: 0)!
    )

    try logger.append(
        ObsidianEventRecord(
            timestamp: Date(timeIntervalSince1970: 300),
            eventType: "focus-session-cancelled",
            status: "cancelled",
            taskOrActivity: "Draft report",
            actualDurationSeconds: 125
        ),
        category: .sessions
    )

    let fileURL = vault
        .appendingPathComponent("Focus Dive/Sessions", isDirectory: true)
        .appendingPathComponent("1970-01-01.md")
    let markdown = try String(contentsOf: fileURL, encoding: .utf8)

    #expect(markdown.contains("Actual session duration: 125 seconds"))
    #expect(markdown.contains("Status: cancelled"))
}
