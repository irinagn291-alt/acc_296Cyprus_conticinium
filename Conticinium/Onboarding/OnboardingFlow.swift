import SwiftUI

/// Three pages. Skip still writes 90, 120, and 90 second pages and leaves haptics on.
struct OnboardingFlow: View {
    @ObservedObject var desk: RitualDesk
    @State private var page = 0
    @ScaledMetric(relativeTo: .largeTitle) private var artFloor: CGFloat = 192

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
                pageBody
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                if page < 2 {
                    Button("Next") { page += 1 }
                        .buttonStyle(FolioCapsuleStyle())
                } else {
                    Button("Continue") {
                        Task { await desk.completeOnboarding(skip: false) }
                    }
                    .buttonStyle(FolioCapsuleStyle())
                }
                Button("Skip") {
                    Task { await desk.completeOnboarding(skip: true) }
                }
                .buttonStyle(FolioQuietStyle())
            }
            .padding(FolioChrome.space(3))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    private var pageBody: some View {
        switch page {
        case 0:
            pageCopy(
                art: "ctn_Onboarding1",
                title: "An evening in order",
                line: "Four pages, one after another. Reflect, breathe, ambient, then rest."
            )
        case 1:
            pageCopy(
                art: "ctn_Onboarding2",
                title: "Keep, then turn",
                line: "Keep the page you are on. Turn moves only after that mark is there."
            )
        default:
            pageCopy(
                art: "ctn_Onboarding3",
                title: "Rest seals the night",
                line: "When the three pages hold a mark, rest files the night on this device."
            )
        }
    }

    private func pageCopy(art: String, title: String, line: String) -> some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
            Image(art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, minHeight: artFloor, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)
            Text(title)
                .font(FolioChrome.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(FolioChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(pageMark)
                .font(FolioChrome.micro)
                .foregroundStyle(DesignTokens.muted)
                .monospacedDigit()
        }
    }

    private var pageMark: String {
        let current = FolioCount.integer(page + 1)
        let total = FolioCount.integer(3)
        return "Page " + current + " of " + total
    }
}
