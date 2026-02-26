import SwiftUI

// MARK: - Navigation State

enum AppScreen: Equatable {
    case onboarding
    case scriptInput
    case beatBreakdown
    case practiceMenu
    case memorization
    case memorizationRecording
    case memorizationResults
    case beatSelection
    case characterContext
    case deliveryGuide
    case recording
    case intensityResults
}

// MARK: - Root Content View

struct ContentView: View {
    @StateObject private var store = ScriptStore()
    @State private var currentScreen: AppScreen = .onboarding
    @State private var screenOpacity: Double = 1.0
    
    // Intensity Evaluation state
    @State private var selectedBeatIndex: Int = 0
    @State private var selectedContext: CharacterContext?
    @State private var currentResult: PerformanceResult?
    
    // Memorization state
    @State private var currentMemResults: [WordMatchResult] = []
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            Group {
                switch currentScreen {
                case .onboarding:
                    OnboardingView {
                        navigateTo(.scriptInput)
                    }
                    
                case .scriptInput:
                    ScriptInputView(store: store) {
                        navigateTo(.beatBreakdown)
                    }
                    
                case .beatBreakdown:
                    BeatBreakdownView(
                        store: store,
                        onPractice: { navigateTo(.practiceMenu) },
                        onBack: { navigateTo(.scriptInput) }
                    )
                    
                case .practiceMenu:
                    PracticeMenuView(
                        onMemorization: { navigateTo(.memorization) },
                        onIntensityEval: { navigateTo(.beatSelection) },
                        onBack: { navigateTo(.beatBreakdown) }
                    )
                    
                case .memorization:
                    MemorizationView(
                        store: store,
                        onBack: { navigateTo(.practiceMenu) },
                        onTestMemory: { navigateTo(.memorizationRecording) }
                    )
                    
                case .memorizationRecording:
                    MemorizationRecordingView(
                        store: store,
                        onFinished: { results in
                            currentMemResults = results
                            navigateTo(.memorizationResults)
                        },
                        onBack: { navigateTo(.memorization) }
                    )
                    
                case .memorizationResults:
                    MemorizationResultsView(
                        results: currentMemResults,
                        onTryAgain: { navigateTo(.memorizationRecording) },
                        onFinish: { navigateTo(.practiceMenu) }
                    )
                    
                case .beatSelection:
                    BeatSelectionView(
                        store: store,
                        onSelect: { index in
                            selectedBeatIndex = index
                            navigateTo(.characterContext)
                        },
                        onBack: { navigateTo(.practiceMenu) }
                    )
                    
                case .characterContext:
                    CharacterContextView(
                        store: store,
                        beatIndex: selectedBeatIndex,
                        onContinue: { context in
                            selectedContext = context
                            navigateTo(.deliveryGuide)
                        },
                        onBack: { navigateTo(.beatSelection) }
                    )
                    
                case .deliveryGuide:
                    if let context = selectedContext {
                        DeliveryGuideView(
                            store: store,
                            beatIndex: selectedBeatIndex,
                            context: context,
                            onBeginRecording: { navigateTo(.recording) },
                            onBack: { navigateTo(.characterContext) }
                        )
                    }
                    
                case .recording:
                    if let context = selectedContext {
                        RecordingView(
                            store: store,
                            beatIndex: selectedBeatIndex,
                            context: context,
                            onFinished: { result in
                                currentResult = result
                                navigateTo(.intensityResults)
                            },
                            onBack: { navigateTo(.deliveryGuide) }
                        )
                    }
                    
                case .intensityResults:
                    if let result = currentResult, let context = selectedContext {
                        ResultsView(
                            result: result,
                            context: context,
                            onTryAgain: { navigateTo(.recording) },
                            onEditContext: { navigateTo(.characterContext) },
                            onBack: { navigateTo(.beatSelection) }
                        )
                    }
                }
            }
            .opacity(screenOpacity)
        }
        .preferredColorScheme(.dark)
    }
    
    private func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeOut(duration: 0.15)) {
            screenOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentScreen = screen
            withAnimation(.easeIn(duration: 0.25)) {
                screenOpacity = 1
            }
        }
    }
}

// MARK: - Practice Menu

struct PracticeMenuView: View {
    let onMemorization: () -> Void
    let onIntensityEval: () -> Void
    let onBack: () -> Void
    
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
                    
                    Text("PRACTICE")
                        .font(AppFonts.headerTitle(11))
                        .tracking(2)
                        .foregroundColor(AppColors.headerText)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 20, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 40)
                
                Spacer()
                
                VStack(spacing: 16) {
                    PracticeMenuItem(
                        icon: "text.word.spacing",
                        title: "Memorization",
                        subtitle: "Progressive word removal",
                        action: onMemorization,
                        delay: 0.1
                    )
                    
                    PracticeMenuItem(
                        icon: "dial.low",
                        title: "Intensity Evaluation",
                        subtitle: "Vocal delivery at chosen intensity",
                        action: onIntensityEval,
                        delay: 0.2
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
    }
}

// MARK: - Practice Menu Item

struct PracticeMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    let delay: Double
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(AppColors.accent)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppFonts.body(17))
                        .foregroundColor(AppColors.text)
                    
                    Text(subtitle)
                        .font(AppFonts.caption(12))
                        .foregroundColor(AppColors.dimText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.dimText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .cinematicFade(delay: delay)
    }
}
