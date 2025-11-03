import SwiftUI

enum AppTheme {
    static let brand = Color("Brand")
    static let brandSecondary = Color("BrandSecondary")
    static let backgroundGradient = LinearGradient(
        colors: [Color("BgTop"), Color("BgBottom")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.95),
            Color("Brand").opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let tagGradient = LinearGradient(
        colors: [
            Color("Brand"),
            Color("BrandSecondary")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let cardGradientDark = LinearGradient(
        colors: [
            Color("Brand").opacity(0.15),
            Color("BrandSecondary").opacity(0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    @ViewBuilder
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("Brand").opacity(0.08),
                                        Color("BrandSecondary").opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color("Brand").opacity(0.3),
                                Color("BrandSecondary").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color("Brand").opacity(0.15), radius: 10, x: 0, y: 4)
    }
}


