import SwiftUI

struct IntensitySelectionView: View {
    @ObservedObject var store: ScriptStore
    let beatIndex: Int
    let onBeginRecording: (Int) -> Void
    let onBack: () -> Void
    @State private var intensity: Double = 5.0
    
    var currentBeat: Beat? {
        guard let beats = store.currentScript?.beats,
              beatIndex < beats.count else { return nil }
        return beats[beatIndex]
    }
    
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
                    
                    Text("INTENSITY EVALUATION")
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
                
                Spacer()
                
                // Script line
                if let beat = currentBeat {
                    Text(beat.text)
                        .font(AppFonts.beatText(24))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding(.horizontal, 32)
                        .cinematicFade(delay: 0.2)
                }
                
                Spacer()
                
                // Intensity value
                Text("\(Int(intensity))")
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.accent)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: intensity)
                    .cinematicFade(delay: 0.4)
                
                // Slider
                VStack(spacing: 12) {
                    HStack {
                        Text("RESTRAINED")
                            .font(AppFonts.caption(9))
                            .tracking(1)
                            .foregroundColor(AppColors.dimText)
                        
                        Spacer()
                        
                        Text("EXPLOSIVE")
                            .font(AppFonts.caption(9))
                            .tracking(1)
                            .foregroundColor(AppColors.dimText)
                    }
                    
                    Slider(value: $intensity, in: 1...10, step: 1)
                        .tint(AppColors.accent)
                        .onChange(of: intensity) { _, _ in
                            hapticFeedback()
                        }
                }
                .padding(.horizontal, 32)
                .cinematicFade(delay: 0.5)
                
                // Subtext
                Text("Deliver the line at this intensity.")
                    .font(AppFonts.caption(13))
                    .foregroundColor(AppColors.subtleText)
                    .padding(.top, 16)
                    .cinematicFade(delay: 0.6)
                
                Spacer()
                
                // Begin Recording button
                GreenOutlineButton(title: "Begin Recording") {
                    onBeginRecording(Int(intensity))
                }
                .cinematicFade(delay: 0.7)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func hapticFeedback() {
        #if os(iOS)
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
        #endif
    }
}
