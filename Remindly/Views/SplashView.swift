import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0.0
    @State private var tilt: Double = -12
    @State private var glow: Double = 0.0
    @State private var shimmerPhase: CGFloat = -1.0
    @State private var showSparkles: Bool = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    // App icon tile (pseudo app icon)
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.brand, AppTheme.brandSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
                        .shadow(color: AppTheme.brand.opacity(0.35 * glow), radius: 24, x: 0, y: 0)
                        .frame(width: 150, height: 100)
                        .overlay {
                            // Bell symbol inside
                            Image("launchIcon")
                                .frame(width: 105, height: 75, alignment: .center)
                                .symbolRenderingMode(.palette)
                                .scaleEffect(1.0 + glow * 0.05)
                                .shadow(color: Color.white.opacity(0.6 * glow), radius: 10, x: 0, y: 0)
                        }
                        .mask {
                            // Soft shimmer mask
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.white)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .clear, location: 0.0),
                                            .init(color: .white.opacity(0.35), location: 0.5),
                                            .init(color: .clear, location: 1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .scaleEffect(1.2)
                                    .offset(x: shimmerPhase * 140, y: shimmerPhase * -140)
                                    .blendMode(.plusLighter)
                                )
                        }
                        .rotation3DEffect(.degrees(tilt), axis: (x: 0.0, y: 1.0, z: 0.0))
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            // Fade + scale in
                            withAnimation(.easeOut(duration: 0.5)) { opacity = 1.0 }
                            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { scale = 1.0 }
                            // 3D tilt to flat
                            withAnimation(.spring(response: 0.9, dampingFraction: 0.8).delay(0.1)) { tilt = 0 }
                            // Glow pulse
                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.2)) { glow = 1.0 }
                            // Shimmer sweep
                            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: false).delay(0.4)) { shimmerPhase = 1.0 }
                            // Sparkles
                            withAnimation(.easeInOut(duration: 0.4).delay(0.4)) { showSparkles = true }
                        }

                    if showSparkles {
                        // Lightweight sparkle dots
                        ForEach(0..<10, id: \.self) { i in
                            Circle()
                                .fill(Color.white.opacity(0.85))
                                .frame(width: 3, height: 3)
                                .offset(randomOffset(index: i))
                                .opacity(0.0)
                                .onAppear {
                                    let delay = Double(i) * 0.04
                                    withAnimation(.easeOut(duration: 0.5).delay(0.2 + delay)) {}
                                    withAnimation(.easeOut(duration: 0.7).delay(0.25 + delay)) {}
                                }
                        }
                    }
                }

                Text("Remindly")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white.opacity(0.95))
                    .opacity(opacity)
            }
        }
        .task {
            // Keep splash short and delightful
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            withAnimation(.easeInOut(duration: 0.35)) { isActive = true }
        }
    }
}

private extension SplashView {
    func randomOffset(index: Int) -> CGSize {
        // Deterministic pseudo-random based on index for stable layout each run
        var seed = UInt64(index * 1103515245 &+ 12345)
        func next() -> Double {
            seed = 2862933555777941757 &* seed &+ 3037000493
            let upper = Double((seed >> 33) & 0xFFFFFFFF)
            return upper.truncatingRemainder(dividingBy: 1000.0) / 1000.0
        }
        let radius: Double = 90
        let angle = next() * 2 * .pi
        let r = sqrt(next()) * radius
        let x = cos(angle) * r
        let y = sin(angle) * r
        return CGSize(width: x, height: y)
    }
}

#Preview {
    SplashView(isActive: .constant(false))
}


