import SwiftUI

struct MemorizationResultsView: View {
    let results: [WordMatchResult]
    let onTryAgain: () -> Void
    let onFinish: () -> Void
    
    var accuracy: Double {
        guard !results.isEmpty else { return 0.0 }
        let correctCount = results.filter { result in
            if case .correct = result.type { return true }
            return false
        }.count
        return Double(correctCount) / Double(results.count)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Spacer()
                    
                    Text("MEMORY RESULTS")
                        .font(AppFonts.headerTitle(11))
                        .tracking(2)
                        .foregroundColor(AppColors.headerText)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                SectionDivider()
                    .padding(.horizontal, 24)
                
                // Score visualization
                VStack(spacing: 8) {
                    Text("\(Int(accuracy * 100))%")
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(accuracy > 0.8 ? AppColors.accent : (accuracy > 0.5 ? Color.orange : Color.red.opacity(0.8)))
                        .cinematicFade(delay: 0.1)
                    
                    Text("ACCURACY")
                        .font(AppFonts.caption(10))
                        .tracking(2)
                        .foregroundColor(AppColors.dimText)
                        .cinematicFade(delay: 0.2)
                }
                .padding(.top, 32)
                .padding(.bottom, 24)
                
                // Flow Layout for results
                ScrollView(.vertical, showsIndicators: false) {
                    // Using a simple wrapping layout approach (if FlowLayout is missing, we can use LazyVGrid or wrapping container)
                    // For pure SwiftUI standard without complex GeometryReader logic, we render a combined view
                    VStack(alignment: .leading, spacing: 12) {
                        FlowLayout(spacing: 6) {
                            ForEach(results) { result in
                                WordResultPill(result: result)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .cinematicFade(delay: 0.4)
                }
                
                // Actions
                VStack(spacing: 16) {
                    AccentFilledButton(title: "Try Again") {
                        onTryAgain()
                    }
                    
                    Button("Finish Practice") {
                        onFinish()
                    }
                    .font(AppFonts.caption(14))
                    .foregroundColor(AppColors.dimText)
                    .padding(.vertical, 8)
                }
                .padding(.bottom, 40)
                .cinematicFade(delay: 0.6)
            }
        }
    }
}

// MARK: - Components

struct WordResultPill: View {
    let result: WordMatchResult
    
    var body: some View {
        Group {
            switch result.type {
            case .correct(let text):
                Text(text)
                    .font(AppFonts.mono(16))
                    .foregroundColor(AppColors.accentBright)
                
            case .incorrect(let expected, let actual):
                VStack(spacing: 2) {
                    Text(expected)
                        .font(AppFonts.mono(14))
                        .strikethrough()
                        .foregroundColor(Color.red.opacity(0.8))
                    Text(actual)
                        .font(AppFonts.mono(14))
                        .foregroundColor(Color.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(4)
                
            case .missing(let expected):
                Text(expected)
                    .font(AppFonts.mono(14))
                    .foregroundColor(Color.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(4)
                    
            case .extra(let actual):
                Text(actual)
                    .font(AppFonts.mono(14))
                    .strikethrough()
                    .foregroundColor(.gray)
            }
        }
    }
}

// Simple FlowLayout Implementation for SwiftUI
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
        
        height = currentY + rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
