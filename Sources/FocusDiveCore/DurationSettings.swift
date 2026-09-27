import Foundation

public enum SessionKind: String, Codable, CaseIterable, Sendable {
    case focus
    case shortBreak
    case longBreak
    case custom

    public var title: String {
        switch self {
        case .focus: "Focus Dive"
        case .shortBreak: "Short Surface Break"
        case .longBreak: "Long Surface Break"
        case .custom: "Custom Session"
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
    public var customMinutes: Int
    public var automaticallyStartBreaks: Bool
    public var ambienceEnabled: Bool
    public var completionSoundEnabled: Bool

    public init(
        focusMinutes: Int = 25,
        shortBreakMinutes: Int = 5,
        longBreakMinutes: Int = 15,
        customMinutes: Int = 30,
        automaticallyStartBreaks: Bool = false,
        ambienceEnabled: Bool = false,
        completionSoundEnabled: Bool = false
    ) throws {
        guard focusMinutes > 0, shortBreakMinutes > 0, longBreakMinutes > 0, customMinutes > 0 else {
            throw SettingsError.nonPositiveDuration
        }
        self.focusMinutes = focusMinutes
        self.shortBreakMinutes = shortBreakMinutes
        self.longBreakMinutes = longBreakMinutes
        self.customMinutes = customMinutes
        self.automaticallyStartBreaks = automaticallyStartBreaks
        self.ambienceEnabled = ambienceEnabled
        self.completionSoundEnabled = completionSoundEnabled
    }

    public func duration(for kind: SessionKind) -> Int {
        switch kind {
        case .focus: focusMinutes * 60
        case .shortBreak: shortBreakMinutes * 60
        case .longBreak: longBreakMinutes * 60
        case .custom: customMinutes * 60
        }
    }

    private enum CodingKeys: String, CodingKey {
        case focusMinutes
        case shortBreakMinutes
        case longBreakMinutes
        case customMinutes
        case automaticallyStartBreaks
        case ambienceEnabled
        case completionSoundEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            focusMinutes: container.decode(Int.self, forKey: .focusMinutes),
            shortBreakMinutes: container.decode(Int.self, forKey: .shortBreakMinutes),
            longBreakMinutes: container.decode(Int.self, forKey: .longBreakMinutes),
            customMinutes: container.decodeIfPresent(Int.self, forKey: .customMinutes) ?? 30,
            automaticallyStartBreaks: container.decodeIfPresent(Bool.self, forKey: .automaticallyStartBreaks) ?? false,
            ambienceEnabled: container.decodeIfPresent(Bool.self, forKey: .ambienceEnabled) ?? false,
            completionSoundEnabled: container.decodeIfPresent(Bool.self, forKey: .completionSoundEnabled) ?? false
        )
    }

    public static var standard: DurationSettings {
        try! DurationSettings()
    }
}
