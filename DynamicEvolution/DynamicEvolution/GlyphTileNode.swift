// GlyphTileNode.swift — Glyph Tile UI Component
import SpriteKit

// MARK: - GlyphTileNode

/// A single tile in the 4×4 slot-machine grid.
/// Displays the tier symbol, level label, and background shape.
/// Exposes animation methods for spin reveal, fusion, and highlight effects.
class GlyphTileNode: SKNode {

    // MARK: - Visual Layers

    /// Rounded-rectangle background, colored per tier
    private let bgShape: SKShapeNode

    /// Icon sprite for the tier symbol image
    private let iconSprite: SKSpriteNode

    /// Text label showing "Lv#" or "?" for empty slots
    private let tierLabel: SKLabelNode

    /// Subtle outer glow ring that reflects tier color in idle state
    private let glowRing: SKShapeNode

    /// Tile dimension in points (uniform width and height)
    let tileSize: CGFloat

    // MARK: - Initialization

    init(tier: GlyphTier, size: CGFloat) {
        tileSize   = size
        bgShape    = SKShapeNode(rectOf: CGSize(width: size - 4, height: size - 4), cornerRadius: 10)
        iconSprite = SKSpriteNode(imageNamed: tier.assetName)
        tierLabel  = SKLabelNode(text: "Lv\(tier.rawValue)")
        glowRing   = SKShapeNode(rectOf: CGSize(width: size + 2, height: size + 2), cornerRadius: 12)
        super.init()
        setupVisuals(tier: tier)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Visual Setup

    /// Configure all child nodes with default appearance for a given tier.
    private func setupVisuals(tier: GlyphTier) {
        // Outer glow ring rendered behind all other layers
        glowRing.fillColor   = .clear
        glowRing.strokeColor = tierColor(tier).withAlphaComponent(0.18)
        glowRing.lineWidth   = 3
        glowRing.zPosition   = -1
        addChild(glowRing)

        // Main tile background
        bgShape.fillColor   = UIColor(red: 0.1, green: 0.1, blue: 0.24, alpha: 0.95)
        bgShape.strokeColor = tierColor(tier).withAlphaComponent(0.7)
        bgShape.lineWidth   = 1.5
        addChild(bgShape)

        // Tier symbol icon
        iconSprite.size     = CGSize(width: tileSize * 0.62, height: tileSize * 0.62)
        iconSprite.position = CGPoint(x: 0, y: 4)
        addChild(iconSprite)

        // Level text label below the icon
        tierLabel.fontName              = "AvenirNext-Bold"
        tierLabel.fontSize              = tileSize * 0.18
        tierLabel.fontColor             = tierColor(tier)
        tierLabel.verticalAlignmentMode = .center
        tierLabel.position              = CGPoint(x: 0, y: -(tileSize * 0.34))
        addChild(tierLabel)
    }

    /// Apply tier colors and textures to all existing visual nodes atomically.
    private func applyTierTheme(_ tier: GlyphTier) {
        let color           = tierColor(tier)
        bgShape.strokeColor = color.withAlphaComponent(0.7)
        glowRing.strokeColor = color.withAlphaComponent(0.18)
        tierLabel.fontColor = color
        iconSprite.texture  = SKTexture(imageNamed: tier.assetName)
        iconSprite.alpha    = 1
        tierLabel.text      = "Lv\(tier.rawValue)"
        tierLabel.alpha     = 1
    }

    // MARK: - State Updates

    /// Update tile appearance to reflect a new tier (called after fusion upgrade).
    func updateTier(_ tier: GlyphTier) {
        iconSprite.texture  = SKTexture(imageNamed: tier.assetName)
        iconSprite.alpha    = 1
        tierLabel.text      = "Lv\(tier.rawValue)"
        tierLabel.alpha     = 1
        tierLabel.fontColor = tierColor(tier)
        bgShape.strokeColor = tierColor(tier).withAlphaComponent(0.7)
        glowRing.strokeColor = tierColor(tier).withAlphaComponent(0.18)
    }

    /// Render the tile as an unfilled slot awaiting the next spin.
    func showAsEmptySlot() {
        iconSprite.alpha    = 0
        tierLabel.text      = "?"
        tierLabel.alpha     = 0.3
        tierLabel.fontColor = UIColor(white: 0.3, alpha: 1)
        bgShape.strokeColor = UIColor(white: 0.2, alpha: 0.5)
        glowRing.strokeColor = .clear
        alpha               = 1
        removeAllActions()
    }

    // MARK: - Spin Reveal Animation

    /// Play the slot-machine reveal animation: rapid tier cycling then landing
    /// on the final result with a satisfying pop and scale bounce.
    /// - Parameters:
    ///   - finalTier: The tier this tile will display after the reveal.
    ///   - delay: Stagger delay before the animation begins.
    func playSpinReveal(finalTier: GlyphTier, delay: TimeInterval) {
        let flickCount    = 8
        let flickDuration = 0.06
        var actions: [SKAction] = []

        // Wait for column/row stagger offset
        actions.append(SKAction.wait(forDuration: delay))

        // Rapid flicker through random tiers simulating spinning reels
        for _ in 0..<flickCount {
            actions.append(SKAction.run { [weak self] in
                let randomTier = GlyphTier.allCases.randomElement() ?? .seedling
                self?.iconSprite.texture  = SKTexture(imageNamed: randomTier.assetName)
                self?.iconSprite.alpha    = 1
                self?.tierLabel.text      = "Lv\(randomTier.rawValue)"
                self?.tierLabel.fontColor = self?.tierColor(randomTier) ?? .white
                self?.bgShape.strokeColor = self?.tierColor(randomTier).withAlphaComponent(0.7) ?? .white
                self?.tierLabel.alpha     = 1
            })
            actions.append(SKAction.wait(forDuration: flickDuration))
        }

        // Land on the final tier with scale pop
        actions.append(SKAction.run { [weak self] in
            self?.updateTier(finalTier)
        })
        actions.append(SKAction.scale(to: 1.15, duration: 0.08))
        actions.append(SKAction.scale(to: 1.0,  duration: 0.10))

        run(SKAction.sequence(actions))
    }

    // MARK: - Fusion Animation

    /// Play the pop-and-flash animation on the upgraded base tile after fusion.
    /// - Parameter color: Highlight flash color (typically gold).
    func playFusionPop(color: UIColor) {
        let flash = SKAction.run { [weak self] in
            self?.bgShape.fillColor = color.withAlphaComponent(0.4)
        }
        let grow    = SKAction.scale(to: 1.3, duration: 0.12)
        let shrink  = SKAction.scale(to: 1.0, duration: 0.14)
        let restore = SKAction.run { [weak self] in
            self?.bgShape.fillColor = UIColor(red: 0.1, green: 0.1, blue: 0.24, alpha: 0.95)
        }
        run(SKAction.sequence([flash, grow, shrink, restore]))
        spawnGlowParticles(color: color, count: 8)
    }

    /// Play a stronger flash effect when this tile achieves a new apex tier.
    /// - Parameter color: Flash highlight color.
    func playUpgradeFlash(color: UIColor) {
        let brighten = SKAction.run { [weak self] in
            self?.bgShape.fillColor     = color.withAlphaComponent(0.5)
            self?.glowRing.strokeColor  = color.withAlphaComponent(0.7)
            self?.glowRing.lineWidth    = 5
        }
        let wait = SKAction.wait(forDuration: 0.22)
        let dim  = SKAction.run { [weak self] in
            self?.bgShape.fillColor    = UIColor(red: 0.1, green: 0.1, blue: 0.24, alpha: 0.95)
            self?.glowRing.lineWidth   = 3
        }
        run(SKAction.sequence([brighten, wait, dim]))
        spawnGlowParticles(color: color, count: 12)
    }

    // MARK: - Highlight

    /// Briefly illuminate the tile border to mark it as part of a fusion group.
    /// - Parameter color: The highlight border color.
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

    // MARK: - Idle Animation

    /// Start a subtle breathing glow animation for tiles with content.
    /// Should be called after `playSpinReveal` settles.
    func playIdleBreath(tier: GlyphTier) {
        let color = tierColor(tier)
        let breathe = SKAction.customAction(withDuration: 2.0) { [weak self] _, t in
            let alpha = 0.1 + 0.15 * abs(sin(.pi * Double(t) / 2.0))
            self?.glowRing.strokeColor = color.withAlphaComponent(alpha)
        }
        glowRing.run(SKAction.repeatForever(breathe))
    }

    /// Stop all idle animations and clear the glow ring.
    func stopIdleAnimations() {
        glowRing.removeAllActions()
        glowRing.strokeColor = .clear
    }

    // MARK: - Particle Effects

    /// Spawn outward-flying dot particles for fusion and upgrade feedback.
    /// - Parameters:
    ///   - color: The particle tint color.
    ///   - count: Number of particles to emit.
    private func spawnGlowParticles(color: UIColor, count: Int) {
        for i in 0..<count {
            let radius = CGFloat.random(in: 2.0...4.0)
            let dot    = SKShapeNode(circleOfRadius: radius)
            dot.fillColor   = color
            dot.strokeColor = .clear
            dot.zPosition   = 10
            addChild(dot)

            // Evenly distribute around circle with slight randomization
            let baseAngle = (CGFloat(i) / CGFloat(count)) * .pi * 2
            let angle     = baseAngle + CGFloat.random(in: -0.25...0.25)
            let dist      = CGFloat.random(in: 20...45)
            let move      = SKAction.moveBy(x: cos(angle) * dist,
                                             y: sin(angle) * dist,
                                             duration: 0.45)
            let fade      = SKAction.fadeOut(withDuration: 0.45)
            let shrink    = SKAction.scale(to: 0.2, duration: 0.45)
            move.timingMode = .easeOut
            dot.run(SKAction.sequence([
                SKAction.group([move, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Tier Color

    /// Returns the display color for a given tier.
    /// Values match `GlyphTier.themeColor` but are kept here for
    /// backward compatibility with existing call sites.
    private func tierColor(_ t: GlyphTier) -> UIColor {
        switch t {
        case .seedling:  return UIColor(red: 0.55, green: 0.41, blue: 0.08, alpha: 1)
        case .verdant:   return UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1)
        case .sapling:   return UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1)
        case .arbor:     return UIColor(red: 0.11, green: 0.37, blue: 0.13, alpha: 1)
        case .ancient:   return UIColor(red: 1.00, green: 0.76, blue: 0.03, alpha: 1)
        case .mystic:    return UIColor(red: 0.42, green: 0.11, blue: 0.60, alpha: 1)
        case .legendary: return UIColor(red: 0.90, green: 0.32, blue: 0.00, alpha: 1)
        case .divine:    return UIColor(red: 1.00, green: 0.90, blue: 0.50, alpha: 1)
        }
    }
}
