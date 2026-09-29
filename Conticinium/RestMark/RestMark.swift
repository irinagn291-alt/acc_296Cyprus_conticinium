import Foundation

/// Seal for one daykey. Present only after Reflect, Breathe, and Ambient each hold a LeafMark.
struct RestMark: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var daykey: Int
    var sealedAt: Date
}
