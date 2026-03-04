// CelestialArena.swift — Main Menu Scene
import SpriteKit

// MARK: - CelestialArena

/// The main menu scene displayed at application launch and after returning from gameplay.
/// Houses buttons for all game modes, access to info panels, and ambient particle effects.
class CelestialArena: SKScene {

    // MARK: - UI Node References

    private var questButton:       SKNode!
    private var dailyButton:       SKNode!
    private var infiniteButton:    SKNode!
    private var codexButton:       SKNode!
    private var leaderboardButton: SKNode!
    private var statsButton:       SKNode!
    private var achieveButton:     SKNode!
    private var settingsButton:    SKNode!

    // MARK: - Layout Helpers

    private var safeAreaTop:    CGFloat = 44
    private var safeAreaBottom: CGFloat = 0

    private var titleBoxY: CGFloat {
        min(size.height * 0.84, size.height - safeAreaTop - 105)
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        let insets     = view.safeAreaInsets
        safeAreaTop    = max(insets.top, 20)
        safeAreaBottom = insets.bottom

        buildBackground()
        buildTitle()
        buildModeButtons()
        buildInfoGrid()
        buildSettingsGear()
        buildTipBanner()
        buildParticleField()
        buildAmbientGlow()
        animateButtonEntrance()
    }

    // MARK: - Background

    private func buildBackground() {
        let bg       = SKSpriteNode(imageNamed: "bg_main_menu")
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)

