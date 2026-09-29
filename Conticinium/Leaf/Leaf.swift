import Foundation

/// One page of tonight's folio. Identity is the leaf kind, never a list index.
enum LeafKind: String, Codable, CaseIterable, Equatable, Sendable {
    case reflect
    case breathe
    case ambient
    case rest

    static let canonical: [LeafKind] = [.reflect, .breathe, .ambient, .rest]

    /// The three leaves that must hold a LeafMark before Rest can seal.
    static let seatedBeforeRest: [LeafKind] = [.reflect, .breathe, .ambient]

    var banksALeafMark: Bool {
        self != .rest
    }
}

/// A leaf in canonical order. A missing mark means the page is still open.
struct Leaf: Codable, Equatable, Identifiable, Sendable {
    var kind: LeafKind
    var mark: LeafMark?

    var id: LeafKind { kind }

    var isBanked: Bool { mark != nil }
}

/// Durations for Reflect, Breathe, and Ambient. Rest has no guided length.
struct LeafDurations: Codable, Equatable, Sendable {
    var reflect: Int
    var breathe: Int
    var ambient: Int

    static let canonical = LeafDurations(reflect: 90, breathe: 120, ambient: 90)

    func seconds(for kind: LeafKind) -> Int {
        switch kind {
        case .reflect: return reflect
        case .breathe: return breathe
        case .ambient: return ambient
        case .rest: return 0
        }
    }
}
