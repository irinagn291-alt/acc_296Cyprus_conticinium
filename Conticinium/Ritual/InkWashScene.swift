import SpriteKit
import SwiftUI

/// Tactile ink wash behind the current leaf. SpriteKit stays on Ritual only.
final class InkWashScene: SKScene {
    private let heavy = SKShapeNode(ellipseOf: CGSize(width: 180, height: 120))
    private let hair = SKShapeNode(rectOf: CGSize(width: 224, height: 8), cornerRadius: FolioChrome.chipRadius)
    private var reduceMotion = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        let ink = DesignTokens.inkUI
        heavy.fillColor = ink.withAlphaComponent(0.22)
        heavy.strokeColor = ink.withAlphaComponent(0.45)
        heavy.lineWidth = 1
        hair.fillColor = ink.withAlphaComponent(0.55)
        hair.strokeColor = .clear
        addChild(heavy)
        addChild(hair)
        layoutMarks(settled: false, animated: false)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutMarks(settled: false, animated: false)
    }

    func setSettled(_ settled: Bool, reduceMotion: Bool) {
        self.reduceMotion = reduceMotion
        layoutMarks(settled: settled, animated: !reduceMotion)
    }

    private func layoutMarks(settled: Bool, animated: Bool) {
        guard size.width > 1, size.height > 1 else { return }
        let heavyTarget = settled
            ? CGPoint(x: size.width * 0.46, y: size.height * 0.58)
            : CGPoint(x: size.width * 0.78, y: size.height * 0.72)
        let hairTarget = settled
            ? CGPoint(x: size.width * 0.42, y: size.height * 0.42)
            : CGPoint(x: size.width * 0.30, y: size.height * 0.48)
        heavy.zRotation = settled ? -0.08 : 0.35
        if animated {
            heavy.run(SKAction.move(to: heavyTarget, duration: 0.32))
            hair.run(SKAction.move(to: hairTarget, duration: 0.32))
        } else {
            heavy.removeAllActions()
            hair.removeAllActions()
            heavy.position = heavyTarget
            hair.position = hairTarget
        }
    }
}

struct InkWashAccent: UIViewRepresentable {
    var settled: Bool
    var reduceMotion: Bool

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        let scene = InkWashScene(size: view.bounds.size)
        scene.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        guard let scene = uiView.scene as? InkWashScene else { return }
        if scene.size != uiView.bounds.size, uiView.bounds.width > 1 {
            scene.size = uiView.bounds.size
        }
        scene.setSettled(settled, reduceMotion: reduceMotion)
    }
}
