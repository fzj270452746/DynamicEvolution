// VortexBattleground+Animations.swift — Visual Effects & Animations
import SpriteKit

// MARK: - VortexBattleground: Animations

extension VortexBattleground {

    // MARK: - Combo Label

    /// Display and then fade out the "COMBO ×N" text above the spin button.
    /// - Parameter combo: The combo count to show.
    func showComboLabel(_ combo: Int) {
        comboLbl.text  = "COMBO ×\(combo)"
        comboLbl.alpha = 0
        comboLbl.setScale(0.5)

        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        let hold = SKAction.wait(forDuration: 0.8)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        comboLbl.run(SKAction.sequence([appear, hold, fade]))
    }

    // MARK: - Score Pop

    /// Spawn a floating "+N" score label that drifts upward and fades out.
    /// - Parameter pts: The point value to display.
    func showScorePop(_ pts: Int) {
        let lbl      = SKLabelNode(text: "+\(pts)")
        lbl.fontName = "AvenirNext-Heavy"
        lbl.fontSize = adaptiveFontSize(base: 28)
        lbl.fontColor = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        lbl.position  = CGPoint(x: size.width / 2, y: gridOriginY)
        lbl.zPosition = 20
        lbl.setScale(0.8)
        addChild(lbl)

        let grow = SKAction.scale(to: 1.1, duration: 0.12)
        let move = SKAction.moveBy(x: 0, y: 65, duration: 0.75)
        let fade = SKAction.fadeOut(withDuration: 0.75)
        lbl.run(SKAction.sequence([
            grow,
            SKAction.group([move, fade]),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - New Apex Flash

    /// Flash the screen and display a banner when a new apex tier is achieved.
    /// - Parameter tier: The newly reached apex tier to celebrate.
    func flashNewApex(tier: GlyphTier) {
        // Full-screen color overlay flash
        let flash = SKSpriteNode(
            color: UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.25),
            size: size
        )
        flash.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.10),
            SKAction.fadeOut(withDuration: 0.45),
            SKAction.removeFromParent()
        ]))

        // "NEW APEX: X!" banner that pops into view then fades
        let banner = SKLabelNode(text: "NEW APEX: \(tier.labelText.uppercased())!")
        banner.fontName  = "AvenirNext-Heavy"
        banner.fontSize  = adaptiveFontSize(base: 24)
        banner.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        banner.position  = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        banner.zPosition = 51
        banner.setScale(0.3)
        addChild(banner)
        banner.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.20),
            SKAction.scale(to: 1.0, duration: 0.10),
            SKAction.wait(forDuration: 0.75),
            SKAction.fadeOut(withDuration: 0.30),
            SKAction.removeFromParent()
        ]))

        // Celebration particle burst at the center of the grid
        spawnCelebrationBurst(
            at: CGPoint(x: size.width / 2, y: gridOriginY),
            color: tier.themeColor,
            count: 18
        )
    }

    // MARK: - Screen Shake

    /// Apply a brief horizontal shake to the scene camera to signal a large combo.
    func shakeScreen() {
        let dx: CGFloat = 8
        let shake = SKAction.sequence([
            SKAction.moveBy(x:  dx,    y: 0, duration: 0.045),
            SKAction.moveBy(x: -dx*2,  y: 0, duration: 0.045),
            SKAction.moveBy(x:  dx*1.5, y: 0, duration: 0.04),
            SKAction.moveBy(x: -dx,    y: 0, duration: 0.04),
            SKAction.moveBy(x:  dx*0.5, y: 0, duration: 0.03),
            SKAction.moveBy(x: 0,      y: 0, duration: 0.03)
        ])
        run(shake)
    }

    // MARK: - Spin Button State

    /// Enable or disable the spin button by adjusting its opacity.
    /// - Parameter enabled: Pass `true` to fully opaque/active, `false` to dimmed/inactive.
    func setSpinButtonEnabled(_ enabled: Bool) {
        let targetAlpha: CGFloat = enabled ? 1.0 : 0.45
        spinButton.run(SKAction.fadeAlpha(to: targetAlpha, duration: 0.15))
    }

    // MARK: - Celebration Particles

    /// Emit a burst of colored dot particles radiating outward from a position.
    /// - Parameters:
    ///   - point: Scene-space origin of the burst.
    ///   - color: Particle tint color.
    ///   - count: Number of particles to emit.
    func spawnCelebrationBurst(at point: CGPoint, color: UIColor, count: Int) {
        for i in 0..<count {
            let size  = CGFloat.random(in: 3...7)
            let dot   = SKShapeNode(circleOfRadius: size)
            dot.fillColor   = color
            dot.strokeColor = .clear
            dot.position    = point
            dot.zPosition   = 55
            addChild(dot)

            let angle  = (CGFloat(i) / CGFloat(count)) * .pi * 2
                         + CGFloat.random(in: -0.2...0.2)
            let dist   = CGFloat.random(in: 50...130)
            let move   = SKAction.moveBy(x: cos(angle) * dist,
                                          y: sin(angle) * dist,
                                          duration: 0.55)
            let fade   = SKAction.fadeOut(withDuration: 0.55)
            let shrink = SKAction.scale(to: 0.15, duration: 0.55)
            move.timingMode = .easeOut
            dot.run(SKAction.sequence([
                SKAction.group([move, fade, shrink]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Timer Warning

    /// Briefly flash the timer label red when the countdown enters the danger zone.
    /// Called from the update loop when time crosses 10 seconds.
    func flashTimerWarning() {
        let flash = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.12),
            SKAction.scale(to: 1.0, duration: 0.12)
        ])
        timerLbl.run(flash)
    }

    // MARK: - Dormant Streak Warning

    /// Show a brief "NO MATCH" warning when several consecutive spins produce no fusions.
    /// Helps the player understand probability mechanics when they have bad luck.
    func showDormantWarning() {
        let lbl      = SKLabelNode(text: "NO MATCH…")
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: 14)
        lbl.fontColor = UIColor(white: 0.55, alpha: 1)
        lbl.position  = CGPoint(x: size.width / 2, y: gridOriginY - tileSize * 2.2)
        lbl.zPosition = 20
        lbl.alpha     = 0
        addChild(lbl)

        lbl.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Single Tile Pulse

    /// Briefly pulse-scale a specific tile node to draw attention to it.
    /// - Parameter index: The flat grid index of the tile to pulse.
    func pulseTile(at index: Int) {
        guard index < tileNodes.count else { return }
        let tile = tileNodes[index]
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.18, duration: 0.10),
            SKAction.scale(to: 1.0,  duration: 0.12)
        ])
        tile.run(pulse)
    }
}
