import Foundation
import Testing
@testable import FocusDiveCore

@Test("focus events append readable Markdown without replacing earlier events")
func focusEventsAppendToTheSameDailyFile() throws {
    let vault = FileManager.default.temporaryDirectory
        .appendingPathComponent("FocusDiveObsidianTests-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: vault) }

    let logger = ObsidianFocusLogger(
        vaultURL: vault,
        timeZone: TimeZone(secondsFromGMT: 7_200)!
    )
    let timestamp = Date(timeIntervalSince1970: 1_727_123_456)
    try logger.append(FocusLogEvent(
        timestamp: timestamp,
        type: .started,
        activity: "Write report",
        actualDurationSeconds: 0
    ))
    let fileURL = try logger.append(FocusLogEvent(
        timestamp: timestamp,
        type: .completed,
        activity: "Write report",
        actualDurationSeconds: 1_505
    ))

    let markdown = try String(contentsOf: fileURL, encoding: .utf8)
    #expect(markdown.contains("focus_session_started"))
    #expect(markdown.contains("focus_session_completed"))
    #expect(markdown.contains("actual_duration_seconds: 1505"))
    #expect(markdown.contains("Europe") == false)
    #expect(markdown.components(separatedBy: "## ").count == 2)
}
