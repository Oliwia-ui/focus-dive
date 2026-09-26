import AppKit
import SwiftUI

struct OceanBackground: View {
    let progress: Double
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            if let image = Self.cavernImage {
                GeometryReader { proxy in
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .saturation(0.72)
                        .contrast(1.08)
                        .brightness(-0.18 + progress * 0.07)
                }
            }

            TimelineView(.animation(minimumInterval: reduceMotion ? 10 : 1.0 / 24.0)) { timeline in
            Canvas { context, size in
                let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let bright = max(0.12, progress)

                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color(red: 0.025 + bright * 0.04, green: 0.18 + bright * 0.13, blue: 0.29 + bright * 0.18),
                            .diveNavy,
                            .diveAbyss
                        ]),
                        startPoint: CGPoint(x: size.width * 0.5, y: 0),
                        endPoint: CGPoint(x: size.width * 0.5, y: size.height)
                    )
                )

                let surfaceGlow = Path(ellipseIn: CGRect(
                    x: size.width * 0.23,
                    y: -size.height * 0.35,
                    width: size.width * 0.54,
                    height: size.height * 0.92
                ))
                context.fill(
                    surfaceGlow,
                    with: .radialGradient(
                        Gradient(colors: [
                            Color.diveCyan.opacity(0.2 + bright * 0.14),
                            Color.diveCobalt.opacity(0.08),
                            .clear
                        ]),
                        center: CGPoint(x: size.width * 0.5, y: size.height * 0.05),
                        startRadius: 0,
                        endRadius: size.width * 0.34
                    )
                )

                var surface = Path()
                surface.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.12))
                context.fill(
                    surface,
                    with: .linearGradient(
                        Gradient(colors: [.diveCyan.opacity(0.28 + bright * 0.22), .clear]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: 0, y: size.height * 0.12)
                    )
                )

                for line in 0..<5 {
                    var ripple = Path()
                    let baseY = Double(line) * 9 + 5
                    ripple.move(to: CGPoint(x: 0, y: baseY))
                    for step in 1...32 {
                        let x = size.width * Double(step) / 32
                        let y = baseY + sin(Double(step) * 0.82 + phase * 0.16 + Double(line)) * (2.5 + Double(line) * 0.45)
                        ripple.addLine(to: CGPoint(x: x, y: y))
                    }
                    context.stroke(
                        ripple,
                        with: .color(.diveCyan.opacity(0.12 - Double(line) * 0.012)),
                        lineWidth: 1
                    )
                }

                for index in 0..<9 {
                    let x = size.width * (0.18 + Double(index) * 0.08)
                    let sway = sin(phase * 0.18 + Double(index)) * 28
                    var ray = Path()
                    ray.move(to: CGPoint(x: x + sway, y: 0))
                    ray.addLine(to: CGPoint(x: x - 80 + sway, y: size.height * 0.7))
                    ray.addLine(to: CGPoint(x: x + 115 + sway, y: size.height * 0.7))
                    ray.closeSubpath()
                    context.fill(
                        ray,
                        with: .linearGradient(
                            Gradient(colors: [.diveCyan.opacity(0.04 + bright * 0.035), .clear]),
                            startPoint: CGPoint(x: x, y: 0),
                            endPoint: CGPoint(x: x, y: size.height * 0.7)
                        )
                    )
                }

                for index in 0..<84 {
                    let seed = Double((index * 47) % 101) / 101
                    let x = seed * size.width
                    let baseY = Double((index * 83) % 97) / 97 * size.height
                    let y = reduceMotion ? baseY : (baseY - phase * (2 + Double(index % 4))).truncatingRemainder(dividingBy: size.height)
                    let point = CGRect(x: x, y: y < 0 ? y + size.height : y, width: 1.4, height: 1.4)
                    context.fill(Path(ellipseIn: point), with: .color(.diveCyan.opacity(0.18)))
                }

                var leftSpire = Path()
                leftSpire.move(to: CGPoint(x: size.width * 0.07, y: size.height))
                leftSpire.addCurve(
                    to: CGPoint(x: size.width * 0.2, y: size.height * 0.29),
                    control1: CGPoint(x: size.width * 0.1, y: size.height * 0.72),
                    control2: CGPoint(x: size.width * 0.15, y: size.height * 0.45)
                )
                leftSpire.addCurve(
                    to: CGPoint(x: size.width * 0.3, y: size.height),
                    control1: CGPoint(x: size.width * 0.23, y: size.height * 0.54),
                    control2: CGPoint(x: size.width * 0.28, y: size.height * 0.78)
                )
                leftSpire.closeSubpath()
                context.fill(
                    leftSpire,
                    with: .linearGradient(
                        Gradient(colors: [Color.diveCobalt.opacity(0.18), .black.opacity(0.84)]),
                        startPoint: CGPoint(x: 0, y: size.height * 0.3),
                        endPoint: CGPoint(x: 0, y: size.height)
                    )
                )

                for layer in 0..<3 {
                    var terrain = Path()
                    let layerOffset = Double(layer) * size.height * 0.035
                    terrain.move(to: CGPoint(x: 0, y: size.height))
                    terrain.addLine(to: CGPoint(x: 0, y: size.height * 0.73 + layerOffset))
                    for index in 0...36 {
                        let x = size.width * Double(index) / 36
                        let ridge = sin(Double(index) * 1.51 + Double(layer)) * (20 + Double(layer) * 8)
                            + sin(Double(index) * 0.47 + 1.8) * (44 - Double(layer) * 7)
                            + abs(sin(Double(index) * 2.7)) * 22
                        terrain.addLine(to: CGPoint(x: x, y: size.height * 0.79 + layerOffset + ridge))
                    }
                    terrain.addLine(to: CGPoint(x: size.width, y: size.height))
                    terrain.closeSubpath()
                    context.fill(
                        terrain,
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(
                                    red: 0.02,
                                    green: 0.15 - Double(layer) * 0.025,
                                    blue: 0.22 - Double(layer) * 0.025
                                ).opacity(0.9),
                                .black.opacity(0.98)
                            ]),
                            startPoint: CGPoint(x: 0, y: size.height * 0.72),
                            endPoint: CGPoint(x: 0, y: size.height)
                        )
                    )
                }
            }
            }
            .opacity(Self.cavernImage == nil ? 1 : 0.34)

            LinearGradient(
                colors: [
                    Color.diveAbyss.opacity(0.38),
                    Color.diveNavy.opacity(0.12 + (1 - progress) * 0.18),
                    Color.diveAbyss.opacity(0.46)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.46),
                    .clear,
                    Color.black.opacity(0.34)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .ignoresSafeArea()
    }

    private static let cavernImage: NSImage? = {
        guard let url = Bundle.main.url(forResource: "DiveCavern", withExtension: "jpg") else {
            return nil
        }
        return NSImage(contentsOf: url)
    }()
}

