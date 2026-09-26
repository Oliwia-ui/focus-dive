import FocusDiveCore
import SwiftUI

struct FocusDiveDashboard: View {
    @ObservedObject var model: FocusDiveViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            OceanBackground(progress: model.progress, reduceMotion: reduceMotion, isActive: model.isRunning)

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
                    DepthGauge(depth: model.depth, isRunning: model.isRunning)
                        .frame(width: 280)

                    VStack(spacing: 8) {
                        TimerConsole(model: model, reduceMotion: reduceMotion)
                            .frame(maxWidth: 580, maxHeight: 580)
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
            Button("Continue") { model.completionNotice = nil }
                .buttonStyle(.borderedProminent)
                .tint(Color.diveCobalt)
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 28)
        .frame(width: 360)
        .divePanel()
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(notice.title). \(notice.detail)")
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

                if model.isRunning {
                    BubbleField(reduceMotion: reduceMotion)
                        .frame(width: side, height: side)
                        .transition(.opacity)
                }

                Circle()
                    .stroke(Color.diveCyan.opacity(0.08), lineWidth: 12)
                    .padding(31)

                Circle()
                    .trim(from: 0, to: min(1, 0.19 + model.progress * 0.81))
                    .stroke(
                        AngularGradient(colors: [.white, .diveCyan, .diveCyan.opacity(0.42)], center: .center),
                        style: StrokeStyle(lineWidth: 13, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(31)
                    .shadow(color: .diveCyan.opacity(0.72), radius: 12)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: model.progress)

                Circle()
                    .trim(from: 0.54, to: 0.72)
                    .stroke(
                        LinearGradient(colors: [.diveCyan.opacity(0.95), .diveCobalt.opacity(0.25)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(31)
                    .shadow(color: .diveCyan.opacity(0.45), radius: 9)

                Circle()
                    .stroke(Color.diveCyan.opacity(0.66), lineWidth: 0.9)
                    .padding(18)
                Circle()
                    .stroke(Color.diveAqua.opacity(0.28), lineWidth: 0.8)
                    .padding(44)
                Circle()
                    .stroke(Color.diveCobalt.opacity(0.34), lineWidth: 2)
                    .padding(53)

                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text(model.currentKind.title.uppercased())
                            .font(.system(size: 10, weight: .medium, design: .default))
                            .tracking(3.8)
                            .foregroundStyle(Color.diveAqua)
                        Text(formattedTime)
                            .font(.system(size: side * 0.2, weight: .ultraLight, design: .default))
                            .monospacedDigit()
                            .contentTransition(.numericText())
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
                        Image(systemName: model.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 23, weight: .semibold))
                            .frame(width: 70, height: 70)
                            .background(Color(red: 0.015, green: 0.13, blue: 0.21).opacity(0.82), in: Circle())
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
        GeometryReader { proxy in
            let gaugeHeight = min(520, proxy.size.height)
            let markerY = min(gaugeHeight - 10, max(10, gaugeHeight * depth / 60))

            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(depth.rounded())) m")
                        .font(.system(size: 43, weight: .light, design: .default))
                        .monospacedDigit()
                    Text(isRunning ? "A S C E N D I N G" : "D E S C E N D I N G")
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
            .frame(width: proxy.size.width, height: gaugeHeight, alignment: .topLeading)
        }
        .frame(height: 520)
        .accessibilityLabel("Current depth \(Int(depth.rounded())) meters")
    }
}
