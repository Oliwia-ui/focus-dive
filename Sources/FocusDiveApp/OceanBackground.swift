import SwiftUI

struct OceanBackground: View {
    let progress: Double
    let reduceMotion: Bool

    var body: some View {
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

                var surface = Path()
                surface.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.11))
                context.fill(surface, with: .linearGradient(
                    Gradient(colors: [.diveCyan.opacity(0.26 + bright * 0.22), .clear]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: size.height * 0.12)
                ))

                for index in 0..<8 {
                    let x = size.width * (0.25 + Double(index) * 0.075)
                    let sway = sin(phase * 0.18 + Double(index)) * 28
                    var ray = Path()
                    ray.move(to: CGPoint(x: x + sway, y: 0))
                    ray.addLine(to: CGPoint(x: x - 85 + sway, y: size.height * 0.62))
                    ray.addLine(to: CGPoint(x: x + 105 + sway, y: size.height * 0.62))
                    ray.closeSubpath()
                    context.fill(ray, with: .linearGradient(
                        Gradient(colors: [.diveCyan.opacity(0.045 + bright * 0.04), .clear]),
                        startPoint: CGPoint(x: x, y: 0),
                        endPoint: CGPoint(x: x, y: size.height * 0.64)
                    ))
                }

                for index in 0..<72 {
                    let seed = Double((index * 47) % 101) / 101
                    let x = seed * size.width
                    let baseY = Double((index * 83) % 97) / 97 * size.height
                    let y = reduceMotion ? baseY : (baseY - phase * (2 + Double(index % 4))).truncatingRemainder(dividingBy: size.height)
                    let point = CGRect(x: x, y: y < 0 ? y + size.height : y, width: 1.4, height: 1.4)
                    context.fill(Path(ellipseIn: point), with: .color(.diveCyan.opacity(0.18)))
                }

                var terrain = Path()
                terrain.move(to: CGPoint(x: 0, y: size.height))
                terrain.addLine(to: CGPoint(x: 0, y: size.height * 0.78))
                for index in 0...24 {
                    let x = size.width * Double(index) / 24
                    let ridge = sin(Double(index) * 1.7) * 32 + sin(Double(index) * 0.53) * 48
                    terrain.addLine(to: CGPoint(x: x, y: size.height * 0.83 + ridge))
                }
                terrain.addLine(to: CGPoint(x: size.width, y: size.height))
                terrain.closeSubpath()
                context.fill(terrain, with: .linearGradient(
                    Gradient(colors: [Color(red: 0.025, green: 0.13, blue: 0.19), .black.opacity(0.96)]),
                    startPoint: CGPoint(x: 0, y: size.height * 0.75),
                    endPoint: CGPoint(x: 0, y: size.height)
                ))
            }
        }
        .ignoresSafeArea()
    }
}

struct BubbleField: View {
    let reduceMotion: Bool
    private let bubbles: [(Double, Double, Double)] = [
        (0.08, 0.64, 8), (0.14, 0.31, 5), (0.2, 0.76, 11), (0.26, 0.18, 6),
        (0.78, 0.2, 9), (0.83, 0.64, 13), (0.89, 0.38, 6), (0.94, 0.72, 8),
        (0.71, 0.81, 4), (0.12, 0.88, 4), (0.86, 0.49, 4)
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
                        .overlay(Circle().stroke(Color.diveCyan.opacity(0.55), lineWidth: 0.8))
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
