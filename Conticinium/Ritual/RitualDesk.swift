import Foundation

/// Presentation seam. Screens call these methods. They never write a LeafMark, FlutterMark, or RestMark themselves.
@MainActor
final class RitualDesk: ObservableObject {
    let store: FolioChartStore

    @Published private(set) var session: RitualSession
    @Published private(set) var durations: LeafDurations
    @Published private(set) var hapticsEnabled: Bool
    @Published private(set) var recoveryNote: String?
    @Published var showOnboarding: Bool
    @Published var showHistory = false
    @Published var showSettings = false
    @Published var beatRunning = false
    @Published var beatElapsed: TimeInterval = 0
    @Published var banking = false
    @Published var resting = false
    @Published var inkSettled = false
    @Published var notice: String?
    @Published var flutterPulse = 0
    @Published private(set) var hapticTick = 0
    @Published private(set) var showWait = false

    private var beatTask: Task<Void, Never>?
    private var noticeTask: Task<Void, Never>?
    private var inkTask: Task<Void, Never>?
    private var waitTask: Task<Void, Never>?
    private var launchConsumed = false
    private let tone = AmbientTone()

    init(store: FolioChartStore) {
        self.store = store
        let night = store.tonight()
        session = night
        durations = store.chart.durations
        hapticsEnabled = store.chart.hapticsEnabled
        recoveryNote = store.recoveryNote
        showOnboarding = !store.chart.onboardingComplete
    }

    var folio: Folio { session.folio }

    var streak: Int {
        store.completedNightStreak()
    }

    var sealedNights: [RitualSession] {
        store.chart.sessions.filter(\.isRested).sorted { $0.daykey > $1.daykey }
    }

    var cue: BeatCue {
        let span = TimeInterval(durations.seconds(for: folio.current))
        return GuidedBeat.cue(at: beatElapsed, duration: span > 0 ? span : 1)
    }

    var canBank: Bool {
        guard folio.fold != .rested, folio.current.banksALeafMark else { return false }
        return folio.currentLeaf?.isBanked != true
    }

    var canTurn: Bool {
        folio.fold != .rested && folio.current != .rest
    }

    var canRest: Bool {
        folio.fold != .rested && folio.current == .rest && folio.priorLeavesBanked
    }

    func reload() {
        session = store.tonight()
        durations = store.chart.durations
        hapticsEnabled = store.chart.hapticsEnabled
        recoveryNote = store.recoveryNote
        syncTone()
    }

    func consumeLaunchIfReady() {
        guard !launchConsumed else { return }
        let screen = ReviewLaunch.screen
        if showOnboarding, screen != "onboarding" { return }
        launchConsumed = true
        switch screen {
        case "log", "history":
            showHistory = true
        case "goals", "settings":
            showSettings = true
        case "onboarding":
            showOnboarding = true
        default:
            break
        }
    }

    func completeOnboarding(skip: Bool) async {
        if skip {
            await store.updateDurations(.canonical)
            await store.updateHaptics(true)
        }
        await store.updateOnboardingComplete(true)
        showOnboarding = false
        reload()
        consumeLaunchIfReady()
    }

    func reopenOnboarding() async {
        await store.updateOnboardingComplete(false)
        showOnboarding = true
        showSettings = false
    }

