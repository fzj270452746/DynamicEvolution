// PhantomOverlay+ResultPanels.swift — Game Result Panels
import SpriteKit

// MARK: - PhantomOverlay: Result Panels

extension PhantomOverlay {

    // MARK: - Quest / Generic Result

    func buildResultPanel(won: Bool, score: Int, apex: String, questLevel: Int?) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.82, 340)
        let ph: CGFloat = min(sceneSize.height * 0.52, 420)

        let accent = won
            ? UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
            : UIColor(red: 1, green: 0.37, blue: 0.42, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.85)))

        // Glow ring
        let ring = SKShapeNode(rectOf: CGSize(width: pw + 12, height: ph + 12), cornerRadius: 28)
        ring.fillColor   = .clear
        ring.strokeColor = accent.withAlphaComponent(0.15)
        ring.lineWidth   = 6
        ring.position    = CGPoint(x: cx, y: cy)
        ring.zPosition   = 0
        addChild(ring)

        // Icon
        let icon      = SKLabelNode(text: won ? "🏆" : "💀")
        icon.fontSize = adaptiveFontSize(base: 52)
        icon.verticalAlignmentMode = .center
        icon.position  = CGPoint(x: cx, y: cy + ph * 0.32)
        icon.zPosition = 2
        icon.setScale(0.3)
        icon.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.scale(to: 1.1, duration: 0.20),
            SKAction.scale(to: 1.0, duration: 0.10)
        ]))
        addChild(icon)

        // Title
        let titleStr: String
        if let lvl = questLevel { titleStr = "LEVEL \(lvl) CLEAR!" }
        else { titleStr = won ? "VICTORY!" : "GAME OVER" }

        let title      = SKLabelNode(text: titleStr)
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = adaptiveFontSize(base: 30)
        title.fontColor = accent
        title.verticalAlignmentMode = .center
        title.position  = CGPoint(x: cx, y: cy + ph * 0.14)
        title.zPosition = 2
        addChild(title)

        // Score
        let sLbl      = SKLabelNode(text: "SCORE  \(score)")
        sLbl.fontName = "AvenirNext-Bold"
        sLbl.fontSize = adaptiveFontSize(base: 22)
        sLbl.fontColor = UIColor(white: 0.95, alpha: 1)
        sLbl.verticalAlignmentMode = .center
        sLbl.position  = CGPoint(x: cx, y: cy - ph * 0.02)
        sLbl.zPosition = 2
        addChild(sLbl)

        // Apex
        let aLbl      = SKLabelNode(text: "APEX  \(apex)")
        aLbl.fontName = "AvenirNext-Bold"
        aLbl.fontSize = adaptiveFontSize(base: 16)
        aLbl.fontColor = UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)
        aLbl.verticalAlignmentMode = .center
        aLbl.position  = CGPoint(x: cx, y: cy - ph * 0.14)
        aLbl.zPosition = 2
        addChild(aLbl)

        addChild(makeSeparator(width: pw * 0.7,
                               position: CGPoint(x: cx, y: cy - ph * 0.21)))

        buildResultButtons(won: won, questLevel: questLevel,
                           cx: cx, cy: cy, ph: ph)
    }

    private func buildResultButtons(won: Bool, questLevel: Int?,
                                    cx: CGFloat, cy: CGFloat, ph: CGFloat) {
        if let lvl = questLevel {
            if lvl < NexusVault.questConfigs.count {
                addChild(makeButton(
                    title: "NEXT LEVEL ▶",
                    color: UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1),
                    position: CGPoint(x: cx, y: cy - ph * 0.28),
                    name: "nextLevelBtn"))
            }
            addChild(makeButton(
                title: "MAIN MENU",
                color: UIColor(white: 0.55, alpha: 1),
                position: CGPoint(x: cx, y: cy - ph * 0.40),
                name: "menuBtn"))
        } else {
            addChild(makeButton(
                title: "PLAY AGAIN",
                color: UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1),
                position: CGPoint(x: cx, y: cy - ph * 0.28),
                name: "retryBtn"))
            addChild(makeButton(
                title: "MAIN MENU",
                color: UIColor(white: 0.55, alpha: 1),
                position: CGPoint(x: cx, y: cy - ph * 0.40),
                name: "menuBtn"))
        }
    }

    // MARK: - Timed Result

    func buildTimedResultPanel(score: Int, apexTier: String, apexCount: Int) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.82, 340)
        let ph: CGFloat = min(sceneSize.height * 0.52, 420)
        let accent = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.85)))

        let icon = SKLabelNode(text: "⏱")
        icon.fontSize = adaptiveFontSize(base: 48)
        icon.verticalAlignmentMode = .center
        icon.position  = CGPoint(x: cx, y: cy + ph * 0.32)
        icon.zPosition = 2
        addChild(icon)

        let title = SKLabelNode(text: "TIME'S UP!")
        title.fontName  = "AvenirNext-Heavy"
        title.fontSize  = adaptiveFontSize(base: 28)
        title.fontColor = accent
        title.verticalAlignmentMode = .center
        title.position  = CGPoint(x: cx, y: cy + ph * 0.16)
        title.zPosition = 2
        addChild(title)

        let sLbl = SKLabelNode(text: "SCORE  \(score)")
        sLbl.fontName  = "AvenirNext-Bold"
        sLbl.fontSize  = adaptiveFontSize(base: 22)
        sLbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        sLbl.verticalAlignmentMode = .center
        sLbl.position  = CGPoint(x: cx, y: cy + ph * 0.02)
        sLbl.zPosition = 2
        addChild(sLbl)

        let apexText = apexCount > 0 ? "BEST  \(apexCount) × \(apexTier)" : "BEST  —"
        let aLbl = SKLabelNode(text: apexText)
        aLbl.fontName  = "AvenirNext-Medium"
        aLbl.fontSize  = adaptiveFontSize(base: 16)
        aLbl.fontColor = UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)
        aLbl.verticalAlignmentMode = .center
        aLbl.position  = CGPoint(x: cx, y: cy - ph * 0.08)
        aLbl.zPosition = 2
        addChild(aLbl)

        addChild(makeSeparator(width: pw * 0.7,
                               position: CGPoint(x: cx, y: cy - ph * 0.17)))

        addChild(makeButton(title: "PLAY AGAIN", color: accent,
                             position: CGPoint(x: cx, y: cy - ph * 0.24),
                             name: "retryBtn"))
        addChild(makeButton(title: "MAIN MENU",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.36),
                             name: "menuBtn"))
    }

    // MARK: - Daily Result

    func buildDailyResultPanel(score: Int, apex: String, won: Bool,
                               target: String, best: Int, streak: Int,
                               dayLabel: String) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.86, 350)
        let ph: CGFloat = min(sceneSize.height * 0.58, 460)

        let accent = won
            ? UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1)
            : UIColor(red: 1, green: 0.45, blue: 0.30, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.85)))

        let title = SKLabelNode(text: won ? "DAILY CLEARED" : "DAILY FAILED")
        title.fontName  = "AvenirNext-Heavy"
        title.fontSize  = adaptiveFontSize(base: 26)
        title.fontColor = accent
        title.verticalAlignmentMode = .center
        title.position  = CGPoint(x: cx, y: cy + ph * 0.36)
        title.zPosition = 2
        addChild(title)

        let dl = SKLabelNode(text: dayLabel)
        dl.fontName  = "AvenirNext-Medium"
        dl.fontSize  = adaptiveFontSize(base: 12)
        dl.fontColor = UIColor(white: 0.62, alpha: 1)
        dl.verticalAlignmentMode = .center
        dl.position  = CGPoint(x: cx, y: cy + ph * 0.27)
        dl.zPosition = 2
        addChild(dl)

        addChild(makeSeparator(width: pw * 0.7,
                               position: CGPoint(x: cx, y: cy + ph * 0.22)))

        let rows = [
            ("TARGET",     target),
            ("SCORE",      "\(score)"),
            ("APEX",       apex),
            ("BEST TODAY", "\(best)"),
            ("WIN STREAK", "\(streak)")
        ]

        let startY = cy + ph * 0.10
        let rowH   = ph * 0.10
        for (idx, row) in rows.enumerated() {
            let y = startY - CGFloat(idx) * rowH
            addChild(makeStatRow(label: row.0, value: row.1, y: y,
                                 labelColor: UIColor(white: 0.62, alpha: 1),
                                 valueColor: UIColor(white: 0.95, alpha: 1),
                                 panelWidth: pw))
        }

        addChild(makeSeparator(width: pw * 0.7,
                               position: CGPoint(x: cx, y: cy - ph * 0.18)))

        addChild(makeButton(title: "MAIN MENU",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.32),
                             name: "menuBtn"))
    }
}
