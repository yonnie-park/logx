import SwiftUI

enum FitButtonStyle {
    case primary
    case outline
}

struct FitButton: View {
    let title: String
    let style: FitButtonStyle
    var identifier: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                Capsule()
                    .fill(style == .primary ? Color.fitRed : Color.fitBgBtn)

                // Left icon
                HStack {
                    ZStack {
                        Circle()
                            .fill(style == .primary ? Color.white.opacity(0.2) : Color.fitBg)
                            .frame(width: 44, height: 44)

                        Image(systemName: style == .primary ? "arrow.down" : "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(style == .primary ? .white : .fitText)
                    }
                    .padding(.leading, 6)

                    Spacer()
                }

                // Centered title
                Text(LocalizedStringKey(title))
                    .font(.a2zBold(size: 14))
                    .foregroundColor(style == .primary ? .white : .fitText)
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .accessibilityIdentifier(identifier ?? "action-\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
        .accessibilityLabel(title)
    }
}
