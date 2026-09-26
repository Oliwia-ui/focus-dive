import FocusDiveCore
import SwiftUI

struct FocusDiveDashboard: View {
    @ObservedObject var model: FocusDiveViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            OceanBackground(
                progress: model.presentationProgress,
                reduceMotion: reduceMotion,
                isActive: model.isRunning,
                accent: model.currentKind.accentColor
            )

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.diveAbyss.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.diveAqua.opacity(0.46), lineWidth: 0.8)
                }
                .padding(.horizontal, 38)
                .padding(.vertical, 38)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 58)
                    .padding(.top, 42)

                HStack(alignment: .center, spacing: 20) {
                    DepthGauge(
                        depth: model.presentationDepth,
                        state: model.timerState,
                        kind: model.currentKind,
                        reduceMotion: reduceMotion
                    )
                        .frame(width: 280)

                    VStack(spacing: 8) {
                        TimerConsole(model: model, reduceMotion: reduceMotion)
                            .frame(width: 560, height: 560)
                        Text("DEEPER WORK  •  BRIGHTER DAYS")
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .tracking(4)
                            .foregroundStyle(Color.diveAqua.opacity(0.65))
                    }
                    .frame(maxWidth: .infinity)

                    RightRail(model: model)
                        .frame(width: 350)
                }
                .padding(.horizontal, 58)
                .padding(.bottom, 10)

                bottomBar
                    .padding(.horizontal, 58)
                    .padding(.bottom, 52)
            }

            if let notice = model.completionNotice {
                completionOverlay(notice)
            }

            if let persistenceError = model.persistenceError {
                VStack {
                    Spacer()
                    Label(persistenceError, systemImage: "externaldrive.badge.exclamationmark")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.72), in: Capsule())
                        .overlay(Capsule().stroke(Color.diveAmber.opacity(0.6)))
                        .foregroundStyle(Color.diveAmber)
                        .padding(.bottom, 18)
                }
            }
        }
        .foregroundStyle(Color.diveText)
        .frame(minWidth: 1_180, minHeight: 760)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.7), value: model.completionNotice != nil)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: model.currentKind)
        .onAppear { model.requestNotificationPermission() }
    }

    private func completionOverlay(_ notice: CompletionNotice) -> some View {
        VStack(spacing: 15) {
            Image(systemName: notice.kind == .focus ? "sun.max.fill" : "water.waves")
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Color.diveCyan)
                .shadow(color: .diveCyan.opacity(0.7), radius: 16)
            Text(notice.title.uppercased())
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .tracking(4)
            Text(notice.detail)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Color.diveAqua)
            HStack(spacing: 12) {
                Button("Stay Surfaced") { model.staySurfaced() }
                    .buttonStyle(.bordered)
                Button(notice.actionTitle) { model.startNextSession() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.diveCobalt)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 28)
        .frame(width: 360)
        .divePanel()
        .transition(.opacity.combined(with: .offset(y: 14)))
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
                Button { model.showTasks.toggle() } label: {
                    Image(systemName: "checklist")
                }
                .help("Open tasks")
                .accessibilityLabel("Open tasks")

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
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.diveCyan.opacity(0.24),
                                Color.diveCobalt.opacity(0.11),
                                Color.diveAbyss.opacity(0.48)
                            ],
                            center: UnitPoint(x: 0.5, y: 0.03),
                            startRadius: 0,
                            endRadius: side * 0.62
                        )
                    )
                    .padding(53)

                if model.isRunning || model.completionNotice != nil {
                    BubbleField(
                        reduceMotion: reduceMotion,
                        isCompleting: model.completionNotice != nil
                    )
                        .frame(width: side, height: side)
                        .transition(.opacity)
                }

                Circle()
                    .stroke(Color.diveCyan.opacity(0.08), lineWidth: 12)
                    .padding(31)

                Circle()
                    .trim(from: 0, to: max(0.002, min(1, model.presentationProgress)))
                    .stroke(
                        AngularGradient(colors: [.white, accentColor, accentColor.opacity(0.42)], center: .center),
                        style: StrokeStyle(lineWidth: 13, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(31)
                    .opacity(model.timerState == .paused ? 0.58 : 1)
                    .shadow(
                        color: accentColor.opacity(model.timerState == .paused ? 0.3 : minutePulse ? 0.95 : 0.72),
                        radius: model.timerState == .completed ? 22 : minutePulse ? 18 : 12
                    )
                    .animation(reduceMotion ? nil : .linear(duration: 0.28), value: model.presentationProgress)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: minutePulse)

                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text(model.currentKind.title.uppercased())
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .tracking(3.8)
                            .foregroundStyle(Color.diveAqua)
                        Text(statusText)
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .tracking(2.4)
                            .foregroundStyle(model.timerState == .paused ? Color.diveAmber : accentColor.opacity(0.82))
                        Text(formattedTime)
                            .font(.system(size: side * 0.2, weight: .ultraLight, design: .default))
                            .monospacedDigit()
                            .contentTransition(reduceMotion ? .identity : .numericText())
                            .accessibilityIdentifier("timer-display")
                            .accessibilityLabel("Time remaining \(formattedTime)")
                    }

                    HStack(spacing: 7) {
                        Image(systemName: "scope")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(Color.diveCyan.opacity(0.75))
                        TextField("Set current mission", text: $model.mission)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("Current mission")
                    }
                    .frame(width: 220)
                    .padding(.vertical, 5)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Color.diveAqua.opacity(0.22)).frame(height: 0.7)
                    }

                    Button(action: model.toggleTimer) {
                        ZStack {
                            if model.timerState == .paused {
                                Circle()
                                    .stroke(Color.diveCyan.opacity(0.24), lineWidth: 1)
                                    .frame(width: 86, height: 86)
                                    .shadow(color: .diveCyan.opacity(0.35), radius: 10)
                            }
                            Image(systemName: primaryControlSymbol)
                                .font(.system(size: 23, weight: .semibold))
                                .frame(width: 70, height: 70)
                                .background(Color(red: 0.015, green: 0.13, blue: 0.21).opacity(0.82), in: Circle())
                                .overlay(Circle().stroke(Color.diveCyan.opacity(model.timerState == .paused ? 0.82 : 0.55)))
                                .shadow(color: .diveCyan.opacity(model.timerState == .paused ? 0.5 : 0.28), radius: 18)
                        }
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.space, modifiers: [])
                    .accessibilityIdentifier("primary-timer-control")
                    .accessibilityLabel(primaryControlLabel)
                }

            }
            .frame(width: side, height: side)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.65), value: model.isRunning)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var formattedTime: String {
        String(format: "%02d:%02d", model.remainingSeconds / 60, model.remainingSeconds % 60)
    }

    private var minutePulse: Bool {
        model.isRunning && model.remainingSeconds > 0 && model.remainingSeconds < model.timer.durationSeconds
            && model.remainingSeconds.isMultiple(of: 60)
    }

    private var accentColor: Color { model.currentKind.accentColor }

    private var statusText: String {
        switch model.timerState {
        case .idle: "READY"
        case .running: "IN PROGRESS"
        case .paused: "PAUSED"
        case .completed: "SURFACED"
        }
    }

    private var primaryControlSymbol: String {
        switch model.timerState {
        case .running: "pause.fill"
        case .completed: "arrow.right"
        case .idle, .paused: "play.fill"
        }
    }

    private var primaryControlLabel: String {
        switch model.timerState {
        case .running: "Pause \(model.currentKind.title)"
        case .paused: "Resume \(model.currentKind.title)"
        case .completed: "Start next session"
        case .idle: "Start \(model.currentKind.title)"
        }
    }
}

