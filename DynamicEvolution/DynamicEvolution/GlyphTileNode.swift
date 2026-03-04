// GlyphTileNode.swift — Glyph Tile UI Component
import SpriteKit

class GlyphTileNode: SKNode {
    private let bgShape: SKShapeNode
    private let iconSprite: SKSpriteNode
    private let tierLabel: SKLabelNode
    let tileSize: CGFloat

    init(tier: GlyphTier, size: CGFloat) {
        tileSize = size
        bgShape = SKShapeNode(rectOf: CGSize(width: size-4, height: size-4), cornerRadius: 10)
        iconSprite = SKSpriteNode(imageNamed: tier.assetName)
        tierLabel = SKLabelNode(text: "Lv\(tier.rawValue)")
        super.init()
        setupVisuals(tier: tier)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupVisuals(tier: GlyphTier) {
        bgShape.fillColor   = UIColor(red:0.1,green:0.1,blue:0.24,alpha:0.95)
        bgShape.strokeColor = tierColor(tier).withAlphaComponent(0.7)
        bgShape.lineWidth   = 1.5
        addChild(bgShape)

        iconSprite.size = CGSize(width: tileSize*0.62, height: tileSize*0.62)
        iconSprite.position = CGPoint(x: 0, y: 4)
        addChild(iconSprite)

        tierLabel.fontName  = "AvenirNext-Bold"
        tierLabel.fontSize  = tileSize * 0.18
        tierLabel.fontColor = tierColor(tier)
        tierLabel.verticalAlignmentMode = .center
        tierLabel.position  = CGPoint(x: 0, y: -(tileSize*0.34))
        addChild(tierLabel)
    }

    func updateTier(_ tier: GlyphTier) {
        iconSprite.texture  = SKTexture(imageNamed: tier.assetName)
        iconSprite.alpha    = 1
        tierLabel.text      = "Lv\(tier.rawValue)"
        tierLabel.alpha     = 1
        tierLabel.fontColor = tierColor(tier)
        bgShape.strokeColor = tierColor(tier).withAlphaComponent(0.7)
    }

    func showAsEmptySlot() {
        iconSprite.alpha    = 0
        tierLabel.text      = "?"
        tierLabel.alpha     = 0.3
        tierLabel.fontColor = UIColor(white: 0.3, alpha: 1)
        bgShape.strokeColor = UIColor(white: 0.2, alpha: 0.5)
        alpha = 1
    }

    func playSpinReveal(finalTier: GlyphTier, delay: TimeInterval) {
        // slot-style: rapid random symbol cycling, then land on final
        let flickCount = 8
        let flickDuration = 0.06
        var actions: [SKAction] = []

        // wait for stagger
        actions.append(SKAction.wait(forDuration: delay))

        // rapid flicker through random tiers
        for _ in 0..<flickCount {
            actions.append(SKAction.run { [weak self] in
                let randomTier = GlyphTier.allCases.randomElement() ?? .seedling
                self?.iconSprite.texture = SKTexture(imageNamed: randomTier.assetName)
                self?.tierLabel.text = "Lv\(randomTier.rawValue)"
                self?.tierLabel.fontColor = self?.tierColor(randomTier) ?? .white
                self?.bgShape.strokeColor = self?.tierColor(randomTier).withAlphaComponent(0.7) ?? .white
            })
            actions.append(SKAction.wait(forDuration: flickDuration))
        }

        // land on final tier with a pop
        actions.append(SKAction.run { [weak self] in
            self?.updateTier(finalTier)
        })
        actions.append(SKAction.scale(to: 1.15, duration: 0.08))
        actions.append(SKAction.scale(to: 1.0, duration: 0.1))

        run(SKAction.sequence(actions))
    }

    func playFusionPop(color: UIColor) {
        let grow    = SKAction.scale(to: 1.3, duration: 0.12)
        let shrink  = SKAction.scale(to: 1.0, duration: 0.14)
        let flash   = SKAction.run { [weak self] in
            self?.bgShape.fillColor = color.withAlphaComponent(0.4)
        }
        let restore = SKAction.run { [weak self] in
            self?.bgShape.fillColor = UIColor(red:0.1,green:0.1,blue:0.24,alpha:0.95)
        }
        run(SKAction.sequence([flash, grow, shrink, restore]))
        spawnGlowParticles(color: color)
    }

    func bgHighlight(color: UIColor) {
        bgShape.strokeColor = color
        bgShape.lineWidth   = 2.5
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.1),
            SKAction.scale(to: 1.0,  duration: 0.1)
        ])
        run(pulse) { [weak self] in
            self?.bgShape.lineWidth = 1.5
        }
    }

    private func spawnGlowParticles(color: UIColor) {
        for _ in 0..<6 {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor   = color
            dot.strokeColor = .clear
            dot.zPosition   = 10
            addChild(dot)
            let angle  = CGFloat.random(in: 0..<(.pi*2))
            let dist   = CGFloat.random(in: 20...40)
            let dx     = cos(angle)*dist; let dy = sin(angle)*dist
            let move   = SKAction.moveBy(x: dx, y: dy, duration: 0.4)
            let fade   = SKAction.fadeOut(withDuration: 0.4)
            dot.run(SKAction.sequence([SKAction.group([move,fade]),
                                       SKAction.removeFromParent()]))
        }
    }

    private func tierColor(_ t: GlyphTier) -> UIColor {
        switch t {
        case .seedling:  return UIColor(red:0.55,green:0.41,blue:0.08,alpha:1)
        case .verdant:   return UIColor(red:0.30,green:0.69,blue:0.31,alpha:1)
        case .sapling:   return UIColor(red:0.18,green:0.49,blue:0.20,alpha:1)
        case .arbor:     return UIColor(red:0.11,green:0.37,blue:0.13,alpha:1)
        case .ancient:   return UIColor(red:1.00,green:0.76,blue:0.03,alpha:1)
        case .mystic:    return UIColor(red:0.42,green:0.11,blue:0.60,alpha:1)
        case .legendary: return UIColor(red:0.90,green:0.32,blue:0.00,alpha:1)
        case .divine:    return UIColor(red:1.00,green:0.90,blue:0.50,alpha:1)
        }
    }
}
