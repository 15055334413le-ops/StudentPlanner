//
//  DesignSystem.swift
//  StudentPlanner
//
//  Design tokens and constants
//

import SwiftUI

// MARK: - Hex Color Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Colors
extension Color {
    // Primary
    static let primaryBlue = Color(hex: "2563EB")
    static let secondaryBlue = Color(hex: "3B82F6")
    static let accentGreen = Color(hex: "059669")

    // Background
    static let background = Color(hex: "F8FAFC")
    static let mutedBackground = Color(hex: "F1F5FD")

    // Text
    static let foreground = Color(hex: "0F172A")
    static let mutedText = Color(hex: "64748B")

    // Border
    static let border = Color(hex: "E4ECFC")

    // Destructive
    static let destructive = Color(hex: "DC2626")
}

// MARK: - Layout
enum Layout {
    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing6: CGFloat = 6
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    static let spacing100: CGFloat = 100
    
    static let cornerRadius8: CGFloat = 8
    static let cornerRadius12: CGFloat = 12
    static let cornerRadius16: CGFloat = 16
    static let cornerRadius20: CGFloat = 20
    
    static let touchTarget: CGFloat = 44
}

// MARK: - Typography
enum Typography {
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionMedium = Font.system(size: 12, weight: .medium)
    static let body = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 16, weight: .medium)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    static let title2 = Font.system(size: 24, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
}

// MARK: - Shadows
enum Shadows {
    static let card = ShadowStyle(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    static let button = ShadowStyle(color: .black.opacity(0.12), radius: 8, x: 0, y: 2)
    static let elevated = ShadowStyle(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func cardShadow() -> some View {
        self.shadow(color: Shadows.card.color, radius: Shadows.card.radius, x: Shadows.card.x, y: Shadows.card.y)
    }
    
    func buttonShadow() -> some View {
        self.shadow(color: Shadows.button.color, radius: Shadows.button.radius, x: Shadows.button.x, y: Shadows.button.y)
    }
}

// MARK: - Gradients
enum Gradients {
    static let primary = LinearGradient(
        colors: [Color(hex: "2563EB"), Color(hex: "3B82F6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Animations
enum Animations {
    static let defaultSpring = Animation.spring(response: 0.35, dampingFraction: 0.8)
    static let quick = Animation.easeInOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.25)
}