    func beginBank() {
        guard canBank else {
            publishRefusal(bankRefusal())
            return
        }
        beatTask?.cancel()
        beatRunning = true
        beatElapsed = 0
        let span = TimeInterval(max(durations.seconds(for: folio.current), 1))
        beatTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, !Task.isCancelled else { return }
                self.beatElapsed += 0.1
                if self.beatElapsed >= span {
                    await self.commitBank(skipped: false)
                    return
                }
            }
        }
    }

    func skipBeat() async {
        guard beatRunning else { return }
        await commitBank(skipped: true)
    }

    func turnForward() async {
        guard canTurn else { return }
        let result = await store.turnForward()
        reload()
        switch result {
        case .fluttered:
            flutterPulse += 1
            notice = "This page is not kept yet. It stays here."
            scheduleNoticeClear()
        case .advanced:
            notice = nil
        case .held:
            notice = "This page is the end of tonight."
            scheduleNoticeClear()
        }
        syncTone()
    }

    func turnBackward() async {
        await store.turnBackward()
        reload()
        syncTone()
    }

    func resolveSwipe(from: LeafKind, to: LeafKind) async {
        guard from != to else { return }
        let fromIndex = LeafKind.canonical.firstIndex(of: from) ?? 0
        let toIndex = LeafKind.canonical.firstIndex(of: to) ?? 0
        if toIndex > fromIndex {
            await turnForward()
        } else {
            await turnBackward()
        }
    }

    func restTonight() async {
        guard !resting else { return }
        resting = true
        armWait()
        defer {
            resting = false
            clearWait()
        }
        do {
            try await store.restTonight()
            reload()
            pulseHaptic()
            settleInk()
            notice = "Tonight is sealed."
            scheduleNoticeClear()
        } catch let error as FolioRefusal {
            publishRefusal(error)
        } catch {
            notice = "Rest did not seal. Try again in a moment."
            scheduleNoticeClear()
        }
    }

    func setDurations(_ next: LeafDurations) async {
        await store.updateDurations(next)
        reload()
    }

    func setHaptics(_ enabled: Bool) async {
        await store.updateHaptics(enabled)
        reload()
    }

    func resetNights() async {
        beatTask?.cancel()
        beatRunning = false
        await store.resetAllData()
        await store.updateDurations(.canonical)
        await store.updateHaptics(true)
        await store.updateOnboardingComplete(true)
        reload()
        notice = "Every sealed night is gone from this device."
        scheduleNoticeClear()
        syncTone()
    }

    func stopTone() {
        tone.stop()
    }

    private func commitBank(skipped: Bool) async {
        beatTask?.cancel()
        beatTask = nil
        let elapsed = max(beatElapsed, 0)
        beatRunning = false
        banking = true
        armWait()
        defer {
            banking = false
            clearWait()
        }
        do {
            try await store.bankCurrentLeaf(elapsed: elapsed, skipped: skipped)
            reload()
            pulseHaptic()
            settleInk()
            notice = skipped ? "Page kept. You can turn forward." : "Page kept."
            scheduleNoticeClear()
        } catch let error as FolioRefusal {
            publishRefusal(error)
        } catch is CancellationError {
            return
        } catch {
            notice = "The mark did not land. Keep this page again."
            scheduleNoticeClear()
        }
    }

    private func bankRefusal() -> FolioRefusal {
        if folio.fold == .rested { return .bankAfterRest }
        if !folio.current.banksALeafMark { return .bankOnRestLeaf }
        return .alreadySeated
    }

    private func publishRefusal(_ error: FolioRefusal) {
        switch error {
        case .restTooEarly:
            notice = "Rest waits until Reflect, Breathe, and Ambient are each kept."
        case .bankAfterRest:
            notice = "Tonight is sealed. Open History to see the mark."
        case .bankOnRestLeaf:
            notice = "This page seals the night. Rest when the earlier pages are kept."
        case .alreadySeated:
            notice = "This page is already kept. Turn forward."
        case .negativeElapsed:
            notice = "The beat could not be read. Start it again."
        }
        scheduleNoticeClear()
    }

    private func armWait() {
        waitTask?.cancel()
        showWait = false
        waitTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            guard let self, !Task.isCancelled else { return }
            if self.banking || self.resting {
                self.showWait = true
            }
        }
    }

    private func clearWait() {
        waitTask?.cancel()
        waitTask = nil
        showWait = false
    }

    private func pulseHaptic() {
        guard hapticsEnabled else { return }
        hapticTick += 1
    }

    private func settleInk() {
        inkSettled = true
        inkTask?.cancel()
        inkTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            self?.inkSettled = false
        }
    }

    private func scheduleNoticeClear() {
        noticeTask?.cancel()
        noticeTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3.2))
            guard !Task.isCancelled else { return }
            self?.notice = nil
        }
    }

    private func syncTone() {
        if folio.current == .ambient, folio.fold != .rested {
            tone.start()
        } else {
            tone.stop()
        }
    }
}
