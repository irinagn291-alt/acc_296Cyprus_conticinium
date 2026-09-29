import Foundation

/// In-memory source of truth for the folio chart. UserDefaults holds one JSON
/// projection under `ctn.folio.v1`. The UI talks only to this seam.
@MainActor
final class FolioChartStore {
    static let storageKey = FolioStorage.chartKey
    static let demoKey = FolioStorage.demoKey
    static let schemaVersion = FolioStorage.schemaVersion

    private let defaults: UserDefaults
    private let debounce: Duration
    private var saveTask: Task<Void, Never>?
    private var saveGeneration = 0

    private(set) var chart: FolioChart
    /// Set when a payload could not be decoded and the night fell back to Hush.
    private(set) var recoveryNote: String?

    init(
        defaults: UserDefaults = .standard,
        allowsDemoSeed: Bool = true,
        debounce: Duration = .milliseconds(350),
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        self.defaults = defaults
        self.debounce = debounce
        let loaded = FolioChartStore.decodeChart(defaults.data(forKey: Self.storageKey))
        chart = loaded.chart
        recoveryNote = loaded.recoveryNote
        if allowsDemoSeed {
            seedDemoIfNeeded(now: now, calendar: calendar)
        }
    }

    func tonight(now: Date = Date(), calendar: Calendar = .current) -> RitualSession {
        let key = Daykey.make(now, calendar: calendar)
        if let existing = chart.sessions.first(where: { $0.daykey == key }) {
            return existing
        }
        let session = RitualSession(daykey: key, folio: .openNight(daykey: key))
        chart.sessions.append(session)
        chart.sessions.sort { $0.daykey < $1.daykey }
        return session
    }

    func bankCurrentLeaf(
        elapsed: TimeInterval,
        skipped: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) async throws {
        try Task.checkCancellation()
        var session = tonight(now: now, calendar: calendar)
        try session.folio.bankCurrentLeaf(elapsed: elapsed, skipped: skipped, now: now)
        replace(session)
        scheduleSave()
    }

    func turnForward(now: Date = Date(), calendar: Calendar = .current) async -> TurnResult {
        if Task.isCancelled { return .held }
        var session = tonight(now: now, calendar: calendar)
        let result = session.folio.turnForward(now: now)
        replace(session)
        scheduleSave()
        return result
    }

    func turnBackward(now: Date = Date(), calendar: Calendar = .current) async {
        if Task.isCancelled { return }
        var session = tonight(now: now, calendar: calendar)
        session.folio.turnBackward()
        replace(session)
        scheduleSave()
    }

    func restTonight(now: Date = Date(), calendar: Calendar = .current) async throws {
        try Task.checkCancellation()
        var session = tonight(now: now, calendar: calendar)
        try session.folio.restTonight(now: now)
        replace(session)
        scheduleSave()
    }

    func updateDurations(_ durations: LeafDurations) async {
        chart.durations = durations
        scheduleSave()
    }

    func updateHaptics(_ enabled: Bool) async {
        chart.hapticsEnabled = enabled
        scheduleSave()
    }

    func updateOnboardingComplete(_ complete: Bool) async {
        chart.onboardingComplete = complete
        scheduleSave()
    }

    /// Debounced writes land here when the scene leaves the foreground, and after reset.
    func noteLifetime(_ phase: ChartLifetime) {
        switch phase {
        case .active:
            break
        case .inactive, .background:
            saveGeneration += 1
            saveTask?.cancel()
            saveTask = nil
            persist(chart)
        }
    }

    func flush() async {
        saveGeneration += 1
        saveTask?.cancel()
        saveTask = nil
        await Task.yield()
        guard !Task.isCancelled else { return }
        persist(chart)
    }

    /// Removes `ctn.folio.v1` and returns an empty Hush chart. Does not clear the demo flag.
    func resetAllData() async {
        saveGeneration += 1
        saveTask?.cancel()
        saveTask = nil
        defaults.removeObject(forKey: Self.storageKey)
        chart = .empty
        recoveryNote = nil
        defaults.removeObject(forKey: Self.storageKey)
    }

    func completedNightStreak(ending: Date = Date(), calendar: Calendar = .current) -> Int {
        let rested = Set(chart.sessions.filter(\.isRested).map(\.daykey))
        return NightStreak.count(restedDaykeys: rested, ending: ending, calendar: calendar)
    }

