// PhantomOverlay+InfoPanels.swift — Info & Reference Panels
import SpriteKit

// MARK: - PhantomOverlay: Info Panels

extension PhantomOverlay {

    // MARK: - Leaderboard Panel

    /// Build the top-10 leaderboard panel for timed blitz high scores.
    func buildLeaderboardPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)

        let accentColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)

        // Panel background
        let panel = makePanel(
            width: pw, height: ph,
            position: CGPoint(x: cx, y: cy),
            strokeColor: accentColor.withAlphaComponent(0.8)
        )
        addChild(panel)

        // Panel title
        addChild(makePanelTitle(text: "LEADERBOARD",
                                 at: CGPoint(x: cx, y: cy + ph * 0.42),
                                 color: accentColor))

        // Separator below title
        addChild(makeSeparator(width: pw * 0.8,
                                position: CGPoint(x: cx, y: cy + ph * 0.36)))

        // Load leaderboard data
        let entries = NexusVault.loadLeaderboard()
        let rowH    = ph * 0.075
        let startY  = cy + ph * 0.30

        if entries.isEmpty {
            buildEmptyLeaderboard(at: CGPoint(x: cx, y: cy))
        } else {
            buildLeaderboardRows(entries: entries,
                                  startY: startY,
                                  rowH: rowH,
                                  cx: cx,
                                  pw: pw)
        }

        // Close button
        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.6, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.44),
                             name: "closeBtn"))
    }

    /// Show a centered "No records yet" message when the leaderboard is empty.
    private func buildEmptyLeaderboard(at center: CGPoint) {
        let lbl          = SKLabelNode(text: "No records yet")
        lbl.fontName     = "AvenirNext-Medium"
        lbl.fontSize     = adaptiveFontSize(base: 16)
        lbl.fontColor    = UIColor(white: 0.5, alpha: 1)
        lbl.verticalAlignmentMode = .center
        lbl.position     = center
        lbl.zPosition    = 2
        addChild(lbl)
    }

    /// Render all leaderboard rows with rank medal, score, and apex detail.
    private func buildLeaderboardRows(
        entries: [NexusVault.LeaderboardEntry],
        startY: CGFloat,
        rowH: CGFloat,
        cx: CGFloat,
        pw: CGFloat
    ) {
        for (i, entry) in entries.prefix(10).enumerated() {
            let y = startY - CGFloat(i) * rowH

            // Subtle alternating row background
            if i.isMultiple(of: 2) {
                let rowBg = SKShapeNode(rectOf: CGSize(width: pw - 10, height: rowH - 2))
                rowBg.fillColor   = UIColor(white: 1, alpha: 0.03)
                rowBg.strokeColor = .clear
                rowBg.position    = CGPoint(x: cx, y: y)
                rowBg.zPosition   = 1
                addChild(rowBg)
            }

            // Rank medal or number
            let medals = ["🥇", "🥈", "🥉"]
            let rank   = i < 3 ? medals[i] : "#\(i + 1)"

            let rankLbl = SKLabelNode(text: rank)
            rankLbl.fontName  = "AvenirNext-Bold"
            rankLbl.fontSize  = adaptiveFontSize(base: 14)
            rankLbl.fontColor = i < 3
                ? UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
                : UIColor(white: 0.7, alpha: 1)
            rankLbl.horizontalAlignmentMode = .left
            rankLbl.verticalAlignmentMode   = .center
            rankLbl.position  = CGPoint(x: cx - pw * 0.40, y: y)
            rankLbl.zPosition = 2
            addChild(rankLbl)

            // Score value
            let scoreLbl = SKLabelNode(text: "\(entry.score)")
            scoreLbl.fontName  = "AvenirNext-Heavy"
            scoreLbl.fontSize  = adaptiveFontSize(base: 14)
            scoreLbl.fontColor = UIColor(white: 0.95, alpha: 1)
            scoreLbl.horizontalAlignmentMode = .center
            scoreLbl.verticalAlignmentMode   = .center
            scoreLbl.position  = CGPoint(x: cx - pw * 0.05, y: y)
            scoreLbl.zPosition = 2
            addChild(scoreLbl)

            // Apex tier detail
            let tierName  = GlyphTier(rawValue: entry.apexTier)?.labelText ?? "—"
            let detail    = entry.apexCount > 0 ? "\(entry.apexCount)×\(tierName)" : "—"
            let detailLbl = SKLabelNode(text: detail)
            detailLbl.fontName  = "AvenirNext-Medium"
            detailLbl.fontSize  = adaptiveFontSize(base: 12)
            detailLbl.fontColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 0.9)
            detailLbl.horizontalAlignmentMode = .right
            detailLbl.verticalAlignmentMode   = .center
            detailLbl.position  = CGPoint(x: cx + pw * 0.40, y: y)
            detailLbl.zPosition = 2
            addChild(detailLbl)
        }
    }

    // MARK: - Settings Panel

    /// Build the settings / how-to-play panel.
    func buildSettingsPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)

        // Panel background
        let panel = makePanel(
            width: pw, height: ph,
            position: CGPoint(x: cx, y: cy),
            strokeColor: UIColor(white: 0.5, alpha: 0.8)
        )
        addChild(panel)

        // Panel title
        addChild(makePanelTitle(text: "⚙ SETTINGS",
                                 at: CGPoint(x: cx, y: cy + ph * 0.42),
                                 color: UIColor(white: 0.95, alpha: 1)))

        // Separator
        addChild(makeSeparator(width: pw * 0.8,
                                position: CGPoint(x: cx, y: cy + ph * 0.36)))

        // "HOW TO PLAY" section heading
        addChild(makeSectionHeading(text: "HOW TO PLAY",
                                     at: CGPoint(x: cx, y: cy + ph * 0.30)))

        // Instruction lines
        let instructions: [String] = [
            "Tap SPIN to fill empty slots with symbols.",
            "3 matching symbols fuse into a higher tier.",
            "Fused slots become empty until next SPIN.",
            "",
            "QUEST: Reach the target tier within limited spins.",
            "BLITZ: Score as high as possible in 90 seconds.",
            "",
            "Tiers: Seed → Sprout → Sapling → Tree",
            "→ Ancient → Mystic → Legendary → Divine"
        ]

        let lineH  = ph * 0.048
        let startY = cy + ph * 0.22
        for (i, line) in instructions.enumerated() {
            addChild(buildInstructionLine(
                text: line,
                at: CGPoint(x: cx, y: startY - CGFloat(i) * lineH)
            ))
        }

        // Separator before buttons
        addChild(makeSeparator(width: pw * 0.8,
                                position: CGPoint(x: cx, y: cy - ph * 0.24)))

        // Rate app button
        addChild(makeButton(title: "⭐ RATE THIS APP",
                             color: UIColor(red: 1, green: 0.84, blue: 0, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.30),
                             name: "rateBtn"))

        // Close button
        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.6, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.42),
                             name: "closeBtn"))
    }

    /// Build a single instruction text line with standard styling.
    private func buildInstructionLine(text: String, at position: CGPoint) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontName  = "AvenirNext-Regular"
        lbl.fontSize  = adaptiveFontSize(base: 11)
        lbl.fontColor = UIColor(white: 0.75, alpha: 1)
        lbl.verticalAlignmentMode   = .center
        lbl.horizontalAlignmentMode = .center
        lbl.position  = position
        lbl.zPosition = 2
        return lbl
    }

    // MARK: - Codex Panel

    /// Build the symbol collection reference panel showing all eight tiers.
    func buildCodexPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)

        let accentColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)

        // Panel background
        let panel = makePanel(
            width: pw, height: ph,
            position: CGPoint(x: cx, y: cy),
            strokeColor: accentColor.withAlphaComponent(0.8)
        )
        addChild(panel)

        // Panel title
        addChild(makePanelTitle(text: "CODEX",
                                 at: CGPoint(x: cx, y: cy + ph * 0.42),
                                 color: accentColor))

        // Column headers
        addChild(makeSeparator(width: pw * 0.8,
                                position: CGPoint(x: cx, y: cy + ph * 0.36)))
        addChild(buildCodexColumnHeaders(cx: cx, y: cy + ph * 0.33, pw: pw))
        addChild(makeSeparator(width: pw * 0.8,
                                position: CGPoint(x: cx, y: cy + ph * 0.30)))

        // One row per tier
        let rowH   = ph * 0.09
        let startY = cy + ph * 0.24

        for (i, tier) in GlyphTier.allCases.enumerated() {
            let y = startY - CGFloat(i) * rowH
            buildCodexRow(tier: tier, at: y, cx: cx, pw: pw, rowH: rowH)
        }

        // Close button
        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.6, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.44),
                             name: "closeBtn"))
    }

    /// Build the small column header labels (Symbol / Tier / Base Pts).
    private func buildCodexColumnHeaders(cx: CGFloat, y: CGFloat, pw: CGFloat) -> SKNode {
        let container = SKNode()
        let headers: [(String, CGFloat)] = [
            ("Symbol",   cx - pw * 0.32),
            ("Tier",     cx - pw * 0.06),
            ("Base Pts", cx + pw * 0.35)
        ]
        for (text, x) in headers {
            let lbl      = SKLabelNode(text: text)
            lbl.fontName = "AvenirNext-Medium"
            lbl.fontSize = adaptiveFontSize(base: 10)
            lbl.fontColor = UIColor(white: 0.5, alpha: 1)
            lbl.verticalAlignmentMode   = .center
            lbl.horizontalAlignmentMode = x < cx ? .left : .right
            lbl.position  = CGPoint(x: x, y: y)
            lbl.zPosition = 2
            container.addChild(lbl)
        }
        return container
    }

    /// Build one row in the codex table for a specific tier.
    private func buildCodexRow(tier: GlyphTier, at y: CGFloat,
                                cx: CGFloat, pw: CGFloat, rowH: CGFloat) {
        // Tier symbol icon
        let icon      = SKSpriteNode(imageNamed: tier.assetName)
        icon.size     = CGSize(width: rowH * 0.7, height: rowH * 0.7)
        icon.position = CGPoint(x: cx - pw * 0.32, y: y)
        icon.zPosition = 2
        addChild(icon)

        // Colored tier name
        let nameLbl = SKLabelNode(text: "Lv\(tier.rawValue)  \(tier.labelText)")
        nameLbl.fontName  = "AvenirNext-Bold"
        nameLbl.fontSize  = adaptiveFontSize(base: 15)
        nameLbl.fontColor = tier.themeColor
        nameLbl.horizontalAlignmentMode = .left
        nameLbl.verticalAlignmentMode   = .center
        nameLbl.position  = CGPoint(x: cx - pw * 0.18, y: y)
        nameLbl.zPosition = 2
        addChild(nameLbl)

        // Base score (no combo multiplier)
        let pts      = tier.rawValue * tier.rawValue * 20
        let ptsText  = tier.bonusScore > 0 ? "\(pts)+\(tier.bonusScore)" : "\(pts)"
        let ptsLbl   = SKLabelNode(text: ptsText + "pt")
        ptsLbl.fontName  = "AvenirNext-Medium"
        ptsLbl.fontSize  = adaptiveFontSize(base: 13)
        ptsLbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.9)
        ptsLbl.horizontalAlignmentMode = .right
        ptsLbl.verticalAlignmentMode   = .center
        ptsLbl.position  = CGPoint(x: cx + pw * 0.40, y: y)
        ptsLbl.zPosition = 2
        addChild(ptsLbl)
    }

    // MARK: - Shared Panel Helpers

    /// Create a standardized bold panel title label.
    private func makePanelTitle(text: String, at position: CGPoint,
                                 color: UIColor) -> SKLabelNode {
        let lbl      = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Heavy"
        lbl.fontSize = adaptiveFontSize(base: 24)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        lbl.position  = position
        lbl.zPosition = 2
        return lbl
    }

    /// Create a highlighted section sub-heading inside a panel.
    private func makeSectionHeading(text: String, at position: CGPoint) -> SKLabelNode {
        let lbl      = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: 16)
        lbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        lbl.verticalAlignmentMode = .center
        lbl.position  = position
        lbl.zPosition = 2
        return lbl
    }
}
