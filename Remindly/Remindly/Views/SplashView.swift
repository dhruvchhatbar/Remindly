import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(AppTheme.brand, AppTheme.brandSecondary)
                    .font(.system(size: 64, weight: .bold))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2)) {
                            scale = 1.0
                        }
                        withAnimation(.easeIn(duration: 0.4)) {
                            opacity = 1.0
                        }
                    }

                Text("Remindly")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .opacity(opacity)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            withAnimation(.easeInOut(duration: 0.3)) { isActive = true }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(false))
}


