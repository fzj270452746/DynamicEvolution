// GlyphTileNode.swift — Glyph Tile UI Component
import SpriteKit

// MARK: - GlyphTileNode

class GlyphTileNode: SKNode {

    // MARK: - Layers

    private let bgShape: SKShapeNode
    private let iconSprite: SKSpriteNode
    private let tierLabel: SKLabelNode
    private let glowRing: SKShapeNode
    let tileSize: CGFloat

    // MARK: - Init

    init(tier: GlyphTier, size: CGFloat) {
        tileSize   = size
        bgShape    = SKShapeNode(rectOf: CGSize(width: size - 4, height: size - 4), cornerRadius: 12)
        iconSprite = SKSpriteNode(imageNamed: tier.assetName)
        tierLabel  = SKLabelNode(text: "Lv\(tier.rawValue)")
        glowRing   = SKShapeNode(rectOf: CGSize(width: size + 3, height: size + 3), cornerRadius: 14)
        super.init()
        buildVisuals(tier: tier)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Visual Build

    private func buildVisuals(tier: GlyphTier) {
        glowRing.fillColor   = .clear
        glowRing.strokeColor = tierColor(tier).withAlphaComponent(0.15)
        glowRing.lineWidth   = 3.5
        glowRing.zPosition   = -1
        addChild(glowRing)

        bgShape.fillColor   = UIColor(red: 0.08, green: 0.04, blue: 0.22, alpha: 0.96)
        bgShape.strokeColor = tierColor(tier).withAlphaComponent(0.65)
        bgShape.lineWidth   = 1.6
        addChild(bgShape)

        iconSprite.size     = CGSize(width: tileSize * 0.62, height: tileSize * 0.62)
        iconSprite.position = CGPoint(x: 0, y: 4)
        addChild(iconSprite)

        tierLabel.fontName              = "AvenirNext-Bold"
        tierLabel.fontSize              = tileSize * 0.18
        tierLabel.fontColor             = tierColor(tier)
        tierLabel.verticalAlignmentMode = .center
        tierLabel.position              = CGPoint(x: 0, y: -(tileSize * 0.34))
        addChild(tierLabel)
    }

    // MARK: - Updates

    func updateTier(_ tier: GlyphTier) {
        let c = tierColor(tier)
        iconSprite.texture   = SKTexture(imageNamed: tier.assetName)
        iconSprite.alpha     = 1
        tierLabel.text       = "Lv\(tier.rawValue)"
        tierLabel.alpha      = 1
        tierLabel.fontColor  = c
        bgShape.strokeColor  = c.withAlphaComponent(0.65)
        glowRing.strokeColor = c.withAlphaComponent(0.15)
    }

    func showAsEmptySlot() {
        iconSprite.alpha     = 0
        tierLabel.text       = "?"
        tierLabel.alpha      = 0.3
        tierLabel.fontColor  = UIColor(white: 0.25, alpha: 1)
        bgShape.strokeColor  = UIColor(white: 0.18, alpha: 0.5)
        glowRing.strokeColor = .clear
        alpha                = 1
        removeAllActions()
    }

    // MARK: - Spin Reveal

    func playSpinReveal(finalTier: GlyphTier, delay: TimeInterval) {
        let flickCount    = 8
        let flickDuration = 0.06
        var actions: [SKAction] = []

        actions.append(SKAction.wait(forDuration: delay))

        for _ in 0..<flickCount {
            actions.append(SKAction.run { [weak self] in
                let rnd = GlyphTier.allCases.randomElement() ?? .seedling
                self?.iconSprite.texture  = SKTexture(imageNamed: rnd.assetName)
                self?.iconSprite.alpha    = 0.55
                self?.tierLabel.text      = "Lv\(rnd.rawValue)"
                self?.tierLabel.fontColor = self?.tierColor(rnd)
                self?.tierLabel.alpha     = 0.65
            })
            actions.append(SKAction.wait(forDuration: flickDuration))
        }

        actions.append(SKAction.run { [weak self] in
            self?.updateTier(finalTier)
        })
        actions.append(SKAction.scale(to: 1.14, duration: 0.08))
        actions.append(SKAction.scale(to: 1.0,  duration: 0.10))

        run(SKAction.sequence(actions))
    }

    // MARK: - Fusion

    func playFusionPop(color: UIColor) {
        let flash = SKAction.run { [weak self] in
            self?.bgShape.fillColor = color.withAlphaComponent(0.35)
        }
        let grow    = SKAction.scale(to: 1.3, duration: 0.12)
        let shrink  = SKAction.scale(to: 1.0, duration: 0.14)
        let restore = SKAction.run { [weak self] in
            self?.bgShape.fillColor = UIColor(red: 0.08, green: 0.04, blue: 0.22, alpha: 0.96)
        }
        run(SKAction.sequence([flash, grow, shrink, restore]))
        spawnGlowDots(color: color, count: 8)
    }

    func playUpgradeFlash(color: UIColor) {
        let bright = SKAction.run { [weak self] in
            self?.bgShape.fillColor     = color.withAlphaComponent(0.45)
            self?.glowRing.strokeColor  = color.withAlphaComponent(0.65)
            self?.glowRing.lineWidth    = 5
        }
        let wait = SKAction.wait(forDuration: 0.22)
        let dim  = SKAction.run { [weak self] in
            self?.bgShape.fillColor  = UIColor(red: 0.08, green: 0.04, blue: 0.22, alpha: 0.96)
            self?.glowRing.lineWidth = 3.5
        }
        run(SKAction.sequence([bright, wait, dim]))
        spawnGlowDots(color: color, count: 12)
    }

    // MARK: - Highlight

    func bgHighlight(color: UIColor) {
        bgShape.strokeColor = color
        bgShape.lineWidth   = 2.5
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.1),
            SKAction.scale(to: 1.0,  duration: 0.1)
        ])
        run(pulse) { [weak self] in
            self?.bgShape.lineWidth = 1.6
        }
    }

    // MARK: - Idle Animation

    func playIdleBreath(tier: GlyphTier) {
        let c = tierColor(tier)
        let breathe = SKAction.customAction(withDuration: 2.0) { [weak self] _, t in
            let alpha = 0.08 + 0.15 * abs(sin(.pi * Double(t) / 2.0))
            self?.glowRing.strokeColor = c.withAlphaComponent(alpha)
        }
        glowRing.run(SKAction.repeatForever(breathe))
    }

    func stopIdleAnimations() {
        glowRing.removeAllActions()
        glowRing.strokeColor = .clear
    }

    // MARK: - Particles

    private func spawnGlowDots(color: UIColor, count: Int) {
        for i in 0..<count {
            let r   = CGFloat.random(in: 2.0...4.5)
            let dot = SKShapeNode(circleOfRadius: r)
            dot.fillColor   = color
            dot.strokeColor = .clear
            dot.zPosition   = 10
            addChild(dot)

            let angle = (CGFloat(i) / CGFloat(count)) * .pi * 2
                        + CGFloat.random(in: -0.25...0.25)
            let dist  = CGFloat.random(in: 22...48)
            let move  = SKAction.moveBy(x: cos(angle) * dist,
                                         y: sin(angle) * dist,
                                         duration: 0.48)
            let fade   = SKAction.fadeOut(withDuration: 0.48)
            let shrink = SKAction.scale(to: 0.2, duration: 0.48)
            move.timingMode = .easeOut
            dot.run(SKAction.sequence([
                SKAction.group([move, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Tier Color

    private func tierColor(_ t: GlyphTier) -> UIColor { t.themeColor }
}
