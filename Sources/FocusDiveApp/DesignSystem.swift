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
            .background(.black.opacity(0.22))
            .background(.ultraThinMaterial.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.diveAqua.opacity(0.28), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.2), radius: 18, y: 8)
    }
}

extension View {
    func divePanel() -> some View { modifier(DivePanelModifier()) }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .tracking(3.2)
            .foregroundStyle(Color.diveAqua.opacity(0.82))
    }
}
