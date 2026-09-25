import Foundation

public enum SessionKind: String, Codable, CaseIterable, Sendable {
    case focus
    case shortBreak
    case longBreak

    public var title: String {
        switch self {
        case .focus: "Focus Dive"
        case .shortBreak: "Short Surface Break"
        case .longBreak: "Long Surface Break"
        }
    }
}

public enum SettingsError: Error, Equatable {
    case nonPositiveDuration
}

public struct DurationSettings: Codable, Equatable, Sendable {
    public var focusMinutes: Int
    public var shortBreakMinutes: Int
    public var longBreakMinutes: Int
    public var automaticallyStartBreaks: Bool
    public var ambienceEnabled: Bool
    public var completionSoundEnabled: Bool

    public init(
        focusMinutes: Int = 25,
        shortBreakMinutes: Int = 5,
        longBreakMinutes: Int = 15,
        automaticallyStartBreaks: Bool = false,
        ambienceEnabled: Bool = false,
        completionSoundEnabled: Bool = false
    ) throws {
        guard focusMinutes > 0, shortBreakMinutes > 0, longBreakMinutes > 0 else {
            throw SettingsError.nonPositiveDuration
        }
        self.focusMinutes = focusMinutes
        self.shortBreakMinutes = shortBreakMinutes
        self.longBreakMinutes = longBreakMinutes
        self.automaticallyStartBreaks = automaticallyStartBreaks
        self.ambienceEnabled = ambienceEnabled
        self.completionSoundEnabled = completionSoundEnabled
    }

    public func duration(for kind: SessionKind) -> Int {
        switch kind {
        case .focus: focusMinutes * 60
        case .shortBreak: shortBreakMinutes * 60
        case .longBreak: longBreakMinutes * 60
        }
    }

    public static var standard: DurationSettings {
        try! DurationSettings()
    }
}
