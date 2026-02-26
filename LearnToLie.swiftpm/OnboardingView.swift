import SwiftUI

struct OnboardingView: View {
    let onBegin: () -> Void
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("LearnToLie!")
                    .font(.system(size: 42, weight: .bold, design: .default))
                    .foregroundColor(AppColors.text)
                    .tracking(4)
                    .cinematicFade(delay: 0.2)
                
                Text("Train your performance. Own your text.")
                    .font(AppFonts.body(16))
                    .foregroundColor(AppColors.subtleText)
                    .cinematicFade(delay: 0.6)
                
                Spacer()
                
                GreenOutlineButton(title: "Begin") {
                    onBegin()
                }
                .cinematicFade(delay: 1.0)
                
                Spacer()
                    .frame(height: 60)
            }
        }
    }
}
