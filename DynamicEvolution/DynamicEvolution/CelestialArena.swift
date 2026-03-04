// CelestialArena.swift — Main Menu Scene
import SpriteKit

// MARK: - CelestialArena

/// The main menu scene displayed at application launch and after returning from gameplay.
/// Houses buttons for all game modes, access to info panels, and ambient particle effects.
class CelestialArena: SKScene {

    // MARK: - UI Node References

    private var questButton:       SKNode!
    private var infiniteButton:    SKNode!
    private var codexButton:       SKNode!
    private var leaderboardButton: SKNode!
    private var settingsButton:    SKNode!

    // MARK: - Layout Helpers

    /// Safe area insets adapted for both iPhone and iPad compatibility mode
    private var safeAreaTop:    CGFloat = 44
    private var safeAreaBottom: CGFloat = 0

    /// Vertical center Y used as the anchor for all main menu buttons
    private var buttonsMidY: CGFloat { size.height * 0.52 }

    /// Computed title box top position, clamped below the settings gear
    private var titleBoxY: CGFloat {
        min(size.height * 0.82, size.height - safeAreaTop - 115)
    }

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        let insets   = view.safeAreaInsets
        safeAreaTop    = max(insets.top, 20)
        safeAreaBottom = insets.bottom

        setupBackground()
        setupTitle()
        setupButtons()
        setupParticles()
        setupAmbientShimmer()
        animateButtonEntrance()
    }

    // MARK: - Background

    /// Build the multi-layer background: image + dark overlay.
    private func setupBackground() {
        let bg       = SKSpriteNode(imageNamed: "bg_main_menu")
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)

        // Semi-transparent dark overlay for text legibility
        let overlay = SKSpriteNode(
            color: UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 0.55),
            size: size
        )
        overlay.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -9
        addChild(overlay)
    }

    /// Add a slow-cycling color shimmer to the background overlay for atmosphere.
    private func setupAmbientShimmer() {
        let shimmer = SKSpriteNode(
            color: UIColor(red: 0.0, green: 0.05, blue: 0.15, alpha: 0.0),
            size: size
        )
        shimmer.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        shimmer.zPosition = -8

        let cycle = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.18, duration: 4.0),
            SKAction.fadeAlpha(to: 0.0,  duration: 4.0)
        ])
        shimmer.run(SKAction.repeatForever(cycle))
        addChild(shimmer)
    }

    // MARK: - Title

    /// Build the complete title section: glow box, DYNAMIC / EVOLUTION labels, and subtitle.
    private func setupTitle() {
        setupTitleGlowBox()
        setupTitleLabels()
        setupSlotSubtitle()
    }

    /// Create the rounded gold glow border behind the title text.
    private func setupTitleGlowBox() {
        let cx    = size.width / 2
        let boxW  = min(size.width * 0.85, 360)
        let boxH: CGFloat = 130
        let glowNode = SKShapeNode(rectOf: CGSize(width: boxW, height: boxH), cornerRadius: 18)
        glowNode.fillColor   = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.08)
        glowNode.strokeColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.35)
        glowNode.lineWidth   = 1.5
        glowNode.position    = CGPoint(x: cx, y: titleBoxY)
        glowNode.zPosition   = 1
        addChild(glowNode)
    }

    /// Place the DYNAMIC and EVOLUTION text labels inside the title box.
    private func setupTitleLabels() {
        let cx = size.width / 2

        // Primary title: "DYNAMIC" with idle pulse animation
        let title      = SKLabelNode(text: "DYNAMIC")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = adaptiveFontSize(base: 42)
        title.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        title.verticalAlignmentMode = .center
        title.position  = CGPoint(x: cx, y: titleBoxY + 28)
        title.zPosition = 2
        addChild(title)

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 1.2),
            SKAction.fadeAlpha(to: 1.0, duration: 1.2)
        ])
        title.run(SKAction.repeatForever(pulse))

        // Secondary title: "EVOLUTION" in cyan
        let sub      = SKLabelNode(text: "EVOLUTION")
        sub.fontName = "AvenirNext-Heavy"
        sub.fontSize = adaptiveFontSize(base: 26)
        sub.fontColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        sub.verticalAlignmentMode = .center
        sub.position  = CGPoint(x: cx, y: titleBoxY - 6)
        sub.zPosition = 2
        addChild(sub)
    }

    /// Add the decorative "✦  S L O T  ✦" subtitle below the main title.
    private func setupSlotSubtitle() {
        let cx          = size.width / 2
        let slotLabel   = SKLabelNode(text: "✦  S L O T  ✦")
        slotLabel.fontName  = "AvenirNext-Medium"
        slotLabel.fontSize  = adaptiveFontSize(base: 14)
        slotLabel.fontColor = UIColor(white: 0.7, alpha: 0.9)
        slotLabel.verticalAlignmentMode = .center
        slotLabel.position  = CGPoint(x: cx, y: titleBoxY - 36)
        slotLabel.zPosition = 2
        addChild(slotLabel)
    }

    // MARK: - Buttons

    /// Build all main menu buttons and the settings gear button.
    private func setupButtons() {
        let cx         = size.width / 2
        let titleBottom = titleBoxY - 65
        let spacing    = buttonSpacing()
        let maxMidY    = titleBottom - spacing * 1.5 - adaptiveButtonHeight() / 2 - 10
        let midY       = min(size.height * 0.52, maxMidY)

        questButton = makeMenuButton(
            title:    "QUEST MODE",
            subtitle: "Level \(NexusVault.savedQuestLevel) · Reach the Target",
            color:    UIColor(red: 1, green: 0.84, blue: 0, alpha: 1),
            position: CGPoint(x: cx, y: midY + spacing * 1.5)
        )

        infiniteButton = makeMenuButton(
            title:    "TIMED BLITZ",
            subtitle: "90s · Score Attack",
            color:    UIColor(red: 0, green: 0.83, blue: 1, alpha: 1),
            position: CGPoint(x: cx, y: midY + spacing * 0.5)
        )

        leaderboardButton = makeMenuButton(
            title:    "LEADERBOARD",
            subtitle: "Top 10 Records",
            color:    UIColor(red: 0.90, green: 0.32, blue: 0, alpha: 1),
            position: CGPoint(x: cx, y: midY - spacing * 0.5)
        )

        codexButton = makeMenuButton(
            title:    "CODEX",
            subtitle: "Symbol Collection",
            color:    UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1),
            position: CGPoint(x: cx, y: midY - spacing * 1.5)
        )

        [questButton!, infiniteButton!, leaderboardButton!, codexButton!].forEach {
            addChild($0)
        }

        setupSettingsButton()
    }

    /// Create and position the gear icon settings button in the top-right corner.
    private func setupSettingsButton() {
        let gearLbl = SKLabelNode(text: "⚙")
        gearLbl.fontSize = adaptiveFontSize(base: 28)
        gearLbl.verticalAlignmentMode   = .center
        gearLbl.horizontalAlignmentMode = .center

        let container      = SKNode()
        container.position = CGPoint(x: size.width - 40, y: size.height - safeAreaTop - 22)
        container.zPosition = 10
        container.name     = "settingsBtn"
        container.addChild(gearLbl)
        addChild(container)
        settingsButton = container
    }

    /// Animate buttons flying in from below with a staggered delay.
    private func animateButtonEntrance() {
        let allButtons: [SKNode] = [questButton, infiniteButton, leaderboardButton, codexButton]
        for (i, btn) in allButtons.enumerated() {
            let originalY = btn.position.y
            btn.position  = CGPoint(x: btn.position.x, y: originalY - 40)
            btn.alpha     = 0
            let delay     = Double(i) * 0.08
            btn.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.moveBy(x: 0, y: 40, duration: 0.35),
                    SKAction.fadeIn(withDuration: 0.35)
                ])
            ]))
        }
    }

    // MARK: - Button Factory

    private func buttonSpacing() -> CGFloat { size.height * 0.115 }

    /// Construct a full-featured menu button with title, subtitle, glow border, and shadow.
    private func makeMenuButton(title: String, subtitle: String,
                                color: UIColor, position: CGPoint) -> SKNode {
        let container      = SKNode()
        container.position = position
        container.zPosition = 5

        let bw: CGFloat = min(size.width * 0.78, 320)
        let bh: CGFloat = adaptiveButtonHeight()

        // Drop shadow behind the button
        let shadow = SKShapeNode(rectOf: CGSize(width: bw + 4, height: bh + 4), cornerRadius: 16)
        shadow.fillColor   = color.withAlphaComponent(0.15)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 2, y: -3)
        shadow.zPosition   = -1
        container.addChild(shadow)

        // Main button background
        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 16)
        bg.fillColor   = UIColor(red: 0.1, green: 0.1, blue: 0.22, alpha: 0.92)
        bg.strokeColor = color.withAlphaComponent(0.8)
        bg.lineWidth   = 1.8
        bg.name        = "btnBg"
        container.addChild(bg)

        // Animated border pulse for visual interest
        let glowPulse = SKAction.sequence([
            SKAction.customAction(withDuration: 1.4) { node, t in
                (node as? SKShapeNode)?.strokeColor =
                    color.withAlphaComponent(0.4 + 0.4 * sin(.pi * Double(t) / 1.4))
            },
            SKAction.wait(forDuration: 0)
        ])
        bg.run(SKAction.repeatForever(glowPulse))

        // Title label
        let lbl      = SKLabelNode(text: title)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: 20)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        lbl.position  = CGPoint(x: 0, y: 10)
        container.addChild(lbl)

        // Subtitle label
        let sub      = SKLabelNode(text: subtitle)
        sub.fontName = "AvenirNext-Regular"
        sub.fontSize = adaptiveFontSize(base: 12)
        sub.fontColor = UIColor(white: 0.65, alpha: 1)
        sub.verticalAlignmentMode = .center
        sub.position  = CGPoint(x: 0, y: -12)
        container.addChild(sub)

        return container
    }

    // MARK: - Particles

    /// Add floating gold sparkle particles that drift upward from the bottom edge.
    private func setupParticles() {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate       = 3
        emitter.particleLifetime        = 6
        emitter.particlePositionRange   = CGVector(dx: size.width, dy: 0)
        emitter.position                = CGPoint(x: size.width / 2, y: 0)
        emitter.particleSpeed           = 40
        emitter.particleSpeedRange      = 30
        emitter.emissionAngle           = .pi / 2
        emitter.emissionAngleRange      = .pi / 6
        emitter.particleAlpha           = 0.7
        emitter.particleAlphaRange      = 0.3
        emitter.particleAlphaSpeed      = -0.1
        emitter.particleScale           = 0.06
        emitter.particleScaleRange      = 0.04
        emitter.particleColor           = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        emitter.particleColorBlendFactor = 1
        emitter.zPosition               = 0
        addChild(emitter)
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
        } else if isIn(infiniteButton) {
            animateTap(infiniteButton) { [weak self] in self?.launchTimedBlitz() }
        } else if isIn(leaderboardButton) {
            animateTap(leaderboardButton) { [weak self] in self?.showLeaderboard() }
        } else if isIn(codexButton) {
            animateTap(codexButton) { [weak self] in self?.showCodex() }
        } else if isIn(settingsButton) {
            animateTap(settingsButton) { [weak self] in self?.showSettings() }
        }
    }

    /// Play a brief scale-down-and-restore tap animation before executing an action.
    private func animateTap(_ node: SKNode, completion: @escaping () -> Void) {
        let shrink  = SKAction.scale(to: 0.93, duration: 0.08)
        let restore = SKAction.scale(to: 1.0,  duration: 0.12)
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

    private func launchTimedBlitz() {
        guard let view = view else { return }
        let scene = VortexBattleground(size: size)
        scene.scaleMode = .aspectFill
        scene.vaultEngine.configureWarpMode(.timedBlitz)
        view.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    // MARK: - Info Panel Presentation

    private func showLeaderboard() {
        let overlay       = PhantomOverlay(size: size, kind: .leaderboard)
        overlay.zPosition = 100
        addChild(overlay)
    }

    private func showCodex() {
        let overlay       = PhantomOverlay(size: size, kind: .codex)
        overlay.zPosition = 100
        addChild(overlay)
    }

    private func showSettings() {
        let overlay       = PhantomOverlay(size: size, kind: .settings)
        overlay.zPosition = 100
        addChild(overlay)
    }

    // MARK: - Adaptive Sizing Helpers

    /// Scale a base font size proportionally to the current screen size.
    private func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(size.width / 390, size.height / 844)
        return base * max(scale, 0.75)
    }

    /// Return an appropriate button height based on the available screen height.
    private func adaptiveButtonHeight() -> CGFloat {
        let h = size.height
        if h > 900 { return 72 }
        if h > 700 { return 64 }
        return 56
    }
}
