import SwiftUI

/// Colour, type, space, and radius for every screen. Views do not invent a second kit.
enum FolioChrome {
    static let unit: CGFloat = 8

    static func space(_ steps: Int) -> CGFloat {
        unit * CGFloat(steps)
    }

    /// Cards, sheets, and primary surfaces.
    static let surfaceRadius: CGFloat = 28
    /// Chips, badges, and small controls.
    static let chipRadius: CGFloat = 14

    static func roman(_ size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        Font.custom("Charter-Roman", size: size, relativeTo: textStyle)
    }

    static func bold(_ size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        Font.custom("Charter-Bold", size: size, relativeTo: textStyle)
    }

    static func italic(_ size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
        Font.custom("Charter-Italic", size: size, relativeTo: textStyle)
    }

    static var display: Font { bold(34, relativeTo: .largeTitle) }
    static var title: Font { bold(28, relativeTo: .title) }
    static var headline: Font { bold(22, relativeTo: .title2) }
    static var body: Font { roman(17, relativeTo: .body) }
    static var caption: Font { roman(14, relativeTo: .subheadline) }
    static var micro: Font { roman(12, relativeTo: .caption) }
    static var leafName: Font { italic(22, relativeTo: .title2) }

    static let motion = Animation.easeOut(duration: 0.24)
    /// Reserved height for generated art. A multiple of `unit`.
    static let artFloor: CGFloat = 192
    /// Reading measure, 70 steps. The page may be wider; the column does not stretch with it.
    static let measure: CGFloat = unit * 70
}

enum FolioCount {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }

    static func seconds(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let digits = formatter.string(from: NSNumber(value: value)) ?? String(value)
        return "\(digits) seconds"
    }

    static func day(from daykey: Int) -> String {
        guard let date = Daykey.date(from: daykey) else {
            return FolioCount.integer(daykey)
        }
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct FolioHairline: View {
    var body: some View {
        Rectangle()
            .fill(DesignTokens.muted.opacity(0.45))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

/// Primary control. Default, pressed, disabled, and loading live in one style.
struct FolioCapsuleStyle: ButtonStyle {
    var destructive: Bool = false
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        FolioCapsuleBody(
            configuration: configuration,
            destructive: destructive,
            isLoading: isLoading
        )
    }
}

private struct FolioCapsuleBody: View {
    let configuration: ButtonStyleConfiguration
    var destructive: Bool
    var isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: FolioChrome.space(1)) {
            if isLoading {
                ProgressView()
                    .tint(DesignTokens.surface)
            }
            configuration.label
                .font(FolioChrome.body)
                .lineLimit(2)
        }
        .foregroundStyle(DesignTokens.surface)
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, FolioChrome.space(1))
        .padding(.horizontal, FolioChrome.space(2))
        .background(fill)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .opacity(pressedOpacity)
        .scaleEffect(pressedScale)
        .animation(FolioChrome.motion, value: configuration.isPressed)
    }

    private var fill: Color {
        if !isEnabled {
            return DesignTokens.muted
        }
        if destructive {
            return DesignTokens.ink
        }
        return DesignTokens.accent
    }

    private var pressedOpacity: Double {
        if configuration.isPressed { return 0.78 }
        return isEnabled ? 1 : 0.7
    }

    private var pressedScale: CGFloat {
        if reduceMotion || !isEnabled || !configuration.isPressed { return 1 }
        return 0.98
    }
}

struct FolioQuietStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FolioQuietBody(configuration: configuration)
    }
}

private struct FolioQuietBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(FolioChrome.body)
            .foregroundStyle(isEnabled ? DesignTokens.ink : DesignTokens.muted)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, FolioChrome.space(1))
            .padding(.horizontal, FolioChrome.space(2))
            .background(DesignTokens.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(DesignTokens.muted.opacity(isEnabled ? 0.55 : 0.35), lineWidth: 1)
            )
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.72 : (isEnabled ? 1 : 0.55))
            .scaleEffect(pressedScale)
            .animation(FolioChrome.motion, value: configuration.isPressed)
    }

    private var pressedScale: CGFloat {
        if reduceMotion || !isEnabled || !configuration.isPressed { return 1 }
        return 0.98
    }
}

/// Small chrome control. Chip radius, hairline, and a 44pt hit.
struct FolioMarkStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FolioMarkBody(configuration: configuration)
    }
}

private struct FolioMarkBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .font(FolioChrome.headline)
            .foregroundStyle(isEnabled ? DesignTokens.ink : DesignTokens.muted)
            .frame(width: 44, height: 44)
            .background(DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: FolioChrome.chipRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FolioChrome.chipRadius, style: .continuous)
                    .stroke(DesignTokens.muted.opacity(0.55), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: FolioChrome.chipRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(pressedScale)
            .animation(FolioChrome.motion, value: configuration.isPressed)
    }

    private var pressedScale: CGFloat {
        if reduceMotion || !configuration.isPressed { return 1 }
        return 0.96
    }
}

/// One elevated plate. Surface radius, hairline, pressed scale.
struct FolioPlateStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        FolioPlateBody(configuration: configuration)
    }
}

private struct FolioPlateBody: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .padding(FolioChrome.space(2))
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous)
                    .stroke(DesignTokens.muted.opacity(configuration.isPressed ? 0.9 : 0.45), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous))
            .scaleEffect(pressedScale)
            .animation(FolioChrome.motion, value: configuration.isPressed)
    }

    private var pressedScale: CGFloat {
        if reduceMotion || !configuration.isPressed { return 1 }
        return 0.98
    }
}

struct StaggeredReveal: ViewModifier {
    var index: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : FolioChrome.space(1))
            .onAppear {
                if reduceMotion {
                    shown = true
                    return
                }
                let delay = min(0.32, Double(index) * 0.05)
                withAnimation(FolioChrome.motion.delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func staggered(index: Int) -> some View {
        modifier(StaggeredReveal(index: index))
    }
}
