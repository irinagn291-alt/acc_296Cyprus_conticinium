import XCTest
@testable import Conticinium

@MainActor
final class ConticiniumTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func makeStore() -> (FolioChartStore, UserDefaults) {
        let name = "ctn.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        let store = FolioChartStore(defaults: defaults, allowsDemoSeed: false, debounce: .milliseconds(40))
        return (store, defaults)
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertEqual(
            ReviewLaunch.screen(in: ["Conticinium", "-ReviewScreen", "today"]),
            "today"
        )
        XCTAssertEqual(
            ReviewLaunch.screen(in: ["Conticinium", "-ReviewScreen", "log"]),
            "log"
        )
        XCTAssertEqual(
            ReviewLaunch.screen(in: ["Conticinium", "-ReviewScreen", "goals"]),
            "goals"
        )
        XCTAssertNil(ReviewLaunch.screen(in: ["Conticinium"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Conticinium", "-ReviewScreen"]))
    }

    func testCanonicalOrderDurationsSkipAndCue() throws {
        var folio = Folio.openNight(daykey: 20260926)
        XCTAssertEqual(folio.leaves.map(\.kind), LeafKind.canonical)
        XCTAssertEqual(LeafDurations.canonical.reflect, 90)
        XCTAssertEqual(LeafDurations.canonical.breathe, 120)
        XCTAssertEqual(LeafDurations.canonical.ambient, 90)
        XCTAssertEqual(folio.fold, .open)
        XCTAssertEqual(folio.hush, .waiting)

        try folio.bankCurrentLeaf(elapsed: 12, skipped: true, now: Date(timeIntervalSince1970: 10))
        XCTAssertEqual(folio.fold, .leafed)
        XCTAssertNil(folio.hush)
        XCTAssertEqual(folio.leaf(.reflect)?.mark?.skipped, true)
        XCTAssertEqual(folio.leaf(.reflect)?.mark?.elapsed, 12)

        XCTAssertEqual(GuidedBeat.cue(at: 0, duration: 90), .inhale)
        XCTAssertEqual(GuidedBeat.cue(at: 45, duration: 90), .hold)
        XCTAssertEqual(GuidedBeat.cue(at: 70, duration: 90), .exhale)
        XCTAssertEqual(GuidedBeat.cue(at: 88, duration: 90), .settle)
    }

    func testEmptyTurnAndEarlyRestRefuse() {
        var folio = Folio.openNight(daykey: 20260926)
        let turned = folio.turnForward(now: Date(timeIntervalSince1970: 1))
        guard case .fluttered(let flutter) = turned else {
            return XCTFail("unmarked turn should flutter")
        }
        XCTAssertEqual(flutter.leaf, .reflect)
        XCTAssertEqual(folio.current, .reflect)
        XCTAssertEqual(folio.fold, .open)
        XCTAssertThrowsError(try folio.restTonight(now: Date(timeIntervalSince1970: 2))) { error in
            XCTAssertEqual(error as? FolioRefusal, .restTooEarly)
        }
    }

    func testBankThenTurnThenRestSealsAndStreakCountsRestedNights() throws {
        var folio = Folio.openNight(daykey: 20260926)
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        try folio.bankCurrentLeaf(elapsed: 90, skipped: false, now: now)
        XCTAssertEqual(folio.turnForward(now: now), .advanced(to: .breathe))
        try folio.bankCurrentLeaf(elapsed: 40, skipped: true, now: now)
        XCTAssertEqual(folio.turnForward(now: now), .advanced(to: .ambient))
        let flutter = folio.turnForward(now: now)
        guard case .fluttered = flutter else {
            return XCTFail("unmarked ambient turn should flutter and stay")
        }
        XCTAssertEqual(folio.current, .ambient)
        try folio.bankCurrentLeaf(elapsed: 90, skipped: false, now: now)
        XCTAssertEqual(folio.turnForward(now: now), .advanced(to: .rest))
        XCTAssertThrowsError(try folio.bankCurrentLeaf(elapsed: 1, skipped: false, now: now)) { error in
            XCTAssertEqual(error as? FolioRefusal, .bankOnRestLeaf)
        }
        try folio.restTonight(now: now)
        XCTAssertEqual(folio.fold, .rested)
        XCTAssertNotNil(folio.rest)
        XCTAssertThrowsError(try folio.bankCurrentLeaf(elapsed: 1, skipped: false, now: now)) { error in
            XCTAssertEqual(error as? FolioRefusal, .bankAfterRest)
        }
        let backwardFlutters = folio.flutters.count
        folio.turnBackward()
        XCTAssertEqual(folio.flutters.count, backwardFlutters)

        let rested = try Folio.restedSample(daykey: 20260925, now: now, flutters: 2)
        let openOnly = Folio.openNight(daykey: 20260924)
        let keys: Set<Int> = [rested.daykey, folio.daykey]
        XCTAssertNil(openOnly.rest)
        XCTAssertEqual(
            NightStreak.count(restedDaykeys: keys, ending: Date(timeIntervalSince1970: 1_758_000_000), calendar: calendar),
            0
        )
        let ending = try XCTUnwrap(Daykey.date(from: 20260926, calendar: calendar))
        XCTAssertEqual(NightStreak.count(restedDaykeys: [20260926, 20260925], ending: ending, calendar: calendar), 2)
        XCTAssertEqual(NightStreak.count(restedDaykeys: [20260925], ending: ending, calendar: calendar), 1)
        XCTAssertFalse(keys.contains(openOnly.daykey))
    }

    func testNegativeElapsedIsInvalid() {
        var folio = Folio.openNight(daykey: 1)
        XCTAssertThrowsError(try folio.bankCurrentLeaf(elapsed: -1, skipped: false, now: Date())) { error in
            XCTAssertEqual(error as? FolioRefusal, .negativeElapsed)
        }
        XCTAssertEqual(folio.fold, .open)
    }

    func testArchitectureFoldRefusesRestBeforeThreeMarks() throws {
        var folio = Folio.openNight(daykey: 3)
        XCTAssertEqual(folio.fold, .open)
        try folio.bankCurrentLeaf(elapsed: 90, skipped: false, now: Date())
        XCTAssertEqual(folio.fold, .leafed)
        _ = folio.turnForward(now: Date())
        try folio.bankCurrentLeaf(elapsed: 120, skipped: false, now: Date())
        XCTAssertThrowsError(try folio.restTonight(now: Date())) { error in
            XCTAssertEqual(error as? FolioRefusal, .restTooEarly)
        }
        XCTAssertEqual(folio.fold, .leafed)
        XCTAssertNil(folio.rest)
    }

    func testPersistenceRoundTripAndCorruptFallback() async throws {
        let (store, defaults) = makeStore()
        let now = Date(timeIntervalSince1970: 1_700_100_000)
        try await store.bankCurrentLeaf(elapsed: 90, skipped: false, now: now, calendar: calendar)
        let turned = await store.turnForward(now: now, calendar: calendar)
        XCTAssertEqual(turned, .advanced(to: .breathe))
        await store.flush()

        let reloaded = FolioChartStore(defaults: defaults, allowsDemoSeed: false)
        let daykey = Daykey.make(now, calendar: calendar)
        let session = try XCTUnwrap(reloaded.chart.sessions.first { $0.daykey == daykey })
        XCTAssertEqual(session.folio.fold, .leafed)
        XCTAssertEqual(session.folio.current, .breathe)
        XCTAssertNotNil(session.folio.leaf(.reflect)?.mark)
        XCTAssertEqual(reloaded.chart.schemaVersion, 1)
        XCTAssertEqual(reloaded.chart.durations, .canonical)

        defaults.set(Data("not-json".utf8), forKey: FolioChartStore.storageKey)
        let broken = FolioChartStore(defaults: defaults, allowsDemoSeed: false)
        XCTAssertTrue(broken.chart.sessions.isEmpty)
        XCTAssertEqual(broken.chart.durations, .canonical)
        XCTAssertNotNil(broken.recoveryNote)

        await broken.resetAllData()
        XCTAssertNil(defaults.data(forKey: FolioChartStore.storageKey))
        let afterReset = FolioChartStore(defaults: defaults, allowsDemoSeed: false)
        XCTAssertTrue(afterReset.chart.sessions.isEmpty)
        XCTAssertNil(afterReset.recoveryNote)
    }

    func testSchemaVersionSwitchRejectsUnknown() throws {
        let payload = """
        {"schemaVersion":2,"sessions":[],"durations":{"reflect":90,"breathe":120,"ambient":90},"hapticsEnabled":true,"onboardingComplete":false}
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        XCTAssertThrowsError(try decoder.decode(FolioChart.self, from: payload))
    }

    func testSeedOpensBreatheWithReflectBanked() throws {
        let now = Date(timeIntervalSince1970: 1_758_864_000)
        let chart = try FolioChart.simulatorSeed(now: now, calendar: calendar)
        XCTAssertTrue(chart.onboardingComplete)
        XCTAssertEqual(chart.durations.reflect, 90)
        XCTAssertEqual(chart.durations.breathe, 120)
        XCTAssertEqual(chart.durations.ambient, 90)
        let today = Daykey.make(now, calendar: calendar)
        let tonight = try XCTUnwrap(chart.sessions.first { $0.daykey == today })
        XCTAssertEqual(tonight.folio.current, .breathe)
        XCTAssertNotNil(tonight.folio.leaf(.reflect)?.mark)
        XCTAssertNil(tonight.folio.leaf(.breathe)?.mark)
        XCTAssertEqual(tonight.folio.fold, .leafed)
        let rested = chart.sessions.filter { $0.daykey != today && $0.isRested }
        XCTAssertGreaterThanOrEqual(rested.count, 3)
    }
}
