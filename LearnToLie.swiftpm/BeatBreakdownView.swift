import SwiftUI

struct BeatBreakdownView: View {
    @ObservedObject var store: ScriptStore
    let onPractice: () -> Void
    let onBack: () -> Void
    
    @State private var expandedBeatId: UUID? = nil
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.subtleText)
                    }
                    
                    Spacer()
                    
                    Text("BEATS")
                        .font(AppFonts.headerTitle(12))
                        .tracking(2)
                        .foregroundColor(AppColors.headerText)
                    
                    Spacer()
                    
                    if let beats = store.currentScript?.beats {
                        Text("\(beats.count) BEATS")
                            .font(AppFonts.caption(11))
                            .tracking(1)
                            .foregroundColor(AppColors.dimText)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                // Beat List
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 2) {
                        if let beats = store.currentScript?.beats {
                            ForEach(beats) { beat in
                                BeatRow(
                                    beat: beat,
                                    isExpanded: expandedBeatId == beat.id,
                                    onTap: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            expandedBeatId = expandedBeatId == beat.id ? nil : beat.id
                                        }
                                    },
                                    onUpdate: { updated in
                                        store.updateBeat(updated)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                // Bottom Action
                HStack {
                    Spacer()
                    AccentFilledButton(title: "Practice") {
                        onPractice()
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Beat Row

struct BeatRow: View {
    let beat: Beat
    let isExpanded: Bool
    let onTap: () -> Void
    let onUpdate: (Beat) -> Void
    
    @State private var localIntensity: Double
    
    init(beat: Beat, isExpanded: Bool, onTap: @escaping () -> Void, onUpdate: @escaping (Beat) -> Void) {
        self.beat = beat
        self.isExpanded = isExpanded
        self.onTap = onTap
        self.onUpdate = onUpdate
        self._localIntensity = State(initialValue: beat.intensity)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Beat text
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(beat.text)
                        .font(AppFonts.beatText(18))
                        .foregroundColor(isExpanded ? AppColors.text : AppColors.subtleText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Emotion tag
                    if let emotion = beat.emotion {
                        EmotionTagView(emotion: emotion)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Expanded controls
            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    SectionDivider()
                    
                    // Emotion picker
                    Text("EMOTION")
                        .font(AppFonts.caption(10))
                        .tracking(1.5)
                        .foregroundColor(AppColors.dimText)
                    
                    HStack(spacing: 8) {
                        ForEach(Emotion.allCases, id: \.self) { emotion in
                            Button {
                                var updated = beat
                                updated.emotion = beat.emotion == emotion ? nil : emotion
                                onUpdate(updated)
                            } label: {
                                Text(emotion.rawValue)
                                    .font(AppFonts.caption(11))
                                    .foregroundColor(beat.emotion == emotion ? AppColors.text : AppColors.dimText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(beat.emotion == emotion ? AppColors.accent : Color.white.opacity(0.05))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    // Pause toggle
                    HStack {
                        Text("PAUSE")
                            .font(AppFonts.caption(10))
                            .tracking(1.5)
                            .foregroundColor(AppColors.dimText)
                        
                        Spacer()
                        
                        Button {
                            var updated = beat
                            updated.hasPause.toggle()
                            onUpdate(updated)
                        } label: {
                            Text(beat.hasPause ? "ON" : "OFF")
                                .font(AppFonts.caption(11))
                                .foregroundColor(beat.hasPause ? AppColors.text : AppColors.dimText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(beat.hasPause ? AppColors.accent : Color.white.opacity(0.05))
                                .cornerRadius(4)
                        }
                    }
                    
                    // Intensity slider
                    VStack(alignment: .leading, spacing: 6) {
                        Text("INTENSITY — \(Int(localIntensity))")
                            .font(AppFonts.caption(10))
                            .tracking(1.5)
                            .foregroundColor(AppColors.dimText)
                        
                        Slider(value: $localIntensity, in: 1...10, step: 1)
                            .tint(AppColors.accent)
                            .onChange(of: localIntensity) { newValue in
                                var updated = beat
                                updated.intensity = newValue
                                onUpdate(updated)
                            }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isExpanded ? Color.white.opacity(0.04) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isExpanded ? AppColors.accent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}
