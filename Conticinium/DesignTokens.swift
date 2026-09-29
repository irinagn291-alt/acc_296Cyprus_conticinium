import SwiftUI
import UIKit

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #E7E9EF
    static let bg = Color(red: 0.905882, green: 0.913725, blue: 0.937255)
    static let bgHex = "#E7E9EF"
    /// #F4F3F6
    static let surface = Color(red: 0.956863, green: 0.952941, blue: 0.964706)
    static let surfaceHex = "#F4F3F6"
    /// #141A2A
    static let ink = Color(red: 0.078431, green: 0.101961, blue: 0.164706)
    static let inkHex = "#141A2A"
    /// #4229C2
    static let accent = Color(red: 0.258824, green: 0.160784, blue: 0.760784)
    static let accentHex = "#4229C2"
    /// #4E5974
    static let muted = Color(red: 0.305882, green: 0.349020, blue: 0.454902)
    static let mutedHex = "#4E5974"
    static let fontFamily = "Charter"

    /// Same ink as `ink`, for the one SpriteKit accent.
    static let inkUI = UIColor(red: 0.078431, green: 0.101961, blue: 0.164706, alpha: 1)
}
