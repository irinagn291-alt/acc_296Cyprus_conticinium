import SwiftUI

/// Sheet for page lengths, haptics, onboarding, reset, and the contact link.
struct SettingsSheet: View {
    @ObservedObject var desk: RitualDesk
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    private let contactURL = URL(string: "https://conticinium-folio.pro/contact-us")

    var body: some View {
        NavigationStack {
            Form {
                if let note = desk.recoveryNote {
                    Section {
                        Text(note)
                            .font(FolioChrome.body)
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Button("Try again") { desk.reload() }
                            .font(FolioChrome.body)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .listRowBackground(DesignTokens.surface)
                }
                Section {
                    durationRow("Reflect", value: desk.durations.reflect) { next in
                        var copy = desk.durations
                        copy.reflect = next
                        Task { await desk.setDurations(copy) }
                    }
                    durationRow("Breathe", value: desk.durations.breathe) { next in
                        var copy = desk.durations
                        copy.breathe = next
                        Task { await desk.setDurations(copy) }
                    }
                    durationRow("Ambient", value: desk.durations.ambient) { next in
                        var copy = desk.durations
                        copy.ambient = next
                        Task { await desk.setDurations(copy) }
                    }
                } header: {
                    Text("Page lengths")
                        .font(FolioChrome.caption)
                        .foregroundStyle(DesignTokens.muted)
                }
                .listRowBackground(DesignTokens.surface)
                Section {
                    Toggle("Haptics", isOn: hapticsBinding)
                        .font(FolioChrome.body)
                        .frame(minHeight: 44)
                } header: {
                    Text("Feel")
                        .font(FolioChrome.caption)
                        .foregroundStyle(DesignTokens.muted)
                }
                .listRowBackground(DesignTokens.surface)
                Section {
                    Button("Show the introduction") {
                        Task { await desk.reopenOnboarding() }
                    }
                    .font(FolioChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .tint(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                    Button("Reset all nights") {
                        confirmReset = true
                    }
                    .font(FolioChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                    .tint(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                    if let contactURL {
                        Link(destination: contactURL) {
                            Text("Contact")
                                .font(FolioChrome.body)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    }
                } header: {
                    Text("This device")
                        .font(FolioChrome.caption)
                        .foregroundStyle(DesignTokens.muted)
                }
                .listRowBackground(DesignTokens.surface)
            }
            .font(FolioChrome.body)
            .scrollContentBackground(.hidden)
            .background(DesignTokens.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(FolioChrome.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                }
                ToolbarItem(placement: .confirmationAction) {
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
            .confirmationDialog(
                "Reset all nights?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset all nights", role: .destructive) {
                    Task { await desk.resetNights() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Sealed nights and flutter marks on this device will be removed.")
            }
        }
        .presentationDragIndicator(.visible)
        .tint(DesignTokens.accent)
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { desk.hapticsEnabled },
            set: { enabled in
                Task { await desk.setHaptics(enabled) }
            }
        )
    }

    private func durationRow(_ title: String, value: Int, commit: @escaping (Int) -> Void) -> some View {
        Stepper(value: Binding(
            get: { value },
            set: { commit($0) }
        ), in: 30...240, step: 10) {
            VStack(alignment: .leading, spacing: FolioChrome.space(1)) {
                Text(title)
                    .font(FolioChrome.body)
                    .foregroundStyle(DesignTokens.ink)
                Text(FolioCount.seconds(value))
                    .font(FolioChrome.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .monospacedDigit()
            }
        }
        .frame(minHeight: 44)
    }
}
