import SwiftUI

extension Color {
    static let fitRed     = Color(hex: "#E32A28")

    // 라이트/다크 자동 전환
    static let fitBg      = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#202020")
            : UIColor(hex: "#DBD7D4")
    })

    static let fitBgBtn   = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#303030")
            : UIColor(hex: "#E4E0DD")
    })

    static let fitText    = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#ffffff")
            : UIColor(hex: "#000000")
    })

    static let fitMuted   = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(hex: "#b4b4b4")
            : UIColor(hex: "#666666")
    })

    static let fitWhite   = Color(hex: "#ffffff")
    static let fitBlack   = Color(hex: "#000000")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
