// PhantomOverlay+ResultPanels.swift — Game Result Panels
import SpriteKit

// MARK: - PhantomOverlay: Result Panels

extension PhantomOverlay {

    // MARK: - Quest / Generic Result Panel

    /// Build the win or lose result panel.
    /// - Parameters:
    ///   - won: Whether the player succeeded.
    ///   - score: Final session score.
    ///   - apex: Apex tier label text.
    ///   - questLevel: Quest level number if this is a quest result, otherwise nil.
    func buildResultPanel(won: Bool, score: Int, apex: String, questLevel: Int?) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.82, 340)
        let ph: CGFloat = min(sceneSize.height * 0.52, 420)

        let accentColor = won
            ? UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            : UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)

        // Panel background
        let panel = makePanel(
            width: pw, height: ph,
            position: CGPoint(x: cx, y: cy),
            strokeColor: accentColor.withAlphaComponent(0.9)
        )
        addChild(panel)

        // Outer glow ring
        addChild(buildGlowRing(width: pw + 12, height: ph + 12,
                                at: CGPoint(x: cx, y: cy),
                                color: accentColor.withAlphaComponent(0.18)))

        // Animated result icon (trophy or skull)
        addChild(buildResultIcon(won: won, at: CGPoint(x: cx, y: cy + ph * 0.32)))

        // Title label (victory / level clear / game over)
        let titleText = buildTitleText(won: won, questLevel: questLevel)
        addChild(buildResultTitle(text: titleText,
                                   at: CGPoint(x: cx, y: cy + ph * 0.14),
                                   color: accentColor))

        // Score row
        addChild(buildStatLabel(text: "SCORE  \(score)",
                                 at: CGPoint(x: cx, y: cy - ph * 0.02),
                                 fontSize: 22,
                                 color: UIColor(white: 0.95, alpha: 1)))

        // Apex row
        addChild(buildStatLabel(text: "APEX  \(apex)",
                                 at: CGPoint(x: cx, y: cy - ph * 0.14),
                                 fontSize: 16,
                                 color: UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)))

        // Separator line
        addChild(makeSeparator(width: pw * 0.7,
                                position: CGPoint(x: cx, y: cy - ph * 0.21)))

        // Action buttons
        buildResultButtons(won: won, questLevel: questLevel,
                           cx: cx, cy: cy, ph: ph)
    }

    // MARK: - Result Panel Helpers

    /// Build the leading emoji icon with a bounce-in animation.
    private func buildResultIcon(won: Bool, at position: CGPoint) -> SKLabelNode {
        let icon          = SKLabelNode(text: won ? "🏆" : "💀")
        icon.fontSize     = adaptiveFontSize(base: 52)
        icon.verticalAlignmentMode = .center
        icon.position     = position
        icon.zPosition    = 2
        icon.setScale(0.3)
        icon.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.scale(to: 1.1, duration: 0.20),
            SKAction.scale(to: 1.0, duration: 0.10)
        ]))
        return icon
    }

    /// Compose the correct title string based on mode and outcome.
    private func buildTitleText(won: Bool, questLevel: Int?) -> String {
        if let lvl = questLevel { return "LEVEL \(lvl) CLEAR!" }
        return won ? "VICTORY!" : "GAME OVER"
    }

    /// Build the styled result title label.
    private func buildResultTitle(text: String, at position: CGPoint, color: UIColor) -> SKLabelNode {
        let lbl      = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Heavy"
        lbl.fontSize = adaptiveFontSize(base: 30)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        lbl.position  = position
        lbl.zPosition = 2
        return lbl
    }

    /// Build a generic stat text label.
    private func buildStatLabel(text: String, at position: CGPoint,
                                 fontSize: CGFloat, color: UIColor) -> SKLabelNode {
        let lbl      = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: fontSize)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        lbl.position  = position
        lbl.zPosition = 2
        return lbl
    }

    /// Build an outer glow ring shape behind a panel.
    private func buildGlowRing(width: CGFloat, height: CGFloat,
                                at position: CGPoint, color: UIColor) -> SKShapeNode {
        let ring = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 26)
        ring.fillColor   = .clear
        ring.strokeColor = color
        ring.lineWidth   = 6
        ring.position    = position
        ring.zPosition   = 0
        return ring
    }

    /// Add the appropriate action buttons for the result type.
    private func buildResultButtons(won: Bool, questLevel: Int?,
                                     cx: CGFloat, cy: CGFloat, ph: CGFloat) {
        if let lvl = questLevel {
            // Quest win buttons: Next Level (if available) + Main Menu
            let hasNextLevel = lvl < NexusVault.questConfigs.count
            if hasNextLevel {
                let nextBtn = makeButton(
                    title:    "NEXT LEVEL ▶",
                    color:    UIColor(red: 1, green: 0.84, blue: 0, alpha: 1),
                    position: CGPoint(x: cx, y: cy - ph * 0.28),
                    name:     "nextLevelBtn"
                )
                addChild(nextBtn)
            }
            let menuBtn = makeButton(
                title:    "MAIN MENU",
                color:    UIColor(white: 0.6, alpha: 1),
                position: CGPoint(x: cx, y: cy - ph * 0.40),
                name:     "menuBtn"
            )
            addChild(menuBtn)
        } else {
            // Non-quest result: Play Again + Main Menu
            let retryBtn = makeButton(
                title:    "PLAY AGAIN",
                color:    UIColor(red: 0, green: 0.83, blue: 1, alpha: 1),
                position: CGPoint(x: cx, y: cy - ph * 0.28),
                name:     "retryBtn"
            )
            let menuBtn = makeButton(
                title:    "MAIN MENU",
                color:    UIColor(white: 0.6, alpha: 1),
                position: CGPoint(x: cx, y: cy - ph * 0.40),
                name:     "menuBtn"
            )
            addChild(retryBtn)
            addChild(menuBtn)
        }
    }

    // MARK: - Timed Result Panel

    /// Build the timed blitz session result panel.
    /// - Parameters:
    ///   - score: Final score accumulated during the blitz.
    ///   - apexTier: Label text of the best tier seen on the grid.
    ///   - apexCount: Number of apex-tier symbols at session end.
    func buildTimedResultPanel(score: Int, apexTier: String, apexCount: Int) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.82, 340)
        let ph: CGFloat = min(sceneSize.height * 0.52, 420)

        let accentColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)

        // Panel background
        let panel = makePanel(
            width: pw, height: ph,
            position: CGPoint(x: cx, y: cy),
            strokeColor: accentColor.withAlphaComponent(0.9)
        )
        addChild(panel)

        // Timer icon
        let iconLbl          = SKLabelNode(text: "⏱")
        iconLbl.fontSize     = adaptiveFontSize(base: 48)
        iconLbl.verticalAlignmentMode = .center
        iconLbl.position     = CGPoint(x: cx, y: cy + ph * 0.32)
        iconLbl.zPosition    = 2
        addChild(iconLbl)

        // "TIME'S UP!" title
        let titleLbl          = SKLabelNode(text: "TIME'S UP!")
        titleLbl.fontName     = "AvenirNext-Heavy"
        titleLbl.fontSize     = adaptiveFontSize(base: 28)
        titleLbl.fontColor    = accentColor
        titleLbl.verticalAlignmentMode = .center
        titleLbl.position     = CGPoint(x: cx, y: cy + ph * 0.16)
        titleLbl.zPosition    = 2
        addChild(titleLbl)

        // Score
        let scoreLbl          = SKLabelNode(text: "SCORE  \(score)")
        scoreLbl.fontName     = "AvenirNext-Bold"
        scoreLbl.fontSize     = adaptiveFontSize(base: 22)
        scoreLbl.fontColor    = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        scoreLbl.verticalAlignmentMode = .center
        scoreLbl.position     = CGPoint(x: cx, y: cy + ph * 0.02)
        scoreLbl.zPosition    = 2
        addChild(scoreLbl)

        // Best apex stat
        let apexText          = apexCount > 0 ? "BEST  \(apexCount) × \(apexTier)" : "BEST  —"
        let apexLbl           = SKLabelNode(text: apexText)
        apexLbl.fontName      = "AvenirNext-Medium"
        apexLbl.fontSize      = adaptiveFontSize(base: 16)
        apexLbl.fontColor     = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        apexLbl.verticalAlignmentMode = .center
        apexLbl.position      = CGPoint(x: cx, y: cy - ph * 0.08)
        apexLbl.zPosition     = 2
        addChild(apexLbl)

        // Separator
        addChild(makeSeparator(width: pw * 0.7,
                                position: CGPoint(x: cx, y: cy - ph * 0.17)))

        // Action buttons
        let retryBtn = makeButton(
            title:    "PLAY AGAIN",
            color:    accentColor,
            position: CGPoint(x: cx, y: cy - ph * 0.24),
            name:     "retryBtn"
        )
        let menuBtn = makeButton(
            title:    "MAIN MENU",
            color:    UIColor(white: 0.6, alpha: 1),
            position: CGPoint(x: cx, y: cy - ph * 0.36),
            name:     "menuBtn"
        )
        addChild(retryBtn)
        addChild(menuBtn)
    }
}
