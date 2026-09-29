import Foundation

/// The night is a fold over Leaves: Open (Hush), Leafed, or Rested.
enum FolioFold: String, Codable, Equatable, Sendable {
    case open
    case leafed
    case rested
}

/// Why Bank, Turn, or Rest declined. The next successful verb is named by the case.
enum FolioRefusal: Error, Equatable, Sendable {
    case restTooEarly
    case bankAfterRest
    case bankOnRestLeaf
    case negativeElapsed
    case alreadySeated
}

enum TurnResult: Equatable, Sendable {
    case advanced(to: LeafKind)
    case fluttered(FlutterMark)
    case held
}
