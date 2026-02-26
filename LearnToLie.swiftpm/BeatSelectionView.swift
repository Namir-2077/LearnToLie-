import SwiftUI

struct BeatSelectionView: View {
    @ObservedObject var store: ScriptStore
    let onSelect: (Int) -> Void
    let onBack: () -> Void
    
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
                    
                    Text("SELECT LINE")
                        .font(AppFonts.headerTitle(12))
                        .tracking(2)
                        .foregroundColor(AppColors.headerText)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 20, height: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 12)
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                // Header prompt
                Text("Which line would you like to evaluate?")
                    .font(AppFonts.caption(13))
                    .foregroundColor(AppColors.subtleText)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                
                // Beat List
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if let beats = store.currentScript?.beats {
                            ForEach(Array(beats.enumerated()), id: \.element.id) { index, beat in
                                Button {
                                    onSelect(index)
                                } label: {
                                    Text(beat.text)
                                        .font(AppFonts.beatText(18))
                                        .foregroundColor(AppColors.text)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.white.opacity(0.04))
                                        )
                                }
                                .buttonStyle(.plain)
                                .cinematicFade(delay: Double(index) * 0.05)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}
