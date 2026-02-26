import SwiftUI

struct CharacterContextView: View {
    @ObservedObject var store: ScriptStore
    let beatIndex: Int
    let onContinue: (CharacterContext) -> Void
    let onBack: () -> Void
    
    @State private var originContext: String = ""
    @State private var destinationContext: String = ""
    @State private var intent: String = ""
    @State private var motivation: String = ""
    
    @State private var showOriginDropdown = false
    @State private var showDestinationDropdown = false
    @State private var showIntentDropdown = false
    @State private var showMotivationDropdown = false
    
    @State private var selectedPreset: ContextPreset? = nil
    
    var isComplete: Bool {
        !originContext.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destinationContext.trimmingCharacters(in: .whitespaces).isEmpty &&
        !intent.trimmingCharacters(in: .whitespaces).isEmpty &&
        !motivation.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var currentBeat: Beat? {
        guard let beats = store.currentScript?.beats,
              beatIndex < beats.count else { return nil }
        return beats[beatIndex]
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
                    
                    Text("CHARACTER CONTEXT")
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
                        
                        // Quick presets
                        VStack(spacing: 12) {
                            Text("QUICK START")
                                .font(AppFonts.caption(10))
                                .tracking(1)
                                .foregroundColor(AppColors.dimText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(ContextPresets.commonScenarios) { preset in
                                        Button {
                                            applyPreset(preset)
                                        } label: {
                                            Text(preset.label)
                                                .font(AppFonts.caption(11))
                                                .foregroundColor(selectedPreset?.id == preset.id ? AppColors.text : AppColors.accent)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(selectedPreset?.id == preset.id ? AppColors.accent : Color.clear)
                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(AppColors.accent, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .cinematicFade(delay: 0.15)
                        
                        SectionDivider()
                        
                        // Custom fields
                        VStack(spacing: 16) {
                            // Origin
                            ContextSelectionField(
                                label: "Where is the character coming from?",
                                placeholder: "e.g., Confrontation, Deception",
                                value: $originContext,
                                options: ContextPresets.origins,
                                showDropdown: $showOriginDropdown,
                                onSelect: { value in
                                    originContext = value
                                    showOriginDropdown = false
                                }
                            )
                            
                            // Destination
                            ContextSelectionField(
                                label: "Where is the character going?",
                                placeholder: "e.g., Reconciliation, Escape",
                                value: $destinationContext,
                                options: ContextPresets.destinations,
                                showDropdown: $showDestinationDropdown,
                                onSelect: { value in
                                    destinationContext = value
                                    showDestinationDropdown = false
                                }
                            )
                            
                            // Intent
                            ContextSelectionField(
                                label: "What is the character's intent?",
                                placeholder: "e.g., Threaten, Persuade",
                                value: $intent,
                                options: ContextPresets.intents,
                                showDropdown: $showIntentDropdown,
                                onSelect: { value in
                                    intent = value
                                    showIntentDropdown = false
                                }
                            )
                            
                            // Motivation
                            ContextSelectionField(
                                label: "What is the character's motivation?",
                                placeholder: "e.g., Desperation, Power",
                                value: $motivation,
                                options: ContextPresets.motivations,
                                showDropdown: $showMotivationDropdown,
                                onSelect: { value in
                                    motivation = value
                                    showMotivationDropdown = false
                                }
                            )
                        }
                        .padding(.top, 8)
                        .cinematicFade(delay: 0.2)
                        
                        // Continue button
                        VStack(spacing: 12) {
                            Button {
                                let context = CharacterContext(
                                    originContext: originContext,
                                    destinationContext: destinationContext,
                                    intent: intent,
                                    motivation: motivation
                                )
                                onContinue(context)
                            } label: {
                                Text("GENERATE DELIVERY GUIDE")
                                    .font(AppFonts.caption(14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(isComplete ? AppColors.text : AppColors.dimText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(isComplete ? AppColors.accent : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isComplete ? Color.clear : AppColors.accent.opacity(0.3), lineWidth: 1.5)
                                    )
                                    .cornerRadius(8)
                            }
                            .disabled(!isComplete)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                        .cinematicFade(delay: 0.3)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private func applyPreset(_ preset: ContextPreset) {
        originContext = preset.originContext
        destinationContext = preset.destinationContext
        intent = preset.intent
        motivation = preset.motivation
        selectedPreset = preset
    }
}

// MARK: - Context Selection Field

struct ContextSelectionField: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    let options: [String]
    @Binding var showDropdown: Bool
    let onSelect: (String) -> Void
    
    var filteredOptions: [String] {
        if value.isEmpty {
            return options
        }
        return options.filter { option in
            option.lowercased().contains(value.lowercased()) || value.lowercased().contains(option.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(AppFonts.caption(11))
                .tracking(0.5)
                .foregroundColor(AppColors.dimText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                TextField(placeholder, text: $value)
                    .font(AppFonts.body(16))
                    .foregroundColor(AppColors.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .onChange(of: value) { _ in
                        showDropdown = true
                    }
                    .onTapGesture {
                        showDropdown = true
                    }
                
                if showDropdown && !filteredOptions.isEmpty {
                    SectionDivider()
                        .padding(.horizontal, 12)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(filteredOptions.enumerated()), id: \.offset) { index, option in
                            if option.lowercased() != "custom" {
                                Button {
                                    onSelect(option)
                                } label: {
                                    Text(option)
                                        .font(AppFonts.body(14))
                                        .foregroundColor(AppColors.subtleText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .contentShape(Rectangle())
                                }
                                
                                if index < filteredOptions.count - 1 {
                                    SectionDivider()
                                        .padding(.horizontal, 12)
                                }
                            }
                        }
                    }
                    .backgroundColor(Color.white.opacity(0.02))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

struct BackgroundColorModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .background(color)
    }
}

extension View {
    func backgroundColor(_ color: Color) -> some View {
        modifier(BackgroundColorModifier(color: color))
    }
}

#Preview {
    CharacterContextView(
        store: ScriptStore(),
        beatIndex: 0,
        onContinue: { _ in },
        onBack: { }
    )
}