struct BubbleField: View {
    let reduceMotion: Bool
    private let bubbles: [(Double, Double, Double)] = [
        (0.08, 0.64, 8), (0.14, 0.31, 5), (0.2, 0.76, 11), (0.26, 0.18, 6),
        (0.78, 0.2, 9), (0.83, 0.64, 13), (0.89, 0.38, 6), (0.94, 0.72, 8),
        (0.71, 0.81, 4), (0.12, 0.88, 4), (0.86, 0.49, 4),
        (0.04, 0.48, 5), (0.91, 0.84, 11), (0.76, 0.34, 5), (0.22, 0.9, 6)
    ]

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 10 : 1.0 / 30.0)) { timeline in
            GeometryReader { proxy in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                ForEach(Array(bubbles.enumerated()), id: \.offset) { index, bubble in
                    let drift = sin(time * 0.35 + Double(index)) * 12
                    let rise = reduceMotion ? 0 : (time * (5 + Double(index % 3))).truncatingRemainder(dividingBy: proxy.size.height * 0.35)
                    Circle()
                        .fill(.white.opacity(0.035))
                        .overlay(Circle().stroke(Color.diveCyan.opacity(0.58), lineWidth: 0.8))
                        .overlay(alignment: .topLeading) {
                            Circle().fill(.white.opacity(0.8)).frame(width: 2.2, height: 2.2).padding(2)
                        }
                        .frame(width: bubble.2, height: bubble.2)
                        .position(
                            x: proxy.size.width * bubble.0 + drift,
                            y: proxy.size.height * bubble.1 - rise
                        )
                        .opacity(0.45 + 0.3 * sin(time * 0.5 + Double(index)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
