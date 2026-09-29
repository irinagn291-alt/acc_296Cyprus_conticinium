import Foundation

/// One civil night stored in the chart. The daykey is the stable identity.
struct RitualSession: Codable, Equatable, Identifiable, Sendable {
    var daykey: Int
    var folio: Folio

    var id: Int { daykey }

    var isRested: Bool { folio.rest != nil && folio.fold == .rested }
}
