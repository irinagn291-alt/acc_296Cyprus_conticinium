import SwiftUI

/// Sheet of sealed nights. Counts rest marks and flutter marks, never hours slept.
struct HistoryScreen: View {
    @ObservedObject var desk: RitualDesk
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .largeTitle) private var artFloor: CGFloat = 192

    var body: some View {
        NavigationStack {
            Group {
                if desk.recoveryNote != nil, desk.sealedNights.isEmpty {
                    errorState
                } else if desk.sealedNights.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(DesignTokens.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sealed nights")
                        .font(FolioChrome.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(FolioChrome.headline)
                            .foregroundStyle(DesignTokens.ink)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var list: some View {
        List {
            ForEach(desk.sealedNights) { night in
                HStack(alignment: .firstTextBaseline, spacing: FolioChrome.space(2)) {
                    Text(FolioCount.day(from: night.daykey))
                        .font(FolioChrome.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer(minLength: FolioChrome.space(2))
                    Text(markLine(night))
                        .font(FolioChrome.caption)
                        .foregroundStyle(DesignTokens.muted)
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .layoutPriority(1)
                }
                .frame(minHeight: 44)
                .listRowBackground(DesignTokens.surface)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, FolioChrome.space(3), for: .scrollContent)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
            Image("ctn_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, minHeight: artFloor, maxHeight: .infinity)
                .padding(FolioChrome.space(2))
                .background(DesignTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous))
                .overlay(plateStroke)
                .clipped()
                .accessibilityHidden(true)
            Text("No sealed night yet")
                .font(FolioChrome.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            Text("Keep the three pages, then rest. The mark will wait here.")
                .font(FolioChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Back to tonight") { dismiss() }
                .buttonStyle(FolioCapsuleStyle())
        }
        .padding(FolioChrome.space(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var errorState: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
            Text("Nights could not be read")
                .font(FolioChrome.headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            Text(desk.recoveryNote ?? "A saved night could not be read.")
                .font(FolioChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Try again") { desk.reload() }
                .buttonStyle(FolioCapsuleStyle())
            Button("Back to tonight") { dismiss() }
                .buttonStyle(FolioQuietStyle())
        }
        .padding(FolioChrome.space(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var plateStroke: some View {
        RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous)
            .stroke(DesignTokens.muted.opacity(0.45), lineWidth: 1)
    }

    private func markLine(_ night: RitualSession) -> String {
        let rests = night.folio.rest == nil ? 0 : 1
        let flutters = night.folio.flutters.count
        return countPhrase(rests, singular: "rest mark", plural: "rest marks")
            + ", "
            + countPhrase(flutters, singular: "flutter mark", plural: "flutter marks")
    }

    private func countPhrase(_ value: Int, singular: String, plural: String) -> String {
        let digits = FolioCount.integer(value)
        if value == 1 {
            return digits + " " + singular
        }
        return digits + " " + plural
    }
}