    private func replace(_ session: RitualSession) {
        chart.sessions.removeAll { $0.daykey == session.daykey }
        chart.sessions.append(session)
        chart.sessions.sort { $0.daykey < $1.daykey }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveGeneration += 1
        let ticket = saveGeneration
        let snapshot = chart
        let wait = debounce
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(for: wait)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            self?.persistIfCurrent(snapshot, ticket: ticket)
        }
    }

    private func persistIfCurrent(_ snapshot: FolioChart, ticket: Int) {
        guard ticket == saveGeneration else { return }
        persist(snapshot)
    }

    private func persist(_ snapshot: FolioChart) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        do {
            let data = try encoder.encode(snapshot)
            defaults.set(data, forKey: Self.storageKey)
        } catch {
            recoveryNote = "Tonight could not be saved. The open night is still on screen."
        }
    }

    private static func decodeChart(_ data: Data?) -> (chart: FolioChart, recoveryNote: String?) {
        guard let data, !data.isEmpty else {
            return (.empty, nil)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let chart = try decoder.decode(FolioChart.self, from: data)
            return (chart, nil)
        } catch {
            return (.empty, "A saved night could not be read. Tonight starts quiet.")
        }
    }

    private func seedDemoIfNeeded(now: Date, calendar: Calendar) {
        #if targetEnvironment(simulator)
        guard defaults.bool(forKey: Self.demoKey) == false else { return }
        guard chart.sessions.isEmpty else {
            defaults.set(true, forKey: Self.demoKey)
            return
        }
        do {
            chart = try FolioChart.simulatorSeed(now: now, calendar: calendar)
        } catch {
            recoveryNote = "A sample night could not be prepared. Tonight starts quiet."
            return
        }
        defaults.set(true, forKey: Self.demoKey)
        persist(chart)
        #else
        _ = now
        _ = calendar
        #endif
    }
}

enum ChartLifetime: Sendable {
    case active
    case inactive
    case background
}

enum FolioStorage {
    static let chartKey = "ctn.folio.v1"
    static let demoKey = "ctn.demo.v1"
    static let schemaVersion = 1
}

/// One chart root. schemaVersion 1. Holds daykey folds, durations, haptics, and onboarding.
struct FolioChart: Codable, Equatable, Sendable {
    var schemaVersion: Int
    var sessions: [RitualSession]
    var durations: LeafDurations
    var hapticsEnabled: Bool
    var onboardingComplete: Bool

    static let empty = FolioChart(
        schemaVersion: FolioStorage.schemaVersion,
        sessions: [],
        durations: .canonical,
        hapticsEnabled: true,
        onboardingComplete: false
    )

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case sessions
        case durations
        case hapticsEnabled
        case onboardingComplete
    }

    init(
        schemaVersion: Int,
        sessions: [RitualSession],
        durations: LeafDurations,
        hapticsEnabled: Bool,
        onboardingComplete: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.sessions = sessions
        self.durations = durations
        self.hapticsEnabled = hapticsEnabled
        self.onboardingComplete = onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            sessions = try container.decode([RitualSession].self, forKey: .sessions)
            durations = try container.decode(LeafDurations.self, forKey: .durations)
            hapticsEnabled = try container.decode(Bool.self, forKey: .hapticsEnabled)
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported folio chart schema \(version)."
            )
        }
    }

    static func simulatorSeed(now: Date, calendar: Calendar) throws -> FolioChart {
        let today = Daykey.make(now, calendar: calendar)
        var sessions: [RitualSession] = []
        for offset in 1...4 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: now)) else {
                continue
            }
            let key = Daykey.make(day, calendar: calendar)
            sessions.append(
                RitualSession(
                    daykey: key,
                    folio: try Folio.restedSample(daykey: key, now: day, flutters: offset)
                )
            )
        }
        var tonight = Folio.openNight(daykey: today)
        let reflectWhen = calendar.date(byAdding: .minute, value: -20, to: now) ?? now
        try tonight.bankCurrentLeaf(elapsed: 90, skipped: false, now: reflectWhen)
        _ = tonight.turnForward(now: reflectWhen)
        sessions.append(RitualSession(daykey: today, folio: tonight))
        sessions.sort { $0.daykey < $1.daykey }
        return FolioChart(
            schemaVersion: FolioStorage.schemaVersion,
            sessions: sessions,
            durations: .canonical,
            hapticsEnabled: true,
            onboardingComplete: true
        )
    }
}

extension Folio {
    /// A sealed night for History. Not the live opening leaf.
    static func restedSample(daykey: Int, now: Date, flutters: Int) throws -> Folio {
        var folio = Folio.openNight(daykey: daykey)
        let kinds: [LeafKind] = [.reflect, .breathe, .ambient]
        for (index, kind) in kinds.enumerated() {
            folio.current = kind
            let elapsed: TimeInterval = kind == .breathe ? 40 : 90
            try folio.bankCurrentLeaf(
                elapsed: elapsed,
                skipped: kind == .breathe,
                now: now.addingTimeInterval(TimeInterval(index * 90))
            )
            _ = folio.turnForward(now: now.addingTimeInterval(TimeInterval(index * 90 + 1)))
        }
        for flutterIndex in 0..<flutters {
            folio.flutters.append(
                FlutterMark(
                    id: UUID(),
                    leaf: .ambient,
                    markedAt: now.addingTimeInterval(TimeInterval(flutterIndex))
                )
            )
        }
        try folio.restTonight(now: now.addingTimeInterval(400))
        return folio
    }
}
