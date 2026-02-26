import SwiftUI

struct ScriptInputView: View {
    @ObservedObject var store: ScriptStore
    let onSaved: () -> Void
    
    @State private var scriptText: String = ""
    @State private var showingSample = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Button {
                        scriptText = ""
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                            Text("NEW SCRIPT")
                                .font(AppFonts.caption(11))
                                .tracking(1.5)
                        }
                        .foregroundColor(AppColors.accent)
                    }
                    
                    Spacer()
                    
                    Menu {
                        ForEach(ScriptStore.SampleScript.allCases, id: \.self) { sample in
                            Button(sample.rawValue) {
                                scriptText = sample.text
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("LOAD SAMPLE")
                                .font(AppFonts.caption(11))
                                .tracking(1.5)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(AppColors.accent)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                // Text Editor
                ZStack(alignment: .topLeading) {
                    if scriptText.isEmpty {
                        Text("Paste your monologue or scene here...")
                            .font(AppFonts.beatText(18))
                            .foregroundColor(AppColors.dimText)
                            .padding(.top, 24)
                            .padding(.horizontal, 24)
                    }
                    
                    TextEditor(text: $scriptText)
                        .font(AppFonts.beatText(18))
                        .foregroundColor(AppColors.text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .tint(AppColors.accentBright)
                }
                .frame(maxHeight: .infinity)
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                // Bottom action
                HStack {
                    Spacer()
                    
                    Button {
                        guard !scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        store.saveAndParseScript(scriptText)
                        onSaved()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Save & Break Into Beats")
                                .font(AppFonts.caption(14))
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColors.dimText : AppColors.text)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.white.opacity(0.05)
                            : AppColors.accent
                        )
                        .cornerRadius(8)
                    }
                    .disabled(scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            if let existing = store.currentScript {
                scriptText = existing.rawText
            }
        }
    }
}
