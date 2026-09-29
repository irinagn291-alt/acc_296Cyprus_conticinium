import SwiftUI
import UIKit

/// Permanent root. Tonight's pages never leave. Keep and Turn are fused here.
struct RitualScreen: View {
    @StateObject private var desk: RitualDesk
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    init(store: FolioChartStore) {
        _desk = StateObject(wrappedValue: RitualDesk(store: store))
    }

    var body: some View {
        ZStack {
            DesignTokens.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                chrome
                surface
            }
        }
        .sensoryFeedback(.impact, trigger: desk.hapticTick)
        .sheet(isPresented: $desk.showHistory) {
            HistoryScreen(desk: desk)
                .presentationCornerRadius(FolioChrome.surfaceRadius)
        }
        .sheet(isPresented: $desk.showSettings) {
            SettingsSheet(desk: desk)
                .presentationCornerRadius(FolioChrome.surfaceRadius)
        }
        .fullScreenCover(isPresented: $desk.showOnboarding) {
            OnboardingFlow(desk: desk)
        }
        .onAppear {
            desk.reload()
            desk.consumeLaunchIfReady()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                desk.reload()
            } else {
                desk.stopTone()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            desk.reload()
        }
        .onDisappear {
            desk.stopTone()
        }
    }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(1)) {
            HStack(alignment: .center, spacing: FolioChrome.space(2)) {
                Text("Tonight")
                    .font(FolioChrome.title)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: FolioChrome.space(2))
                Button {
                    desk.showHistory = true
                } label: {
                    Image(systemName: "book.closed")
                }
                .buttonStyle(FolioMarkStyle())
                .accessibilityLabel("History")
                Button {
                    desk.showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(FolioMarkStyle())
                .accessibilityLabel("Settings")
            }
            Text(streakLine)
                .font(FolioChrome.caption)
                .foregroundStyle(DesignTokens.muted)
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, FolioChrome.space(3))
        .padding(.top, FolioChrome.space(2))
        .padding(.bottom, FolioChrome.space(2))
    }

    @ViewBuilder
    private var surface: some View {
        if desk.recoveryNote != nil, desk.store.chart.sessions.isEmpty {
            RitualError(note: desk.recoveryNote ?? "Tonight could not be read.") {
                desk.reload()
            }
        } else if desk.folio.hush != nil, desk.folio.fold == .open {
            HushPage(desk: desk)
        } else {
            ZStack {
                InkWashAccent(settled: desk.inkSettled, reduceMotion: reduceMotion)
                    .ignoresSafeArea(edges: .bottom)
                    .accessibilityHidden(true)
                FolioPages(desk: desk, reduceMotion: reduceMotion)
            }
        }
    }

    private var streakLine: String {
        let count = desk.streak
        if count == 0 {
            return "No sealed night yet."
        }
        if count == 1 {
            return FolioCount.integer(1) + " sealed night."
        }
        return FolioCount.integer(count) + " sealed nights."
    }
}

/// Empty open night. One headline, one line, one control that starts tonight.
private struct HushPage: View {
    @ObservedObject var desk: RitualDesk
    @ScaledMetric(relativeTo: .largeTitle) private var artFloor: CGFloat = 192

    var body: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
            Image("ctn_HushFold")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, minHeight: artFloor, maxHeight: .infinity)
                .padding(FolioChrome.space(2))
                .background(DesignTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous))
                .overlay(plateStroke)
                .clipped()
                .accessibilityHidden(true)
                .staggered(index: 0)
            Text("Build tonight's rite")
                .font(FolioChrome.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .staggered(index: 1)
            Text("Four pages, in order. You can skip a page if you must.")
                .font(FolioChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
                .staggered(index: 2)
            if desk.beatRunning {
                Text(cueWord)
                    .font(FolioChrome.headline)
                    .foregroundStyle(DesignTokens.accent)
                Button("End early") {
                    Task { await desk.skipBeat() }
                }
                .buttonStyle(FolioQuietStyle())
            }
            if let notice = desk.notice {
                Text(notice)
                    .font(FolioChrome.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button("Begin with Reflect") {
                desk.beginBank()
            }
            .buttonStyle(FolioCapsuleStyle(isLoading: desk.showWait))
            .disabled(desk.beatRunning || desk.banking)
            .staggered(index: 3)
        }
        .padding(FolioChrome.space(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var plateStroke: some View {
        RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous)
            .stroke(DesignTokens.muted.opacity(0.45), lineWidth: 1)
    }

    private var cueWord: String {
        switch desk.cue {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .settle: return "Settle"
        }
    }
}

private struct RitualError: View {
    var note: String
    var retry: () -> Void
    @ScaledMetric(relativeTo: .largeTitle) private var artFloor: CGFloat = 192

    var body: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
            Image("ctn_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, minHeight: artFloor, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)
            Text("Tonight could not be read")
                .font(FolioChrome.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            Text(note)
                .font(FolioChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Try again") {
                retry()
            }
            .buttonStyle(FolioCapsuleStyle())
        }
        .padding(FolioChrome.space(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