struct DepthGauge: View {
    let depth: Double
    let state: TimerState
    let kind: SessionKind
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { proxy in
            let gaugeHeight = min(520, proxy.size.height)
            let markerY = min(gaugeHeight - 10, max(10, gaugeHeight * depth / 60))

            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(depth.rounded())) m")
                        .font(.system(size: 43, weight: .light, design: .default))
                        .monospacedDigit()
                    Text(statusText)
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundStyle(Color.diveAqua)
                }
                .offset(x: 74, y: 18)

                Rectangle()
                    .fill(Color.diveAqua.opacity(0.24))
                    .frame(width: 0.8, height: gaugeHeight)
                    .offset(x: 50)

                Rectangle()
                    .fill(Color.diveCyan.opacity(0.9))
                    .frame(width: 36, height: 1)
                    .offset(x: 14)
                    .shadow(color: .diveCyan.opacity(0.85), radius: 5)

                VStack(spacing: 0) {
                    ForEach(0..<25) { index in
                        Rectangle()
                            .fill(Color.diveAqua.opacity(index.isMultiple(of: 2) ? 0.8 : 0.45))
                            .frame(width: index.isMultiple(of: 2) ? 20 : 11, height: 0.8)
                        if index < 24 { Spacer() }
                    }
                }
                .frame(width: 22, height: gaugeHeight)
                .offset(x: 14)

                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.diveCyan.opacity(0.72), .diveCobalt.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 12, height: max(4, gaugeHeight - markerY))
                    .offset(x: 44, y: markerY)

                Circle()
                    .fill(Color.diveText)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.diveCyan, lineWidth: 1))
                    .shadow(color: .diveCyan, radius: 13)
                    .offset(x: 41, y: markerY - 9)
            }
            .animation(reduceMotion ? nil : .linear(duration: 0.28), value: markerY)
            .frame(width: proxy.size.width, height: gaugeHeight, alignment: .topLeading)
        }
        .frame(height: 520)
        .accessibilityLabel("Current depth \(Int(depth.rounded())) meters")
        .accessibilityValue(statusText.replacingOccurrences(of: " ", with: ""))
    }

    private var statusText: String {
        switch state {
        case .idle:
            "R E A D Y"
        case .running:
            kind == .focus ? "A S C E N D I N G" : "R E S T I N G"
        case .paused:
            "P A U S E D"
        case .completed:
            "S U R F A C E D"
        }
    }
}
