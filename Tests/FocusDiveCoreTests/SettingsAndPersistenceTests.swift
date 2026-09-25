import Foundation
import Testing
@testable import FocusDiveCore

@Test func durationSettingsRejectNonPositiveValues() {
    #expect(throws: Error.self) {
        _ = try DurationSettings(focusMinutes: 0, shortBreakMinutes: 5, longBreakMinutes: 15)
    }
    #expect(throws: Error.self) {
        _ = try DurationSettings(focusMinutes: 25, shortBreakMinutes: -1, longBreakMinutes: 15)
    }
}

@Test func durationSettingsConvertMinutesToSeconds() throws {
    let settings = try DurationSettings(focusMinutes: 30, shortBreakMinutes: 7, longBreakMinutes: 20)

    #expect(settings.duration(for: .focus) == 1_800)
    #expect(settings.duration(for: .shortBreak) == 420)
    #expect(settings.duration(for: .longBreak) == 1_200)
}

@Test func sessionCompletionCreatesDiveLogEntry() throws {
    let coordinator = SessionCoordinator(settings: try .init(focusMinutes: 25, shortBreakMinutes: 5, longBreakMinutes: 15))
    let taskID = UUID()
    coordinator.mission = "Finish project proposal"
    coordinator.linkedTaskID = taskID
    coordinator.start(at: Date(timeIntervalSince1970: 100))

    let entry = coordinator.completeCurrentSession(at: Date(timeIntervalSince1970: 1_600))

    #expect(entry?.taskName == "Finish project proposal")
    #expect(entry?.taskID == taskID)
    #expect(entry?.durationSeconds == 1_500)
    #expect(entry?.depthReachedMeters == 60)
    #expect(coordinator.currentKind == .shortBreak)
}

@Test func jsonStoreRoundTripsSettingsAndHistory() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let store = JSONDiveStore(directory: directory)
    let settings = try DurationSettings(focusMinutes: 45, shortBreakMinutes: 8, longBreakMinutes: 25)
    let entry = DiveLogEntry(
        completedAt: Date(timeIntervalSince1970: 42),
        durationSeconds: 2_700,
        taskName: "Design the ascent",
        depthReachedMeters: 60,
        note: "Quiet session"
    )

    try store.save(AppSnapshot(settings: settings, history: [entry]))
    let restored = try store.load()

    #expect(restored.settings == settings)
    #expect(restored.history == [entry])
}

@Test func sessionQueueAdvancesFocusShortFocusLong() throws {
    let coordinator = SessionCoordinator(settings: try .init(focusMinutes: 25, shortBreakMinutes: 5, longBreakMinutes: 15))

    #expect(coordinator.queuePosition == 0)
    _ = coordinator.completeCurrentSession()
    #expect(coordinator.currentKind == .shortBreak)
    #expect(coordinator.queuePosition == 1)

    coordinator.skip()
    #expect(coordinator.currentKind == .focus)
    #expect(coordinator.queuePosition == 2)

    _ = coordinator.completeCurrentSession()
    #expect(coordinator.currentKind == .longBreak)
    #expect(coordinator.queuePosition == 3)
}

@Test func breakCompletionIsReportedWithoutCreatingLogEntry() throws {
    let coordinator = SessionCoordinator(settings: try .init(focusMinutes: 25, shortBreakMinutes: 5, longBreakMinutes: 15))
    coordinator.skip()
    coordinator.start(at: Date(timeIntervalSince1970: 0))

    let result = coordinator.tick(at: Date(timeIntervalSince1970: 300))

    #expect(result.didComplete)
    #expect(result.logEntry == nil)
    #expect(result.completedKind == .shortBreak)
}

@Test func changingDurationsRefreshesAnIdleSession() throws {
    let coordinator = SessionCoordinator(settings: try .init(focusMinutes: 25, shortBreakMinutes: 5, longBreakMinutes: 15))

    coordinator.updateSettings(try .init(focusMinutes: 40, shortBreakMinutes: 8, longBreakMinutes: 20))

    #expect(coordinator.timer.durationSeconds == 2_400)
    #expect(coordinator.timer.remainingSeconds == 2_400)
}

@Test func changingDurationsDoesNotInterruptARunningSession() throws {
    let coordinator = SessionCoordinator(settings: try .init(focusMinutes: 25, shortBreakMinutes: 5, longBreakMinutes: 15))
    coordinator.start(at: Date(timeIntervalSince1970: 0))
    _ = coordinator.tick(at: Date(timeIntervalSince1970: 60))

    coordinator.updateSettings(try .init(focusMinutes: 40, shortBreakMinutes: 8, longBreakMinutes: 20))

    #expect(coordinator.timer.state == .running)
    #expect(coordinator.timer.remainingSeconds == 1_440)
    #expect(coordinator.settings.focusMinutes == 40)
}

@Test func taskCollectionSupportsTheRequiredLifecycle() throws {
    let createdAt = Date(timeIntervalSince1970: 100)
    var collection = TaskCollection()

    let task = try collection.create(
        title: "Write research summary",
        details: "Compare three focus applications",
        at: createdAt
    )
    #expect(collection.items == [task])
    #expect(task.title == "Write research summary")
    #expect(!task.isCompleted)

    try collection.update(
        id: task.id,
        title: "Write timer research summary",
        details: "Compare three timer applications",
        at: Date(timeIntervalSince1970: 200)
    )
    #expect(collection.items[0].title == "Write timer research summary")
    #expect(collection.items[0].updatedAt == Date(timeIntervalSince1970: 200))

    try collection.complete(id: task.id, at: Date(timeIntervalSince1970: 300))
    #expect(collection.items[0].isCompleted)
    #expect(collection.items[0].completedAt == Date(timeIntervalSince1970: 300))

    try collection.reopen(id: task.id, at: Date(timeIntervalSince1970: 400))
    #expect(!collection.items[0].isCompleted)
    #expect(collection.items[0].completedAt == nil)

    let deleted = try collection.delete(id: task.id)
    #expect(deleted.id == task.id)
    #expect(collection.items.isEmpty)
}

@Test func taskCollectionRejectsBlankTitlesAndMissingTasks() throws {
    var collection = TaskCollection()

    #expect(throws: TaskError.blankTitle) {
        _ = try collection.create(title: "   ", at: .now)
    }
    #expect(throws: TaskError.notFound) {
        try collection.complete(id: UUID(), at: .now)
    }
}

@Test func jsonStoreRoundTripsTasks() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let store = JSONDiveStore(directory: directory)
    var tasks = TaskCollection()
    _ = try tasks.create(title: "Prepare prototype", at: Date(timeIntervalSince1970: 55))
    let snapshot = AppSnapshot(settings: .standard, history: [], tasks: tasks.items)

    try store.save(snapshot)
    let restored = try store.load()

    #expect(restored.tasks == tasks.items)
}

@Test func snapshotDecodesLegacyFilesWithoutTasks() throws {
    let data = Data("""
    {
      "settings": {
        "focusMinutes": 25,
        "shortBreakMinutes": 5,
        "longBreakMinutes": 15,
        "automaticallyStartBreaks": false,
        "ambienceEnabled": false,
        "completionSoundEnabled": false
      },
      "history": []
    }
    """.utf8)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let snapshot = try decoder.decode(AppSnapshot.self, from: data)

    #expect(snapshot.tasks.isEmpty)
}
