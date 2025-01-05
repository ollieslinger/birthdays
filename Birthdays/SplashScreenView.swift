import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false // Controls when to transition

    var body: some View {
        if isActive {
            ContentView() // Transition to your main view
        } else {
            VStack {
                Spacer()
                // App Logo or Branding
                Image(systemName: "gift.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.orange)
                Text("🎉 Birthdays by bambina")
                    .font(.custom("Bicyclette-Bold", size: 36))
                    .foregroundColor(.orange)
                    .padding(.top, 16)
                Spacer()
                // Loading Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    .padding(.bottom, 40)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
