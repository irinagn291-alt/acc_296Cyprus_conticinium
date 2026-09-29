import Foundation

/// Bank seats a LeafMark. The guided beat's cue is computed from elapsed time.
/// Skip is allowed: a short elapsed still seats the mark.
enum Bank {
    static func seat(
        leaf: LeafKind,
        elapsed: TimeInterval,
        skipped: Bool,
        now: Date,
        id: UUID = UUID()
    ) -> LeafMark {
        LeafMark(
            id: id,
            leaf: leaf,
            seatedAt: now,
            elapsed: max(elapsed, 0),
            skipped: skipped
        )
    }
}

/// Phase inside a guided beat. Cue(at elapsed) is a pure function of time and duration.
enum BeatCue: String, Codable, Equatable, Sendable {
    case inhale
    case hold
    case exhale
    case settle
}

enum GuidedBeat {
    /// Canonical cue. `duration` is the leaf length (about 90 / 120 / 90 seconds).
    static func cue(at elapsed: TimeInterval, duration: TimeInterval) -> BeatCue {
        let span = duration > 0 ? duration : 1
        let fraction = min(max(elapsed, 0), span) / span
        switch fraction {
        case ..<0.40:
            return .inhale
        case ..<0.55:
            return .hold
        case ..<0.90:
            return .exhale
        default:
            return .settle
        }
    }
}
