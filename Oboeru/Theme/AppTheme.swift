import SwiftUI

struct AppTheme {

    struct Colors {
        static let background     = Color(hex: "EDE8DC")
        static let cardSurface    = Color(hex: "F7F3EA")
        static let deepBackground = Color(hex: "D4C9B0")

        static let primaryText    = Color(hex: "2A1F14")
        static let secondaryText  = Color(hex: "7A6552")
        static let tertiaryText   = Color(hex: "A89880")

        static let vermillion     = Color(hex: "B83A2E")
        static let gold           = Color(hex: "C8943A")
        static let sageGreen      = Color(hex: "7A8C6E")
        static let dustyBlue      = Color(hex: "6B7F8C")
        static let warmGold       = Color(hex: "D4A843")

        static let border         = Color(hex: "D4C4A8")
        static let cardShadow     = Color(hex: "2A1F14").opacity(0.06)
    }

    struct Typography {
        static let kanjiDisplay  = Font.system(size: 88,
                                       weight: .bold,
                                       design: .serif)
        static let kanaReading   = Font.system(size: 22,
                                       weight: .medium,
                                       design: .serif)
        static let meaning       = Font.system(size: 18,
                                       weight: .regular)
        static let example       = Font.system(size: 15,
                                       weight: .regular)
        static let caption       = Font.system(size: 13,
                                       weight: .regular)
        static let cardHint      = Font.system(size: 14,
                                       weight: .light)
        static let sectionHeader = Font.system(size: 11,
                                       weight: .semibold)
        static let streakNumber  = Font.system(size: 36,
                                       weight: .bold,
                                       design: .serif)
    }

    struct Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    struct Radius {
        static let card:   CGFloat = 20
        static let button: CGFloat = 12
        static let badge:  CGFloat = 8
        static let seal:   CGFloat = 4
    }

    struct Shadows {
        static let cardColor  = Color(hex: "2A1F14").opacity(0.08)
        static let cardRadius: CGFloat = 16
        static let cardX:      CGFloat = 0
        static let cardY:      CGFloat = 4
    }

    struct Animation {
        static let spring = SwiftUI.Animation.spring(
            response: 0.4,
            dampingFraction: 0.7
        )
        static let quick = SwiftUI.Animation.easeInOut(
            duration: 0.2
        )
        static let cardFlip = SwiftUI.Animation.spring(
            response: 0.5,
            dampingFraction: 0.8
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                           (int >> 8) * 17,
                           (int >> 4 & 0xF) * 17,
                           (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                           int >> 16,
                           int >> 8 & 0xFF,
                           int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                           int >> 16 & 0xFF,
                           int >> 8 & 0xFF,
                           int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {

    func oboeruCard() -> some View {
        self
            .background(
                ZStack {
                    AppTheme.Colors.cardSurface
                        .opacity(0.92)
                    Image("CardBG")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.28)
                }
            )
            .clipShape(RoundedRectangle(
                cornerRadius: AppTheme.Radius.card
            ))
            .shadow(
                color: AppTheme.Shadows.cardColor,
                radius: AppTheme.Shadows.cardRadius,
                x: AppTheme.Shadows.cardX,
                y: AppTheme.Shadows.cardY
            )
    }

    func oboeruBackground() -> some View {
        self
            .background(
                AppTheme.Colors.background
                    .ignoresSafeArea()
            )
    }

    func primaryText() -> some View {
        self
            .foregroundStyle(AppTheme.Colors.primaryText)
    }

    func secondaryText() -> some View {
        self
            .foregroundStyle(AppTheme.Colors.secondaryText)
    }

    func tertiaryText() -> some View {
        self
            .foregroundStyle(AppTheme.Colors.tertiaryText)
    }
}

struct SealStamp: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.vermillion)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xs)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.seal)
                    .stroke(AppTheme.Colors.vermillion, lineWidth: 1.5)
            )
    }
}
