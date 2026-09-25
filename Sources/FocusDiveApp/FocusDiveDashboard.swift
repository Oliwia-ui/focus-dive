import FocusDiveCore
import SwiftUI

struct FocusDiveDashboard: View {
    @ObservedObject var model: FocusDiveViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            OceanBackground(progress: model.progress, reduceMotion: reduceMotion)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 28)
                    .padding(.top, 18)

                HStack(alignment: .center, spacing: 28) {
                    DepthGauge(depth: model.depth, isRunning: model.isRunning)
                        .frame(width: 118)

                    VStack(spacing: 22) {
                        missionField
                        TimerConsole(model: model, reduceMotion: reduceMotion)
                            .frame(maxWidth: 610, maxHeight: 610)
                        Text("DEEPER WORK  •  BRIGHTER DAYS")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .tracking(4)
                            .foregroundStyle(Color.diveAqua.opacity(0.65))
                    }
                    .frame(maxWidth: .infinity)

                    RightRail(model: model)
                        .frame(width: 330)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 16)

                bottomBar
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
            }
        }
        .foregroundStyle(Color.diveText)
        .frame(minWidth: 1_100, minHeight: 720)
        .sheet(isPresented: $model.showSettings) {
            SettingsView(model: model)
        }
        .sheet(isPresented: $model.showLogbook) {
            LogbookView(history: model.history)
        }
        .onAppear { model.requestNotificationPermission() }
    }

    private var header: some View {
        HStack {
            Color.clear.frame(width: 96, height: 1)

            Spacer()

            VStack(spacing: 6) {
                Image(systemName: "water.waves")
                    .font(.system(size: 23, weight: .light))
                    .foregroundStyle(Color.diveCyan)
                    .shadow(color: .diveCyan.opacity(0.65), radius: 10)
                Text("FOCUS DIVE")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .tracking(7)
            }

            Spacer()

            HStack(spacing: 22) {
                Button { model.showLogbook.toggle() } label: {
                    Image(systemName: "waveform.path.ecg")
                }
                .help("Open dive log")

                Button { model.showSettings.toggle() } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .help("Session settings")

                Button { model.isCompact.toggle() } label: {
                    Image(systemName: "rectangle.split.2x1")
                }
                .help("Toggle compact timer")
            }
            .buttonStyle(.plain)
            .font(.system(size: 17, weight: .light))
            .foregroundStyle(Color.diveAqua)
        }
        .frame(height: 58)
    }

    private var missionField: some View {
        HStack(spacing: 10) {
            Image(systemName: "scope")
                .foregroundStyle(Color.diveCyan)
            TextField("Set a current mission…", text: $model.mission)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .accessibilityLabel("Current mission")
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: 420, minHeight: 38)
        .background(.black.opacity(0.16), in: Capsule())
        .overlay(Capsule().stroke(Color.diveAqua.opacity(0.2)))
    }

    private var bottomBar: some View {
        HStack(alignment: .bottom) {
            StreakCard(history: model.history)
            Spacer()
            if let discovery = model.discovery {
                DiscoveryCard(discovery: discovery)
            }
            FocusEnergyCard(energy: model.focusEnergy)
        }
    }
}

struct TimerConsole: View {
    @ObservedObject var model: FocusDiveViewModel
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                BubbleField(reduceMotion: reduceMotion)
                    .frame(width: side, height: side)

                Circle()
                    .stroke(Color.diveCyan.opacity(0.12), lineWidth: 22)
                    .padding(30)

                Circle()
                    .trim(from: 0, to: max(0.002, 1 - model.progress))
                    .stroke(
                        AngularGradient(colors: [.diveCyan, .white, .diveCyan.opacity(0.65)], center: .center),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(30)
                    .shadow(color: .diveCyan.opacity(0.72), radius: 14)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.progress)

                Circle()
                    .stroke(Color.diveCyan.opacity(0.62), lineWidth: 1)
                    .padding(17)
                Circle()
                    .stroke(Color.diveAqua.opacity(0.18), lineWidth: 1)
                    .padding(42)

                VStack(spacing: 26) {
                    VStack(spacing: 8) {
                        Text(model.currentKind.title.uppercased())
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .tracking(3)
                            .foregroundStyle(Color.diveAqua)
                        Text(formattedTime)
                            .font(.system(size: side * 0.185, weight: .ultraLight, design: .rounded))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .accessibilityIdentifier("timer-display")
                            .accessibilityLabel("Time remaining \(formattedTime)")
                    }

                    Button(action: model.toggleTimer) {
                        Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .frame(width: 72, height: 72)
                            .background(.black.opacity(0.25), in: Circle())
                            .overlay(Circle().stroke(Color.diveCyan.opacity(0.55)))
                            .shadow(color: .diveCyan.opacity(0.28), radius: 18)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.space, modifiers: [])
                    .accessibilityIdentifier("primary-timer-control")
                    .accessibilityLabel(model.isRunning ? "Pause focus timer" : "Start focus timer")
                }

                HStack(spacing: side * 0.48) {
                    tickMark
                    tickMark
                }
                VStack(spacing: side * 0.48) {
                    tickMark.rotationEffect(.degrees(90))
                    tickMark.rotationEffect(.degrees(90))
                }
            }
            .frame(width: side, height: side)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var tickMark: some View {
        Rectangle().fill(Color.diveAqua.opacity(0.7)).frame(width: 14, height: 1)
    }

    private var formattedTime: String {
        String(format: "%02d:%02d", model.remainingSeconds / 60, model.remainingSeconds % 60)
    }
}

struct DepthGauge: View {
    let depth: Double
    let isRunning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(Int(depth.rounded())) m")
                .font(.system(size: 42, weight: .light, design: .rounded))
                .monospacedDigit()
            SectionLabel(title: isRunning ? "Ascending" : "Ready")

            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.diveAqua.opacity(0.16))
                        .frame(width: 1)

                    Capsule()
                        .fill(LinearGradient(colors: [.diveCyan, .diveCyan.opacity(0.08)], startPoint: .bottom, endPoint: .top))
                        .frame(width: 12, height: proxy.size.height * max(0.02, depth / 60))
                        .overlay(Capsule().stroke(Color.diveCyan.opacity(0.55)))
                        .shadow(color: .diveCyan.opacity(0.6), radius: 8)

                    VStack {
                        ForEach(0..<13) { _ in
                            Rectangle().fill(Color.diveAqua.opacity(0.7)).frame(width: 18, height: 1)
                            Spacer()
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 440)
            .accessibilityLabel("Current depth \(Int(depth.rounded())) meters")
        }
        .padding(.leading, 12)
    }
}
