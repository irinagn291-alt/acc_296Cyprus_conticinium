import Foundation

/// Quiet case of an Open folio. Present until the first Bank folds the night to Leafed.
struct Hush: Codable, Equatable, Sendable {
    var seated: Bool

    static let waiting = Hush(seated: false)
}
