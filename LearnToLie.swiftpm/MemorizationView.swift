import SwiftUI

struct MemorizationView: View {
    @ObservedObject var store: ScriptStore
    let onBack: () -> Void
    let onTestMemory: () -> Void
    
    @State private var stage: Int = 1 // 1-3
    @State private var hidePercentage: Double = 0.0
    @State private var speed: MemorizationSpeed = .medium
    
    enum MemorizationSpeed: String, CaseIterable {
        case slow = "Slow"
        case medium = "Medium"
        case fast = "Fast"
        
        var interval: Double {
            switch self {
            case .slow: return 4.0
            case .medium: return 2.0
            case .fast: return 1.0
            }
        }
    }
    
    var progress: Double {
        Double(stage - 1) / 2.0
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
                    
                    Text("STAGE \(stage) OF 3")
                        .font(AppFonts.headerTitle(11))
                        .tracking(1.5)
                        .foregroundColor(AppColors.headerText)
                    
                    Spacer()
                    
                    // Speed selector
                    Menu {
                        ForEach(MemorizationSpeed.allCases, id: \.self) { s in
                            Button(s.rawValue) { speed = s }
                        }
                    } label: {
                        Text(speed.rawValue.uppercased())
                            .font(AppFonts.caption(10))
                            .tracking(1)
                            .foregroundColor(AppColors.accent)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Progress bar
                CinematicProgressBar(progress: progress)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if let beats = store.currentScript?.beats {
                            ForEach(beats) { beat in
                                Text(processedText(beat.text))
                                    .font(AppFonts.beatText(20))
                                    .foregroundColor(AppColors.text)
                                    .lineSpacing(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(stage == 3 ? 0.0 : 1.0)
                                    .overlay(alignment: .leading) {
                                        if stage == 3 {
                                            Text(beatPrompt(beat.text))
                                                .font(AppFonts.caption(14))
                                                .foregroundColor(AppColors.dimText)
                                                .italic()
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                
                // Bottom controls
                VStack(spacing: 16) {
                    SectionDivider()
                        .padding(.horizontal, 24)
                    
                    BreathPacingView()
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 20) {
                        if stage > 1 {
                            GreenOutlineButton(title: "← Previous") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    stage -= 1
                                    updateHidePercentage()
                                }
                                hapticFeedback()
                            }
                        }
                        
                        if stage < 3 {
                            AccentFilledButton(title: "Next Stage →") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    stage += 1
                                    updateHidePercentage()
                                }
                                hapticFeedback()
                            }
                        } else {
                            AccentFilledButton(title: "Test Memory") {
                                hapticFeedback()
                                onTestMemory()
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    // MARK: - Text Processing
    
    private func processedText(_ text: String) -> String {
        let words = text.split(separator: " ").map(String.init)
        switch stage {
        case 1:
            return text
        case 2:
            return words.enumerated().map { index, word in
                shouldHideWord(index: index) ? "___" : word
            }.joined(separator: " ")
        case 3:
            return ""
        default:
            return text
        }
    }
    
    private func beatPrompt(_ text: String) -> String {
        let words = text.split(separator: " ").prefix(3).joined(separator: " ")
        return "[\(words)…]"
    }
    
    private func shouldHideWord(index: Int) -> Bool {
        let hash = (index * 7 + 3) % 10
        return Double(hash) < (hidePercentage * 10.0)
    }
    
    private func updateHidePercentage() {
        switch stage {
        case 2: hidePercentage = 0.3
        default: hidePercentage = 0
        }
    }
    
    private func hapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
