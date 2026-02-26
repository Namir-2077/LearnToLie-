import SwiftUI

struct ResultsView: View {
    let result: PerformanceResult
    let context: CharacterContext
    let onTryAgain: () -> Void
    let onEditContext: () -> Void
    let onBack: () -> Void
    
    @State private var displayedScore: Double = 0.0
    @State private var contentVisible = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.subtleText)
                    }
                    
                    Spacer()
                    
                    Text("RESULTS")
                        .font(AppFonts.headerTitle(11))
                        .tracking(2)
                        .foregroundColor(AppColors.headerText)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 20, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 24)
                        
                        // Context summary
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHARACTER PERFORMANCE")
                                .font(AppFonts.caption(10))
                                .tracking(1)
                                .foregroundColor(AppColors.dimText)
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Intent")
                                        .font(AppFonts.caption(10))
                                        .foregroundColor(AppColors.dimText)
                                    Text(context.intent)
                                        .font(AppFonts.body(14))
                                        .foregroundColor(AppColors.accent)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Motivation")
                                        .font(AppFonts.caption(10))
                                        .foregroundColor(AppColors.dimText)
                                    Text(context.motivation)
                                        .font(AppFonts.body(14))
                                        .foregroundColor(AppColors.accent)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.02))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .cinematicFade(delay: 0.1)
                        
                        SectionDivider()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        
                        Spacer()
                            .frame(height: 24)
                        
                        // Score
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", displayedScore))
                                .font(.system(size: 56, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.accent)
                            
                            Text("/ 5")
                                .font(AppFonts.caption(16))
                                .foregroundColor(AppColors.dimText)
                        }
                        .padding(.bottom, 16)
                        
                        // Summary
                        Text(result.summary)
                            .font(AppFonts.body(16))
                            .foregroundColor(AppColors.subtleText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 32)
                            .opacity(contentVisible ? 1 : 0)
                            .offset(y: contentVisible ? 0 : 8)
                        
                        // What Worked
                        VStack(alignment: .leading, spacing: 10) {
                            Text("✓  WHAT WORKED")
                                .font(AppFonts.caption(11))
                                .tracking(1.5)
                                .foregroundColor(AppColors.accent)
                            
                            ForEach(result.strengths, id: \.self) { strength in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .font(AppFonts.body(15))
                                        .foregroundColor(AppColors.dimText)
                                    
                                    Text(strength)
                                        .font(AppFonts.body(15))
                                        .foregroundColor(AppColors.text)
                                        .lineSpacing(4)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 8)
                        
                        SectionDivider()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        
                        // Improve
                        VStack(alignment: .leading, spacing: 10) {
                            Text("→  IMPROVE")
                                .font(AppFonts.caption(11))
                                .tracking(1.5)
                                .foregroundColor(AppColors.accent)
                            
                            ForEach(result.improvements, id: \.self) { improvement in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .font(AppFonts.body(15))
                                        .foregroundColor(AppColors.dimText)
                                    
                                    Text(improvement)
                                        .font(AppFonts.body(15))
                                        .foregroundColor(AppColors.text)
                                        .lineSpacing(4)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 8)
                        
                        SectionDivider()
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        
                        // Practical tip
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PRACTICAL TIP")
                                .font(AppFonts.caption(10))
                                .tracking(1.5)
                                .foregroundColor(AppColors.dimText)
                            
                            Text(result.practicalTip)
                                .font(AppFonts.body(15))
                                .foregroundColor(AppColors.subtleText)
                                .italic()
                                .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 8)
                        
                        // Actions
                        VStack(spacing: 14) {
                            GreenOutlineButton(title: "Try Again") {
                                onTryAgain()
                            }
                            
                            Button {
                                onEditContext()
                            } label: {
                                Text("Edit Context")
                                    .font(AppFonts.caption(13))
                                    .foregroundColor(AppColors.dimText)
                            }
                        }
                        .opacity(contentVisible ? 1 : 0)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            animateScore()
            hapticFeedback()
        }
    }
    
    private func animateScore() {
        // Animate score from 0 to final
        let steps = 20
        let stepDuration = 400 / steps // in milliseconds
        
        Task { @MainActor in
            for i in 0...steps {
                let progress = Double(i) / Double(steps)
                // Ease-out curve
                let eased = 1.0 - pow(1.0 - progress, 3)
                displayedScore = (result.score * eased * 10).rounded() / 10
                
                try? await Task.sleep(for: .milliseconds(stepDuration))
            }
            
            // Show content after score animation wait
            try? await Task.sleep(for: .milliseconds(100))
            withAnimation(.easeOut(duration: 0.3)) {
                contentVisible = true
            }
        }
    }
    
    private func hapticFeedback() {
        #if os(iOS)
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        }
        #endif
    }
}
