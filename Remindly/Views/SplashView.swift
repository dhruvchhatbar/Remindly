import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = -15
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0.0
    @State private var shimmerOffset: CGFloat = -200
    @State private var glowScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            
            // Animated background elements
            Circle()
                .fill(AppTheme.brand.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 50)
                .offset(x: -100, y: -200)
                .scaleEffect(isActive ? 1.2 : 0.8)
                .opacity(isActive ? 0 : 1)
            
            Circle()
                .fill(AppTheme.brandSecondary.opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 40)
                .offset(x: 100, y: 200)
                .scaleEffect(isActive ? 1.2 : 0.8)
                .opacity(isActive ? 0 : 1)

            VStack(spacing: 24) {
                ZStack {
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 40)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    AppTheme.brand.opacity(0.3),
                                    AppTheme.brandSecondary.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .offset(x: shimmerOffset)
                        .opacity(isActive ? 0 : 1)
                    
                    // Pulsing glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.brand.opacity(0.3),
                                    AppTheme.brandSecondary.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(glowScale)
                        .opacity(opacity * 0.6)
                    
                    Image(systemName: "bell.badge.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            AppTheme.tagGradient
                        )
                        .font(.system(size: 64, weight: .bold))
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .rotationEffect(.degrees(rotation))
                        .shadow(
                            color: AppTheme.brand.opacity(0.5),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                }

                Text("Remindly")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        AppTheme.tagGradient
                    )
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                    .shadow(
                        color: AppTheme.brand.opacity(0.4),
                        radius: 15,
                        x: 0,
                        y: 5
                    )
            }
            .onAppear {
                // Icon animation with bounce
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.3)) {
                    scale = 1.0
                    rotation = 0
                }
                withAnimation(.easeIn(duration: 0.5).delay(0.1)) {
                    opacity = 1.0
                }
                
                // Pulsing animation for glow
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                        .delay(0.5)
                ) {
                    glowScale = 1.15
                }
                
                // Text animation
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.3)) {
                    textOffset = 0
                    textOpacity = 1.0
                }
                
                // Shimmer animation
                withAnimation(
                    Animation.linear(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(0.5)
                ) {
                    shimmerOffset = 200
                }
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(false))
}


