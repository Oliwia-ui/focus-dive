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
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color(red: 0.018, green: 0.095, blue: 0.15).opacity(0.78), .black.opacity(0.42)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.ultraThinMaterial.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.diveAqua.opacity(0.3), lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(0.28), radius: 22, y: 10)
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