        let overlay = SKSpriteNode(
            color: UIColor(red: 0.04, green: 0.02, blue: 0.14, alpha: 0.62),
            size: size
        )
        overlay.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -9
        addChild(overlay)
    }

    private func buildAmbientGlow() {
        let glow = SKSpriteNode(
            color: UIColor(red: 0.15, green: 0.0, blue: 0.28, alpha: 0.0),
            size: size
        )
        glow.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        glow.zPosition = -8

        let cycle = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.20, duration: 3.5),
            SKAction.fadeAlpha(to: 0.0,  duration: 3.5)
        ])
        glow.run(SKAction.repeatForever(cycle))
        addChild(glow)
    }

    // MARK: - Title

    private func buildTitle() {
        let cx = size.width / 2

        // Glow box with teal border
        let boxW = min(size.width * 0.88, 370)
        let boxH: CGFloat = 135
        let box = SKShapeNode(rectOf: CGSize(width: boxW, height: boxH), cornerRadius: 20)
        box.fillColor   = UIColor(red: 0, green: 0.90, blue: 0.80, alpha: 0.06)
        box.strokeColor = UIColor(red: 0, green: 0.90, blue: 0.80, alpha: 0.30)
        box.lineWidth   = 1.8
        box.position    = CGPoint(x: cx, y: titleBoxY)
        box.zPosition   = 1
        addChild(box)

        let title      = SKLabelNode(text: "DYNAMIC")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = fs(42)
        title.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        title.verticalAlignmentMode = .center
        title.position  = CGPoint(x: cx, y: titleBoxY + 30)
        title.zPosition = 2
        addChild(title)

        let breathe = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.65, duration: 1.5),
            SKAction.fadeAlpha(to: 1.0,  duration: 1.5)
        ])
        title.run(SKAction.repeatForever(breathe))

        let sub      = SKLabelNode(text: "EVOLUTION")
        sub.fontName = "AvenirNext-Heavy"
        sub.fontSize = fs(25)
        sub.fontColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1)
        sub.verticalAlignmentMode = .center
        sub.position  = CGPoint(x: cx, y: titleBoxY - 4)
        sub.zPosition = 2
        addChild(sub)

        let tag      = SKLabelNode(text: "✦  S L O T  ✦")
        tag.fontName = "AvenirNext-Medium"
        tag.fontSize = fs(13)
        tag.fontColor = UIColor(white: 0.55, alpha: 0.85)
        tag.verticalAlignmentMode = .center
        tag.position  = CGPoint(x: cx, y: titleBoxY - 36)
        tag.zPosition = 2
        addChild(tag)
    }

    // MARK: - Mode Buttons (Top Section)

    private func buildModeButtons() {
        let cx          = size.width / 2
        let topY        = titleBoxY - 100
        let spacing     = modeButtonSpacing()

        let daily       = NexusVault.dailyChallengeForToday()
        let dailySub    = "Target \(daily.count)×\(daily.target.labelText) · \(daily.spins) spins"

        questButton = makeModeButton(
            title: "QUEST MODE",
            subtitle: "Level \(NexusVault.savedQuestLevel) · Reach the Target",
            accent: UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1),
            position: CGPoint(x: cx, y: topY)
        )

        dailyButton = makeModeButton(
            title: "DAILY CHALLENGE",
            subtitle: dailySub,
            accent: UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1),
            position: CGPoint(x: cx, y: topY - spacing)
        )

        infiniteButton = makeModeButton(
            title: "TIMED BLITZ",
            subtitle: "90s · Score Attack",
            accent: UIColor(red: 1, green: 0.55, blue: 0.30, alpha: 1),
            position: CGPoint(x: cx, y: topY - spacing * 2)
        )

        [questButton!, dailyButton!, infiniteButton!].forEach { addChild($0) }
    }

    // MARK: - Info Grid (Bottom Section — 2 × 2)

    private func buildInfoGrid() {
        let cx        = size.width / 2
        let colW      = min(size.width * 0.40, 160)
        let rowH: CGFloat = adaptiveInfoHeight() + 12
        let gapX      = colW / 2 + 8
        let gapY      = rowH / 2 + 4

        let lastModeBottomY = titleBoxY - 100 - modeButtonSpacing() * 2 - adaptiveBtnH() / 2
        let gridTop = lastModeBottomY - 14 - gapY - adaptiveInfoHeight() / 2

        leaderboardButton = makeInfoButton(
            title: "LEADERBOARD",
            icon: "🏅",
            accent: UIColor(red: 1, green: 0.55, blue: 0.30, alpha: 1),
            position: CGPoint(x: cx - gapX, y: gridTop + gapY)
        )

        codexButton = makeInfoButton(
            title: "CODEX",
            icon: "📖",
            accent: UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1),
            position: CGPoint(x: cx + gapX, y: gridTop + gapY)
        )

        achieveButton = makeInfoButton(
            title: "ACHIEVEMENTS",
            icon: "🏆",
            accent: UIColor(red: 1, green: 0.82, blue: 0.25, alpha: 1),
            position: CGPoint(x: cx - gapX, y: gridTop - gapY)
        )

        statsButton = makeInfoButton(
            title: "LIFETIME STATS",
            icon: "📊",
            accent: UIColor(white: 0.85, alpha: 1),
            position: CGPoint(x: cx + gapX, y: gridTop - gapY)
        )

        [leaderboardButton!, codexButton!, achieveButton!, statsButton!].forEach { addChild($0) }
    }

    // MARK: - Settings Gear

    private func buildSettingsGear() {
        let gear = SKLabelNode(text: "⚙")
        gear.fontSize = fs(28)
        gear.verticalAlignmentMode   = .center
        gear.horizontalAlignmentMode = .center
        gear.position = CGPoint(x: size.width - 28, y: size.height - safeAreaTop - 14)
        gear.zPosition = 6
        gear.name = "settingsBtn"
        addChild(gear)
        settingsButton = gear
    }

    // MARK: - Button Factories

    private func modeButtonSpacing() -> CGFloat {
        let h = size.height
        if h > 900 { return 82 }
        if h > 750 { return 72 }
        return 62
    }

    private func adaptiveBtnH() -> CGFloat {
        let h = size.height
        if h > 900 { return 66 }
        if h > 700 { return 58 }
        return 50
    }

    private func adaptiveInfoHeight() -> CGFloat {
        let h = size.height
        if h > 900 { return 60 }
        if h > 700 { return 52 }
        return 46
    }

    private func makeModeButton(title: String, subtitle: String,
                                accent: UIColor, position: CGPoint) -> SKNode {
        let container      = SKNode()
        container.position = position
        container.zPosition = 5

        let bw: CGFloat = min(size.width * 0.82, 330)
        let bh: CGFloat = adaptiveBtnH()

        let shadow = SKShapeNode(rectOf: CGSize(width: bw + 4, height: bh + 4), cornerRadius: bh / 2)
        shadow.fillColor   = accent.withAlphaComponent(0.12)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 2, y: -3)
        shadow.zPosition   = -1
        container.addChild(shadow)

        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: bh / 2)
        bg.fillColor   = UIColor(red: 0.08, green: 0.04, blue: 0.20, alpha: 0.94)
        bg.strokeColor = accent.withAlphaComponent(0.75)
        bg.lineWidth   = 1.6
        bg.name = "btnBg"
        container.addChild(bg)

        let pulse = SKAction.sequence([
            SKAction.customAction(withDuration: 1.6) { node, t in
                (node as? SKShapeNode)?.strokeColor =
                    accent.withAlphaComponent(0.35 + 0.40 * sin(.pi * Double(t) / 1.6))
            },
            SKAction.wait(forDuration: 0)
        ])
        bg.run(SKAction.repeatForever(pulse))

        let lbl      = SKLabelNode(text: title)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = fs(19)
        lbl.fontColor = accent
        lbl.verticalAlignmentMode = .center
        lbl.position  = CGPoint(x: 0, y: 9)
        container.addChild(lbl)

        let subLbl      = SKLabelNode(text: subtitle)
        subLbl.fontName = "AvenirNext-Regular"
        subLbl.fontSize = fs(11)
        subLbl.fontColor = UIColor(white: 0.58, alpha: 1)
        subLbl.verticalAlignmentMode = .center
        subLbl.position  = CGPoint(x: 0, y: -11)
        container.addChild(subLbl)

        return container
    }

    private func makeInfoButton(title: String, icon: String,
                                accent: UIColor, position: CGPoint) -> SKNode {
        let container      = SKNode()
        container.position = position
        container.zPosition = 5

        let bw: CGFloat = min(size.width * 0.40, 155)
        let bh: CGFloat = adaptiveInfoHeight()

        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 14)
        bg.fillColor   = UIColor(red: 0.07, green: 0.04, blue: 0.18, alpha: 0.92)
        bg.strokeColor = accent.withAlphaComponent(0.50)
        bg.lineWidth   = 1.2
        container.addChild(bg)

        let iconLbl = SKLabelNode(text: icon)
        iconLbl.fontSize = fs(18)
        iconLbl.verticalAlignmentMode = .center
        iconLbl.position = CGPoint(x: -bw * 0.30, y: 0)
        container.addChild(iconLbl)

        let lbl      = SKLabelNode(text: title)
        lbl.fontName = "AvenirNext-DemiBold"
        lbl.fontSize = fs(10)
        lbl.fontColor = accent
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .left
        lbl.position = CGPoint(x: -bw * 0.16, y: 0)
        container.addChild(lbl)

        return container
    }

    // MARK: - Tip Banner

    private func buildTipBanner() {
        let cx  = size.width / 2
        let tip = NexusVault.randomTip()

        let bannerY = safeAreaBottom + 30
        let bannerW = size.width - 32
        let bannerH: CGFloat = 40

        let bg = SKShapeNode(rectOf: CGSize(width: bannerW, height: bannerH), cornerRadius: 12)
        bg.fillColor   = UIColor(red: 0.06, green: 0.03, blue: 0.16, alpha: 0.85)
        bg.strokeColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.30)
        bg.lineWidth   = 1
        bg.position    = CGPoint(x: cx, y: bannerY)
        bg.zPosition   = 4
        addChild(bg)

        let cropNode = SKCropNode()
        cropNode.position  = CGPoint(x: cx, y: bannerY)
        cropNode.zPosition = 5

        let maskNode = SKShapeNode(rectOf: CGSize(width: bannerW - 16, height: bannerH))
        maskNode.fillColor = .white
        cropNode.maskNode  = maskNode

        let lbl      = SKLabelNode(text: "💡 \(tip.title): \(tip.body)")
        lbl.fontName = "AvenirNext-Regular"
        lbl.fontSize = fs(10)
        lbl.fontColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.80)
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.numberOfLines = 1
        cropNode.addChild(lbl)
        addChild(cropNode)

        func animateMarqueeIfNeeded(_ label: SKLabelNode, inside width: CGFloat) {
            label.removeAllActions()
            let textW = label.frame.width
            guard textW > width else { return }
            let offset  = (textW - width) / 2 + 20
            let speed: CGFloat = 30
            let dur = TimeInterval(offset * 2 / speed)
            let scroll = SKAction.repeatForever(SKAction.sequence([
                SKAction.moveTo(x: 0, duration: 0),
                SKAction.wait(forDuration: 1.5),
                SKAction.moveTo(x: -offset, duration: dur / 2),
                SKAction.wait(forDuration: 1.5),
                SKAction.moveTo(x: 0, duration: dur / 2)
            ]))
            label.run(scroll, withKey: "marquee")
        }

        animateMarqueeIfNeeded(lbl, inside: bannerW - 16)

        let cycle = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 8.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.run { [weak lbl] in
                guard let lbl = lbl else { return }
                let next = NexusVault.randomTip()
                lbl.text = "💡 \(next.title): \(next.body)"
                lbl.position = .zero
                animateMarqueeIfNeeded(lbl, inside: bannerW - 16)
            },
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        cropNode.run(cycle)
    }

    // MARK: - Particles

    private func buildParticleField() {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate       = 4
        emitter.particleLifetime        = 5.5
        emitter.particlePositionRange   = CGVector(dx: size.width, dy: 0)
        emitter.position                = CGPoint(x: size.width / 2, y: 0)
        emitter.particleSpeed           = 35
        emitter.particleSpeedRange      = 25
        emitter.emissionAngle           = .pi / 2
        emitter.emissionAngleRange      = .pi / 5
        emitter.particleAlpha           = 0.65
        emitter.particleAlphaRange      = 0.25
        emitter.particleAlphaSpeed      = -0.12
        emitter.particleScale           = 0.05
        emitter.particleScaleRange      = 0.04
        emitter.particleColor           = UIColor(red: 0.50, green: 0.25, blue: 1, alpha: 1)
        emitter.particleColorBlendFactor = 1
        emitter.zPosition               = 0
        addChild(emitter)
    }

    // MARK: - Button Entrance Animation

    private func animateButtonEntrance() {
        let allModes: [SKNode]  = [questButton, dailyButton, infiniteButton]
        let allInfos: [SKNode]  = [leaderboardButton, codexButton, achieveButton, statsButton]

        for (i, btn) in allModes.enumerated() {
            let oy    = btn.position.y
            btn.position = CGPoint(x: btn.position.x, y: oy - 35)
            btn.alpha = 0
            btn.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.09),
                SKAction.group([
                    SKAction.moveBy(x: 0, y: 35, duration: 0.32),
                    SKAction.fadeIn(withDuration: 0.32)
                ])
            ]))
        }

        for (i, btn) in allInfos.enumerated() {
            btn.setScale(0.7)
            btn.alpha = 0
            btn.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.30 + Double(i) * 0.07),
                SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.28),
                    SKAction.fadeIn(withDuration: 0.28)
                ])
            ]))
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        func isIn(_ node: SKNode) -> Bool {
            node === hit || hit.inParentHierarchy(node)
        }

        if isIn(questButton) {
            animateTap(questButton) { [weak self] in self?.launchQuestMode() }
        } else if isIn(dailyButton) {
            animateTap(dailyButton) { [weak self] in self?.showDailyChallenge() }
        } else if isIn(infiniteButton) {
            animateTap(infiniteButton) { [weak self] in self?.launchTimedBlitz() }
        } else if isIn(leaderboardButton) {
            animateTap(leaderboardButton) { [weak self] in self?.showLeaderboard() }
        } else if isIn(codexButton) {
            animateTap(codexButton) { [weak self] in self?.showCodex() }
        } else if isIn(achieveButton) {
            animateTap(achieveButton) { [weak self] in self?.showAchievements() }
        } else if isIn(statsButton) {
            animateTap(statsButton) { [weak self] in self?.showLifetimeStats() }
        } else if isIn(settingsButton) {
            animateTap(settingsButton) { [weak self] in self?.showSettings() }
        }
    }

    private func animateTap(_ node: SKNode, completion: @escaping () -> Void) {
        let shrink  = SKAction.scale(to: 0.92, duration: 0.07)
        let restore = SKAction.scale(to: 1.0,  duration: 0.11)
        node.run(SKAction.sequence([shrink, restore, SKAction.run(completion)]))
    }

    // MARK: - Scene Transitions

    private func launchQuestMode() {
        guard let view = view else { return }
        let scene = VortexBattleground(size: size)
        scene.scaleMode = .aspectFill
        scene.vaultEngine.configureWarpMode(.questRun(level: NexusVault.savedQuestLevel))
        view.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func launchDailyChallenge() {
        guard let view = view else { return }
        let scene = VortexBattleground(size: size)
        scene.scaleMode = .aspectFill
        scene.vaultEngine.configureWarpMode(.dailyChallenge(dayStamp: NexusVault.dayStamp()))
        view.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func launchTimedBlitz() {
        guard let view = view else { return }
        let scene = VortexBattleground(size: size)
        scene.scaleMode = .aspectFill
        scene.vaultEngine.configureWarpMode(.timedBlitz)
        view.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    // MARK: - Overlay Presentation

    private func showLeaderboard() {
        let o = PhantomOverlay(size: size, kind: .leaderboard)
        o.zPosition = 100
        addChild(o)
    }

    private func showCodex() {
        let o = PhantomOverlay(size: size, kind: .codex)
        o.zPosition = 100
        addChild(o)
    }

    private func showSettings() {
        let o = PhantomOverlay(size: size, kind: .settings)
        o.zPosition = 100
        addChild(o)
    }

    private func showDailyChallenge() {
        let o = PhantomOverlay(size: size, kind: .dailyChallenge)
        o.zPosition = 100
        o.onStartDaily = { [weak self] in
            self?.launchDailyChallenge()
        }
        addChild(o)
    }

    private func showLifetimeStats() {
        let o = PhantomOverlay(size: size, kind: .lifetimeStats)
        o.zPosition = 100
        addChild(o)
    }

    private func showAchievements() {
        let o = PhantomOverlay(size: size, kind: .achievements)
        o.zPosition = 100
        addChild(o)
    }

    // MARK: - Adaptive Font

    private func fs(_ base: CGFloat) -> CGFloat {
        let scale = min(size.width / 390, size.height / 844)
        return base * max(scale, 0.75)
    }
}
