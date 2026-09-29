import Foundation

/// Written when Turn is asked on a leaf that does not yet hold a LeafMark.
/// The page stays put. Turning back over a banked leaf writes nothing.
struct FlutterMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var leaf: LeafKind
    var markedAt: Date
}
