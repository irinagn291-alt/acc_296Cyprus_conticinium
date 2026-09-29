import Foundation

/// Proof that Bank seated the current leaf. Ending the beat early still writes this mark.
struct LeafMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var leaf: LeafKind
    var seatedAt: Date
    var elapsed: TimeInterval
    var skipped: Bool
}
