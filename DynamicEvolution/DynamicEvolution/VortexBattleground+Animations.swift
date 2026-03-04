// VortexBattleground+Animations.swift — Visual Effects & Animations
import SpriteKit

// MARK: - VortexBattleground: Animations

extension VortexBattleground {

    // MARK: - Combo Label

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

    func showScorePop(_ pts: Int) {
        let lbl      = SKLabelNode(text: "+\(pts)")
        lbl.fontName = "AvenirNext-Heavy"
        lbl.fontSize = adaptiveFontSize(base: 28)
        lbl.fontColor = UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)
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

    func flashNewApex(tier: GlyphTier) {
        let flash = SKSpriteNode(
            color: UIColor(red: 0, green: 0.90, blue: 0.80, alpha: 0.20),
            size: size
        )
        flash.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.45, duration: 0.10),
            SKAction.fadeOut(withDuration: 0.45),
            SKAction.removeFromParent()
        ]))

        let banner = SKLabelNode(text: "NEW APEX: \(tier.labelText.uppercased())!")
        banner.fontName  = "AvenirNext-Heavy"
        banner.fontSize  = adaptiveFontSize(base: 24)
        banner.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
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

        spawnCelebrationBurst(
            at: CGPoint(x: size.width / 2, y: gridOriginY),
            color: tier.themeColor,
            count: 18
        )
    }

    // MARK: - Screen Shake

    func shakeScreen() {
        let dx: CGFloat = 8
        let shake = SKAction.sequence([
            SKAction.moveBy(x:  dx,      y: 0, duration: 0.045),
            SKAction.moveBy(x: -dx * 2,  y: 0, duration: 0.045),
            SKAction.moveBy(x:  dx * 1.5, y: 0, duration: 0.04),
            SKAction.moveBy(x: -dx,      y: 0, duration: 0.04),
            SKAction.moveBy(x:  dx * 0.5, y: 0, duration: 0.03),
            SKAction.moveBy(x: 0,        y: 0, duration: 0.03)
        ])
        run(shake)
    }

    // MARK: - Spin Button State

    func setSpinButtonEnabled(_ enabled: Bool) {
        let a: CGFloat = enabled ? 1.0 : 0.40
        spinButton.run(SKAction.fadeAlpha(to: a, duration: 0.15))
    }

    // MARK: - Celebration Particles

    func spawnCelebrationBurst(at point: CGPoint, color: UIColor, count: Int) {
        for i in 0..<count {
            let sz  = CGFloat.random(in: 3...7)
            let dot = SKShapeNode(circleOfRadius: sz)
            dot.fillColor   = color
            dot.strokeColor = .clear
            dot.position    = point
            dot.zPosition   = 55
            addChild(dot)

            let angle = (CGFloat(i) / CGFloat(count)) * .pi * 2
                        + CGFloat.random(in: -0.2...0.2)
            let dist  = CGFloat.random(in: 50...130)
            let move  = SKAction.moveBy(x: cos(angle) * dist,
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

    func flashTimerWarning() {
        let flash = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.12),
            SKAction.scale(to: 1.0, duration: 0.12)
        ])
        timerLbl.run(flash)
    }

    // MARK: - Dormant Warning

    func showDormantWarning() {
        let lbl      = SKLabelNode(text: "NO MATCH…")
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: 14)
        lbl.fontColor = UIColor(white: 0.50, alpha: 1)
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

    // MARK: - Strategy Tip Banner

    func showStrategyTip() {
        let tip = NexusVault.randomTip()
        let lbl      = SKLabelNode(text: "💡 \(tip.title)")
        lbl.fontName = "AvenirNext-DemiBold"
        lbl.fontSize = adaptiveFontSize(base: 12)
        lbl.fontColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.85)
        lbl.position  = CGPoint(x: size.width / 2, y: gridOriginY - tileSize * 2.8)
        lbl.zPosition = 20
        lbl.alpha     = 0
        addChild(lbl)

        lbl.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.wait(forDuration: 2.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Tile Pulse

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
