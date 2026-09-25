import FocusDiveCore
import SwiftUI

struct RightRail: View {
    @ObservedObject var model: FocusDiveViewModel

    var body: some View {
        VStack(spacing: 18) {
            SessionQueueCard(model: model)
            WeeklyDepthProfile(history: model.history)
            controlRow
        }
    }

    private var controlRow: some View {
        HStack(spacing: 12) {
            control("arrow.counterclockwise", label: "Reset", action: model.reset)
                .accessibilityIdentifier("reset-timer-control")
            control("forward.end", label: "Skip", action: model.skip)
            control("stop.fill", label: "Stop", action: model.stop)
        }
        .frame(maxWidth: .infinity)
    }

    private func control(_ icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(label.uppercased()).font(.system(size: 9, weight: .medium)).tracking(1.2)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.diveAqua.opacity(0.22)))
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.diveAqua)
    }
}

struct SessionQueueCard: View {
    @ObservedObject var model: FocusDiveViewModel

    private var queue: [(SessionKind, Int)] {
        [
            (.focus, model.settings.focusMinutes),
            (.shortBreak, model.settings.shortBreakMinutes),
            (.focus, model.settings.focusMinutes),
            (.longBreak, model.settings.longBreakMinutes)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionLabel(title: "Session queue")
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color.diveAqua)
            }

            ForEach(Array(queue.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(Color.diveAqua.opacity(0.75), lineWidth: 1.5)
                        if index == activeIndex {
                            Circle().fill(Color.diveCyan.opacity(0.28)).padding(5)
                            Circle().stroke(Color.diveCyan, lineWidth: 2).padding(5)
                        }
                    }
                    .frame(width: 29, height: 29)
                    .shadow(color: index == activeIndex ? .diveCyan : .clear, radius: 9)

                    Text(item.0.title.replacingOccurrences(of: " Surface", with: ""))
                        .font(.system(size: 14, weight: index == activeIndex ? .medium : .regular, design: .rounded))
                    Spacer()
                    Text("\(item.1) min")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.diveAqua)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(index == activeIndex ? Color.diveCyan.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(22)
        .divePanel()
    }

    private var activeIndex: Int {
        switch model.currentKind {
        case .focus: 0
        case .shortBreak: 1
        case .longBreak: 3
        }
    }
}

struct WeeklyDepthProfile: View {
    let history: [DiveLogEntry]

    private var values: [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let count = history.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
            return min(1, Double(count) / 4)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionLabel(title: "Weekly depth profile")
            HStack(alignment: .bottom, spacing: 16) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            Capsule().fill(Color.diveAqua.opacity(0.07))
                            Capsule()
                                .fill(LinearGradient(colors: [.diveCyan, .diveCobalt.opacity(0.25)], startPoint: .top, endPoint: .bottom))
                                .frame(height: max(12, 82 * value))
                                .shadow(color: .diveCyan.opacity(value > 0 ? 0.45 : 0), radius: 7)
                        }
                        .frame(width: 16, height: 86)
                        Text(dayLetter(index))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.diveAqua)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(22)
        .divePanel()
    }

    private func dayLetter(_ index: Int) -> String {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        let weekday = Calendar.current.component(.weekday, from: Calendar.current.date(byAdding: .day, value: index - 6, to: .now)!)
        return symbols[weekday - 1]
    }
}

struct StreakCard: View {
    let history: [DiveLogEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9) {
                ForEach(0..<7) { offset in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(hasDive(daysAgo: 6 - offset) ? Color.diveCyan : Color.diveAqua.opacity(0.16))
                        .frame(width: 22, height: 8)
                        .shadow(color: hasDive(daysAgo: 6 - offset) ? .diveCyan.opacity(0.5) : .clear, radius: 5)
                }
            }
            Label("\(streak) day streak", systemImage: "calendar")
                .font(.system(size: 15, weight: .medium, design: .rounded))
        }
        .padding(20)
        .divePanel()
    }

    private var streak: Int {
        var result = 0
        for day in 0..<7 {
            if hasDive(daysAgo: day) { result += 1 } else if day > 0 { break }
        }
        return result
    }

    private func hasDive(daysAgo: Int) -> Bool {
        guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now) else { return false }
        return history.contains { Calendar.current.isDate($0.completedAt, inSameDayAs: date) }
    }
}

struct FocusEnergyCard: View {
    let energy: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionLabel(title: "Focus energy")
            HStack(spacing: 17) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < energy ? Color.diveCyan : .clear)
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(Color.diveCyan.opacity(0.65)))
                        .shadow(color: index < energy ? .diveCyan.opacity(0.8) : .clear, radius: 10)
                }
            }
        }
        .padding(20)
        .divePanel()
    }
}

struct DiscoveryCard: View {
    let discovery: Discovery

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: discovery.symbol)
                .font(.system(size: 42, weight: .ultraLight))
                .foregroundStyle(Color.diveAmber)
                .shadow(color: .diveAmber.opacity(0.55), radius: 14)
            VStack(alignment: .leading, spacing: 5) {
                Text("NEW DISCOVERY")
                    .font(.system(size: 9, weight: .semibold)).tracking(2)
                    .foregroundStyle(Color.diveAmber)
                Text(discovery.name)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                Text(discovery.detail)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.diveAqua)
            }
        }
        .padding(18)
        .frame(maxWidth: 300)
        .divePanel()
    }
}
