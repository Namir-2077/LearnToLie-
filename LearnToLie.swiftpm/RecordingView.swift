import SwiftUI

struct RecordingView: View {
    @ObservedObject var store: ScriptStore
    @StateObject private var audio = AudioManager()
    let beatIndex: Int
    let context: CharacterContext
    let onFinished: (PerformanceResult) -> Void
    let onBack: () -> Void
    
    @State private var hasStarted = false
    @State private var isPulsing = false
    @State private var isFinishing = false
    
    var currentBeat: Beat? {
        guard let beats = store.currentScript?.beats,
              beatIndex < beats.count else { return nil }
        return beats[beatIndex]
    }
    
    var formattedTime: String {
        let minutes = Int(audio.recordingDuration) / 60
        let seconds = Int(audio.recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top
                HStack {
                    Button {
                        audio.stopRecording()
                        onBack()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.subtleText)
                    }
                    
                    Spacer()
                    
                    Text("PERFORMING: \(context.intent.uppercased())")
                        .font(AppFonts.headerTitle(10))
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
                
                // Prompt
                Text(hasStarted ? "" : "Perform when ready.")
                    .font(AppFonts.caption(13))
                    .foregroundColor(AppColors.subtleText)
                    .padding(.bottom, 24)
                    .animation(.easeInOut(duration: 0.2), value: hasStarted)
                
                // Script line
                if let beat = currentBeat {
                    Text(beat.text)
                        .font(AppFonts.beatText(24))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                        .lineSpacing(10)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Waveform
                RecordingWaveformView(samples: audio.waveformSamples)
                    .frame(height: 80)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .opacity(hasStarted ? 1 : 0.3)
                    .animation(.easeInOut(duration: 0.3), value: hasStarted)
                
                // Timer
                if hasStarted {
                    Text(formattedTime)
                        .font(AppFonts.mono(14))
                        .foregroundColor(AppColors.dimText)
                        .padding(.bottom, 16)
                        .transition(.opacity)
                }
                
                // Record button
                Button {
                    if hasStarted {
                        finishRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(AppColors.accent, lineWidth: 2)
                            .frame(width: 64, height: 64)
                        
                        Circle()
                            .fill(hasStarted ? AppColors.accent : Color.clear)
                            .frame(width: 56, height: 56)
                            .scaleEffect(isPulsing ? 1.05 : 0.95)
                            .opacity(isPulsing ? 1.0 : 0.7)
                            .animation(
                                hasStarted
                                    ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                    : .default,
                                value: isPulsing
                            )
                        
                        if !hasStarted {
                            Circle()
                                .fill(AppColors.accent)
                                .frame(width: 20, height: 20)
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.background)
                                .frame(width: 18, height: 18)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            audio.requestPermission()
        }
        .onChange(of: audio.isRecording) { _, isRecording in
            // Only handle auto-stop (max duration reached)
            if !isRecording && hasStarted && !isFinishing {
                finishRecording()
            }
        }
    }
    
    private func startRecording() {
        audio.startRecording()
        withAnimation(.easeInOut(duration: 0.3)) {
            hasStarted = true
        }
        isPulsing = true
    }
    
    private func finishRecording() {
        guard !isFinishing else { return }
        isFinishing = true
        
        let metrics = audio.captureMetrics()
        audio.stopRecording()
        isPulsing = false
        
        let result = PerformanceAnalyzer.analyze(context: context, metrics: metrics)
        
        withAnimation(.easeOut(duration: 0.2)) {
            hasStarted = false
        }
        
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            onFinished(result)
        }
    }
}

// MARK: - Recording Waveform

struct RecordingWaveformView: View {
    let samples: [Float]
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let barWidth = width / CGFloat(samples.count)
            
            Canvas { context, size in
                for (index, sample) in samples.enumerated() {
                    let barHeight = CGFloat(sample) * height * 0.9
                    let x = CGFloat(index) * barWidth
                    let y = (height - barHeight) / 2
                    
                    let rect = CGRect(x: x, y: y, width: max(barWidth - 1, 1), height: max(barHeight, 1))
                    
                    let opacity = 0.3 + Double(sample) * 0.7
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 1),
                        with: .color(AppColors.accent.opacity(opacity))
                    )
                }
            }
        }
    }
}
