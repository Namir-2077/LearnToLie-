import SwiftUI

// MARK: - App Colors

enum AppColors {
    // Primary colors
    static let background = Color(red: 0.03/255, green: 0.03/255, blue: 0.03/255) // Deep black
    static let backgroundSecondary = Color.black.opacity(0.7)
    static let text = Color.white
    static let accent = Color(red: 14/255, green: 59/255, blue: 46/255) // #0E3B2E
    static let accentBright = Color(red: 34/255, green: 139/255, blue: 109/255) // Vibrant green
    static let accentDim = Color(red: 14/255, green: 59/255, blue: 46/255).opacity(0.6)
    
    // Text colors
    static let dimText = Color.white.opacity(0.4)
    static let headerText = Color.white.opacity(0.9)
    static let subtleText = Color.white.opacity(0.6)
    static let accentText = Color.white.opacity(0.8)
    
    // Border/separator colors
    static let border = Color.white.opacity(0.12)
    static let borderLight = Color.white.opacity(0.08)
    
    // Gradient colors
    static let gradientStart = Color(red: 14/255, green: 59/255, blue: 46/255)
    static let gradientEnd = Color(red: 34/255, green: 139/255, blue: 109/255)
}

// MARK: - App Fonts

enum AppFonts {
    static func header(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    static func headerTitle(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func title(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func body(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func beatText(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func mono(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

// MARK: - Cinematic Fade Modifier

struct CinematicFade: ViewModifier {
    @State private var appeared = false
    let delay: Double
    
    init(delay: Double = 0) {
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func cinematicFade(delay: Double = 0) -> some View {
        modifier(CinematicFade(delay: delay))
    }
}

// MARK: - Modern Shadow Modifier

struct ModernShadow: ViewModifier {
    var radius: CGFloat = 12
    var color: Color = .black
    var opacity: Double = 0.15
    var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity), radius: radius, x: offset, y: offset + 2)
    }
}

extension View {
    func modernShadow(radius: CGFloat = 12, color: Color = .black, opacity: Double = 0.15) -> some View {
        modifier(ModernShadow(radius: radius, color: color, opacity: opacity))
    }
}

// MARK: - Glass Background Modifier

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 12
    var opacity: Double = 0.08
    var bordered: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(opacity))
                    .backdrop()
            )
            .if(bordered) { view in
                view.overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            }
    }
}

extension View {
    func glass(cornerRadius: CGFloat = 12, opacity: Double = 0.08, bordered: Bool = true) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius, opacity: opacity, bordered: bordered))
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Backdrop Effect Helper

struct BackdropView: View {
    var body: some View {
        Color.clear
    }
}

extension View {
    func backdrop() -> some View {
        self
    }
}

// MARK: - Green Outline Button

struct GreenOutlineButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.body(16))
                .foregroundColor(AppColors.accentBright)
                .fontWeight(.semibold)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.accentBright, lineWidth: 1.5)
                )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .brightness(isPressed ? 0.1 : 0)
        .onLongPressGesture(minimumDuration: 0.001, perform: {}, onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        })
    }
}

// MARK: - Accent Filled Button

struct AccentFilledButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption(14))
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.accentBright, AppColors.accent]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(8)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .brightness(isPressed ? -0.08 : 0)
        .onLongPressGesture(minimumDuration: 0.001, perform: {}, onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        })
    }
}

// MARK: - Progress Bar

struct CinematicProgressBar: View {
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 4)
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.accentBright,
                        AppColors.accent
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geo.size.width * CGFloat(progress), height: 4)
                .cornerRadius(2)
                .animation(.easeInOut(duration: 0.3), value: progress)
                .shadow(color: AppColors.accentBright.opacity(0.4), radius: 8, x: 0, y: 0)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Breath Pacing View

struct BreathPacingView: View {
    @State private var isPulsing = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(AppColors.accent.opacity(isPulsing ? 0.6 : 0.15))
            .frame(height: 3)
            .scaleEffect(x: isPulsing ? 1.0 : 0.7, y: 1.0, anchor: .center)
            .animation(
                .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// MARK: - Section Divider

struct SectionDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
    }
}

// MARK: - Emotion Tag View

struct EmotionTagView: View {
    let emotion: Emotion
    
    var body: some View {
        Text(emotion.rawValue.uppercased())
            .font(AppFonts.caption(11))
            .tracking(1.3)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.accentBright)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}
