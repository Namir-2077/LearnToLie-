import SwiftUI

struct DeliveryGuideView: View {
    @ObservedObject var store: ScriptStore
    let beatIndex: Int
    let context: CharacterContext
    let onBeginRecording: () -> Void
    let onBack: () -> Void
    
    var currentBeat: Beat? {
        guard let beats = store.currentScript?.beats,
              beatIndex < beats.count else { return nil }
        return beats[beatIndex]
    }
    
    var delivery: DeliveryGuidance {
        context.deliveryGuidance
    }
    
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
                    
                    Text("DELIVERY GUIDE")
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
                
                // Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Script line
                        if let beat = currentBeat {
                            VStack(spacing: 12) {
                                Text("YOUR LINE")
                                    .font(AppFonts.caption(10))
                                    .tracking(1)
                                    .foregroundColor(AppColors.dimText)
                                
                                Text(beat.text)
                                    .font(AppFonts.beatText(22))
                                    .foregroundColor(AppColors.text)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(8)
                            }
                            .padding(.top, 24)
                            .padding(.bottom, 12)
                            .cinematicFade(delay: 0.1)
                        }
                        
                        SectionDivider()
                        
                        // Context summary
                        VStack(spacing: 12) {
                            Text("CHARACTER SITUATION")
                                .font(AppFonts.caption(10))
                                .tracking(1)
                                .foregroundColor(AppColors.dimText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ContextRowView(label: "Coming from", value: context.originContext)
                                SectionDivider()
                                ContextRowView(label: "Going toward", value: context.destinationContext)
                                SectionDivider()
                                ContextRowView(label: "Intent", value: context.intent)
                                SectionDivider()
                                ContextRowView(label: "Motivation", value: context.motivation)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.02))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .cinematicFade(delay: 0.15)
                        
                        SectionDivider()
                        
                        // Delivery tips
                        VStack(spacing: 12) {
                            Text("DELIVERY TIPS")
                                .font(AppFonts.caption(10))
                                .tracking(1)
                                .foregroundColor(AppColors.dimText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(delivery.tips.enumerated()), id: \.offset) { index, tip in
                                    HStack(alignment: .top, spacing: 10) {
                                        Text("\(index + 1)")
                                            .font(AppFonts.caption(11))
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppColors.accent)
                                            .frame(minWidth: 20)
                                        
                                        Text(tip)
                                            .font(AppFonts.body(14))
                                            .foregroundColor(AppColors.subtleText)
                                            .lineSpacing(3)
                                    }
                                    .cinematicFade(delay: Double(index + 1) * 0.1)
                                }
                            }
                        }
                        
                        SectionDivider()
                        
                        // Expected characteristics
                        VStack(spacing: 12) {
                            Text("VOCAL CHARACTERISTICS")
                                .font(AppFonts.caption(10))
                                .tracking(1)
                                .foregroundColor(AppColors.dimText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                CharacteristicRow(label: "Pitch", value: delivery.expectedCharacteristics.pitchRange)
                                SectionDivider()
                                CharacteristicRow(label: "Pace", value: delivery.expectedCharacteristics.pace)
                                SectionDivider()
                                CharacteristicRow(label: "Emphasis", value: delivery.expectedCharacteristics.emphasis)
                                SectionDivider()
                                CharacteristicRow(label: "Breath & Pauses", value: delivery.expectedCharacteristics.breathPauses)
                                SectionDivider()
                                CharacteristicRow(label: "Energy", value: delivery.expectedCharacteristics.energy)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.02))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .cinematicFade(delay: 0.35)
                        
                        // Record button
                        VStack(spacing: 12) {
                            Button {
                                onBeginRecording()
                            } label: {
                                Text("BEGIN RECORDING")
                                    .font(AppFonts.caption(14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.text)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppColors.accent)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                        .cinematicFade(delay: 0.5)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Context Row View

struct ContextRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(AppFonts.caption(11))
                .foregroundColor(AppColors.dimText)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(AppFonts.body(14))
                .foregroundColor(AppColors.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Characteristic Row View

struct CharacteristicRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(AppFonts.caption(11))
                .foregroundColor(AppColors.dimText)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(AppFonts.body(14))
                .foregroundColor(AppColors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let context = CharacterContext(
        originContext: "Confrontation",
        destinationContext: "Submission",
        intent: "Threaten",
        motivation: "Power/Control"
    )
    
    DeliveryGuideView(
        store: ScriptStore(),
        beatIndex: 0,
        context: context,
        onBeginRecording: { },
        onBack: { }
    )
}
