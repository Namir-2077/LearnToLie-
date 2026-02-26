import SwiftUI

struct MemorizationRecordingView: View {
    @ObservedObject var store: ScriptStore
    let onFinished: ([WordMatchResult]) -> Void
    let onBack: () -> Void
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var hasStarted = false
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        if speechRecognizer.isRecording {
                            speechRecognizer.stopRecording()
                        }
                        onBack()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.subtleText)
                    }
                    
                    Spacer()
                    
                    Text("MEMORY TEST")
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
                
                // Script Area (Blanks)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if let script = store.currentScript {
                            Text(blankedOutText(script.rawText))
                                .font(AppFonts.beatText(20))
                                .foregroundColor(AppColors.subtleText)
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
                
                Spacer()
                
                // Live Transcript Preview
                if hasStarted {
                    Text(speechRecognizer.transcript.isEmpty ? "Listening..." : speechRecognizer.transcript)
                        .font(AppFonts.body(16))
                        .foregroundColor(AppColors.dimText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                        .cinematicFade()
                }
                
                // Record Controls
                VStack(spacing: 24) {
                    if !speechRecognizer.isAuthorized {
                        Text(speechRecognizer.errorMsg ?? "Please allow Speech Recognition access.")
                            .font(AppFonts.caption(13))
                            .foregroundColor(Color.red.opacity(0.8))
                    } else if !hasStarted {
                        GreenOutlineButton(title: "Begin Recording") {
                            startRecording()
                        }
                    } else {
                        // Stop button
                        Button {
                            finishRecording()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(AppColors.accent.opacity(isPulsing ? 0.3 : 0.8))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(isPulsing ? 1.15 : 1.0)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
                                
                                Circle()
                                    .stroke(AppColors.accent, lineWidth: 2)
                                    .frame(width: 80, height: 80)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onDisappear {
            speechRecognizer.stopRecording()
        }
    }
    
    private func startRecording() {
        speechRecognizer.startRecording()
        withAnimation(.easeIn(duration: 0.3)) {
            hasStarted = true
            isPulsing = true
        }
    }
    
    private func finishRecording() {
        speechRecognizer.stopRecording()
        isPulsing = false
        
        guard let expected = store.currentScript?.rawText else { return }
        
        let results = WordSequenceMatcher.match(expected: expected, actual: speechRecognizer.transcript)
        onFinished(results)
    }
    
    private func blankedOutText(_ text: String) -> String {
        let words = text.split(separator: " ").map(String.init)
        return words.map { word in
            // preserve sentence ending punctuation if possible
            if let last = word.last, last.isPunctuation {
                return "___" + String(last)
            }
            return "___"
        }.joined(separator: " ")
    }
}
