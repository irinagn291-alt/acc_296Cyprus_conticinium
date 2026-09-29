import Foundation

/// One night. Views call these methods and never write marks themselves.
struct Folio: Codable, Equatable, Sendable {
    var daykey: Int
    var fold: FolioFold
    var hush: Hush?
    var leaves: [Leaf]
    var current: LeafKind
    var flutters: [FlutterMark]
    var rest: RestMark?

    static func openNight(daykey: Int) -> Folio {
        Folio(
            daykey: daykey,
            fold: .open,
            hush: .waiting,
            leaves: LeafKind.canonical.map { Leaf(kind: $0, mark: nil) },
            current: .reflect,
            flutters: [],
            rest: nil
        )
    }

    var currentLeaf: Leaf? {
        leaves.first { $0.kind == current }
    }

    func leaf(_ kind: LeafKind) -> Leaf? {
        leaves.first { $0.kind == kind }
    }

    var priorLeavesBanked: Bool {
        LeafKind.seatedBeforeRest.allSatisfy { kind in
            leaf(kind)?.isBanked == true
        }
    }

    /// Bank writes a LeafMark on the current leaf and is the only way a leaf becomes seated.
    mutating func bankCurrentLeaf(
        elapsed: TimeInterval,
        skipped: Bool,
        now: Date,
        markID: UUID = UUID()
    ) throws {
        if elapsed < 0 {
            throw FolioRefusal.negativeElapsed
        }
        if fold == .rested {
            throw FolioRefusal.bankAfterRest
        }
        guard current.banksALeafMark else {
            throw FolioRefusal.bankOnRestLeaf
        }
        guard let index = leaves.firstIndex(where: { $0.kind == current }) else {
            throw FolioRefusal.bankOnRestLeaf
        }
        if leaves[index].isBanked {
            throw FolioRefusal.alreadySeated
        }
        leaves[index].mark = Bank.seat(
            leaf: current,
            elapsed: elapsed,
            skipped: skipped,
            now: now,
            id: markID
        )
        hush = nil
        if fold == .open {
            fold = .leafed
        }
    }

    /// Turn advances only when the current leaf holds a LeafMark.
    /// An unmarked Turn writes a FlutterMark and keeps that leaf.
    mutating func turnForward(now: Date, flutterID: UUID = UUID()) -> TurnResult {
        guard fold != .rested else {
            return .held
        }
        guard let index = LeafKind.canonical.firstIndex(of: current) else {
            return .held
        }
        guard leaves[index].isBanked else {
            let flutter = FlutterMark(id: flutterID, leaf: current, markedAt: now)
            flutters.append(flutter)
            return .fluttered(flutter)
        }
        let next = index + 1
        guard next < LeafKind.canonical.count else {
            return .held
        }
        current = LeafKind.canonical[next]
        return .advanced(to: current)
    }

    /// Moving back over an already banked leaf writes nothing.
    mutating func turnBackward() {
        guard fold != .rested else { return }
        guard let index = LeafKind.canonical.firstIndex(of: current), index > 0 else {
            return
        }
        current = LeafKind.canonical[index - 1]
    }

    /// Rest writes a RestMark and folds Leafed to Rested only when the three prior leaves are seated.
    mutating func restTonight(now: Date, markID: UUID = UUID()) throws {
        if fold == .rested {
            throw FolioRefusal.bankAfterRest
        }
        guard priorLeavesBanked else {
            throw FolioRefusal.restTooEarly
        }
        rest = RestMark(id: markID, daykey: daykey, sealedAt: now)
        fold = .rested
        current = .rest
        hush = nil
    }
}

enum Daykey {
    /// YYYYMMDD from `calendar.startOfDay`. DST short and long days stay on the local civil date.
    static func make(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func date(from daykey: Int, calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = daykey / 10_000
        parts.month = (daykey / 100) % 100
        parts.day = daykey % 100
        guard let day = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: day)
    }
}

enum NightStreak {
    /// Counts consecutive daykeys that hold a RestMark, walking backward from the latest sealed night
    /// that is `ending` or the day before it.
    static func count(
        restedDaykeys: Set<Int>,
        ending: Date,
        calendar: Calendar = .current
    ) -> Int {
        var cursor = calendar.startOfDay(for: ending)
        if !restedDaykeys.contains(Daykey.make(cursor, calendar: calendar)) {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return 0
            }
            cursor = previous
        }
        var total = 0
        while restedDaykeys.contains(Daykey.make(cursor, calendar: calendar)) {
            total += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }
        return total
    }
}
