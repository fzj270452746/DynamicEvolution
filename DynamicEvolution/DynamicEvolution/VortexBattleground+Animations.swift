// VortexBattleground+Animations.swift — Visual Effects & Animations
import SpriteKit

extension VortexBattleground {

    // MARK: - Animations
    func showComboLabel(_ combo: Int) {
        comboLbl.text  = "COMBO ×\(combo)"
        comboLbl.alpha = 0; comboLbl.setScale(0.5)
        let appear = SKAction.group([SKAction.fadeIn(withDuration: 0.15),
                                     SKAction.scale(to: 1.0, duration: 0.15)])
        let hold   = SKAction.wait(forDuration: 0.8)
        let fade   = SKAction.fadeOut(withDuration: 0.3)
        comboLbl.run(SKAction.sequence([appear, hold, fade]))
    }

    func showScorePop(_ pts: Int) {
        let lbl = SKLabelNode(text: "+\(pts)")
        lbl.fontName  = "AvenirNext-Heavy"
        lbl.fontSize  = adaptiveFontSize(base: 28)
        lbl.fontColor = UIColor(red:0.22,green:1,blue:0.08,alpha:1)
        lbl.position  = CGPoint(x: size.width/2, y: gridOriginY)
        lbl.zPosition = 20
        addChild(lbl)
        let move = SKAction.moveBy(x: 0, y: 60, duration: 0.7)
        let fade = SKAction.fadeOut(withDuration: 0.7)
        lbl.run(SKAction.sequence([SKAction.group([move,fade]),
                                   SKAction.removeFromParent()]))
    }

    func flashNewApex(tier: GlyphTier) {
        let flash = SKSpriteNode(color: UIColor(red:1,green:0.84,blue:0,alpha:0.25), size: size)
        flash.position  = CGPoint(x: size.width/2, y: size.height/2)
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))

        let banner = SKLabelNode(text: "NEW APEX: \(tier.labelText.uppercased())!")
        banner.fontName  = "AvenirNext-Heavy"
        banner.fontSize  = adaptiveFontSize(base: 24)
        banner.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        banner.position  = CGPoint(x: size.width/2, y: size.height/2 + 20)
        banner.zPosition = 51
        addChild(banner)
        banner.setScale(0.3)
        banner.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1),
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    func shakeScreen() {
        let dx: CGFloat = 8
        let shake = SKAction.sequence([
            SKAction.moveBy(x: dx,  y: 0, duration: 0.05),
            SKAction.moveBy(x: -dx*2, y: 0, duration: 0.05),
            SKAction.moveBy(x: dx,  y: 0, duration: 0.05),
            SKAction.moveBy(x: 0,   y: 0, duration: 0.05)
        ])
        run(shake)
    }

    func setSpinButtonEnabled(_ enabled: Bool) {
        spinButton.alpha = enabled ? 1.0 : 0.45
    }
}
