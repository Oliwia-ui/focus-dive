import SwiftUI

extension Color {
    static let diveAbyss = Color(red: 0.008, green: 0.035, blue: 0.065)
    static let diveNavy = Color(red: 0.018, green: 0.105, blue: 0.17)
    static let diveCobalt = Color(red: 0.025, green: 0.28, blue: 0.45)
    static let diveCyan = Color(red: 0.35, green: 0.92, blue: 0.98)
    static let diveAqua = Color(red: 0.48, green: 0.78, blue: 0.84)
    static let diveText = Color(red: 0.89, green: 0.97, blue: 0.99)
    static let diveMuted = Color(red: 0.48, green: 0.68, blue: 0.78)
    static let diveAmber = Color(red: 0.96, green: 0.73, blue: 0.32)
}

struct DivePanelModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

        if #available(macOS 26.0, *) {
            content
                .glassEffect(
                    .regular.tint(Color.diveNavy.opacity(0.18)),
                    in: shape
                )
                .overlay {
                    shape.stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.24), Color.diveAqua.opacity(0.18), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                }
                .shadow(color: .black.opacity(0.26), radius: 24, y: 12)
        } else {
            content
                .background(.ultraThinMaterial)
                .background(Color.diveNavy.opacity(0.26))
                .clipShape(shape)
                .overlay {
                    shape.stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.18), Color.diveAqua.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                }
                .shadow(color: .black.opacity(0.26), radius: 24, y: 12)
        }
    }
}

extension View {
    func divePanel() -> some View { modifier(DivePanelModifier()) }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .medium, design: .default))
            .tracking(3.6)
            .foregroundStyle(Color.diveAqua.opacity(0.82))
    }
}
