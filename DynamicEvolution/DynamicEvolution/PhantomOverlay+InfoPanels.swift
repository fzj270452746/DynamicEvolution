// PhantomOverlay+InfoPanels.swift — Info & Reference Panels
import SpriteKit

// MARK: - PhantomOverlay: Info Panels

extension PhantomOverlay {

    // MARK: - Leaderboard

    func buildLeaderboardPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)
        let accent = UIColor(red: 1, green: 0.55, blue: 0.30, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.75)))

        addChild(makePanelTitle(text: "LEADERBOARD",
                                at: CGPoint(x: cx, y: cy + ph * 0.42),
                                color: accent))

        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: cy + ph * 0.36)))

        let entries = NexusVault.loadLeaderboard()
        let rowH    = ph * 0.075
        let startY  = cy + ph * 0.30

        if entries.isEmpty {
            let e = SKLabelNode(text: "No records yet")
            e.fontName  = "AvenirNext-Medium"
            e.fontSize  = adaptiveFontSize(base: 16)
            e.fontColor = UIColor(white: 0.45, alpha: 1)
            e.verticalAlignmentMode = .center
            e.position  = CGPoint(x: cx, y: cy)
            e.zPosition = 2
            addChild(e)
        } else {
            buildLeaderRows(entries: entries, startY: startY,
                            rowH: rowH, cx: cx, pw: pw)
        }

        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.44),
                             name: "closeBtn"))
    }

    private func buildLeaderRows(entries: [NexusVault.LeaderboardEntry],
                                 startY: CGFloat, rowH: CGFloat,
                                 cx: CGFloat, pw: CGFloat) {
        for (i, entry) in entries.prefix(10).enumerated() {
            let y = startY - CGFloat(i) * rowH

            if i.isMultiple(of: 2) {
                let bg = SKShapeNode(rectOf: CGSize(width: pw - 10, height: rowH - 2))
                bg.fillColor   = UIColor(white: 1, alpha: 0.03)
                bg.strokeColor = .clear
                bg.position    = CGPoint(x: cx, y: y)
                bg.zPosition   = 1
                addChild(bg)
            }

            let medals = ["🥇", "🥈", "🥉"]
            let rank   = i < 3 ? medals[i] : "#\(i + 1)"
            let rLbl   = SKLabelNode(text: rank)
            rLbl.fontName  = "AvenirNext-Bold"
            rLbl.fontSize  = adaptiveFontSize(base: 14)
            rLbl.fontColor = i < 3
                ? UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
                : UIColor(white: 0.65, alpha: 1)
            rLbl.horizontalAlignmentMode = .left
            rLbl.verticalAlignmentMode   = .center
            rLbl.position  = CGPoint(x: cx - pw * 0.40, y: y)
            rLbl.zPosition = 2
            addChild(rLbl)

            let sLbl = SKLabelNode(text: "\(entry.score)")
            sLbl.fontName  = "AvenirNext-Heavy"
            sLbl.fontSize  = adaptiveFontSize(base: 14)
            sLbl.fontColor = UIColor(white: 0.95, alpha: 1)
            sLbl.horizontalAlignmentMode = .center
            sLbl.verticalAlignmentMode   = .center
            sLbl.position  = CGPoint(x: cx - pw * 0.05, y: y)
            sLbl.zPosition = 2
            addChild(sLbl)

            let tierName = GlyphTier(rawValue: entry.apexTier)?.labelText ?? "—"
            let detail   = entry.apexCount > 0 ? "\(entry.apexCount)×\(tierName)" : "—"
            let dLbl     = SKLabelNode(text: detail)
            dLbl.fontName  = "AvenirNext-Medium"
            dLbl.fontSize  = adaptiveFontSize(base: 12)
            dLbl.fontColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.9)
            dLbl.horizontalAlignmentMode = .right
            dLbl.verticalAlignmentMode   = .center
            dLbl.position  = CGPoint(x: cx + pw * 0.40, y: y)
            dLbl.zPosition = 2
            addChild(dLbl)
        }
    }

    // MARK: - Settings

    func buildSettingsPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.82, 660)
        let sectionGap: CGFloat = ph * 0.03

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: UIColor(white: 0.45, alpha: 0.75)))

        // --- Top-down cursor layout ---
        var y = cy + ph * 0.43

        addChild(makePanelTitle(text: "⚙ SETTINGS",
                                at: CGPoint(x: cx, y: y),
                                color: UIColor(white: 0.92, alpha: 1)))

        y -= sectionGap * 2
        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: y)))

        y -= sectionGap * 1.5
        addChild(makeSectionHeading(text: "HOW TO PLAY",
                                    at: CGPoint(x: cx, y: y)))

        let lines: [String] = [
            "Tap SPIN to fill empty slots with symbols.",
            "3 matching symbols fuse into a higher tier.",
            "Fused slots become empty until next SPIN.",
            "",
            "QUEST: Reach the target tier within limited spins.",
            "DAILY: Beat the daily target in a fixed budget.",
            "BLITZ: Score as high as possible in 90 seconds.",
            "",
            "Tiers: Seed → Sprout → Sapling → Tree",
            "→ Ancient → Mystic → Legendary → Divine"
        ]

        y -= sectionGap * 1.5
        let lineH = ph * 0.036
        for (i, line) in lines.enumerated() {
            let ly = y - CGFloat(i) * lineH
            let lbl      = SKLabelNode(text: line)
            lbl.fontName = "AvenirNext-Regular"
            lbl.fontSize = adaptiveFontSize(base: 11)
            lbl.fontColor = UIColor(white: 0.70, alpha: 1)
            lbl.verticalAlignmentMode   = .center
            lbl.horizontalAlignmentMode = .center
            lbl.position  = CGPoint(x: cx, y: ly)
            lbl.zPosition = 2
            addChild(lbl)
        }
        y -= CGFloat(lines.count - 1) * lineH

        y -= sectionGap * 1.2
        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: y)))

        y -= sectionGap * 1.5
        addChild(makeSectionHeading(text: "STRATEGY TIP",
                                    at: CGPoint(x: cx, y: y)))

        y -= sectionGap * 1.2
        let tip = NexusVault.randomTip()
        let tipLbl      = SKLabelNode(text: "💡 \(tip.title): \(tip.body)")
        tipLbl.fontName = "AvenirNext-Regular"
        tipLbl.fontSize = adaptiveFontSize(base: 10)
        tipLbl.fontColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.9)
        tipLbl.numberOfLines = 0
        tipLbl.preferredMaxLayoutWidth = pw * 0.8
        tipLbl.verticalAlignmentMode   = .top
        tipLbl.horizontalAlignmentMode = .center
        tipLbl.position  = CGPoint(x: cx, y: y)
        tipLbl.zPosition = 2
        addChild(tipLbl)

        // --- Bottom-up: buttons anchored to panel bottom ---
        let closeY = cy - ph * 0.43
        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: closeY),
                             name: "closeBtn"))

        let rateY = closeY + sectionGap * 3
        addChild(makeButton(title: "⭐ RATE THIS APP",
                             color: UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1),
                             position: CGPoint(x: cx, y: rateY),
                             name: "rateBtn"))

        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: rateY + sectionGap * 2)))
    }

    // MARK: - Codex

    func buildCodexPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.82, 660)
        let accent = UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.75)))

        addChild(makePanelTitle(text: "CODEX",
                                at: CGPoint(x: cx, y: cy + ph * 0.42),
                                color: accent))

        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: cy + ph * 0.36)))
        addChild(buildCodexHeaders(cx: cx, y: cy + ph * 0.33, pw: pw))
        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: cy + ph * 0.30)))

        let closeY = cy - ph * 0.44
        let startY = cy + ph * 0.24
        let buttonClearance: CGFloat = 34
        let tiers = GlyphTier.allCases
        let availableH = startY - (closeY + buttonClearance)
        let rowH = tiers.isEmpty ? 0 : availableH / CGFloat(tiers.count)

        for (i, tier) in tiers.enumerated() {
            let y = startY - CGFloat(i) * rowH
            buildCodexRow(tier: tier, at: y, cx: cx, pw: pw, rowH: rowH)
        }

        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: closeY),
                             name: "closeBtn"))
    }

    private func buildCodexHeaders(cx: CGFloat, y: CGFloat, pw: CGFloat) -> SKNode {
        let c = SKNode()
        let items: [(String, CGFloat)] = [
            ("Symbol", cx - pw * 0.32),
            ("Tier",   cx - pw * 0.06),
            ("Base Pts", cx + pw * 0.35)
        ]
        for (text, x) in items {
            let lbl      = SKLabelNode(text: text)
            lbl.fontName = "AvenirNext-Medium"
            lbl.fontSize = adaptiveFontSize(base: 10)
            lbl.fontColor = UIColor(white: 0.45, alpha: 1)
            lbl.verticalAlignmentMode   = .center
            lbl.horizontalAlignmentMode = x < cx ? .left : .right
            lbl.position  = CGPoint(x: x, y: y)
            lbl.zPosition = 2
            c.addChild(lbl)
        }
        return c
    }

    private func buildCodexRow(tier: GlyphTier, at y: CGFloat,
                               cx: CGFloat, pw: CGFloat, rowH: CGFloat) {
        let icon      = SKSpriteNode(imageNamed: tier.assetName)
        icon.size     = CGSize(width: rowH * 0.7, height: rowH * 0.7)
        icon.position = CGPoint(x: cx - pw * 0.32, y: y)
        icon.zPosition = 2
        addChild(icon)

        let name = SKLabelNode(text: "Lv\(tier.rawValue)  \(tier.labelText)")
        name.fontName  = "AvenirNext-Bold"
        name.fontSize  = adaptiveFontSize(base: 15)
        name.fontColor = tier.themeColor
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode   = .center
        name.position  = CGPoint(x: cx - pw * 0.18, y: y)
        name.zPosition = 2
        addChild(name)

        let pts     = tier.rawValue * tier.rawValue * 20
        let ptsText = tier.bonusScore > 0 ? "\(pts)+\(tier.bonusScore)" : "\(pts)"
        let ptsLbl  = SKLabelNode(text: ptsText + "pt")
        ptsLbl.fontName  = "AvenirNext-Medium"
        ptsLbl.fontSize  = adaptiveFontSize(base: 13)
        ptsLbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 0.9)
        ptsLbl.horizontalAlignmentMode = .right
        ptsLbl.verticalAlignmentMode   = .center
        ptsLbl.position  = CGPoint(x: cx + pw * 0.40, y: y)
        ptsLbl.zPosition = 2
        addChild(ptsLbl)
    }

    // MARK: - Daily Challenge Intro

    func buildDailyChallengePanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.86, 350)
        let ph: CGFloat = min(sceneSize.height * 0.62, 500)
        let accent = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.80)))

        addChild(makePanelTitle(text: "DAILY CHALLENGE",
                                at: CGPoint(x: cx, y: cy + ph * 0.40),
                                color: accent))

        let config   = NexusVault.dailyChallengeForToday()
        let dayLabel = NexusVault.dailyLabel(for: config.dayStamp)

        let sub = SKLabelNode(text: dayLabel)
        sub.fontName  = "AvenirNext-Medium"
        sub.fontSize  = adaptiveFontSize(base: 12)
        sub.fontColor = UIColor(white: 0.62, alpha: 1)
        sub.verticalAlignmentMode = .center
        sub.position  = CGPoint(x: cx, y: cy + ph * 0.32)
        sub.zPosition = 2
        addChild(sub)

        addChild(makeSeparator(width: pw * 0.7,
                               position: CGPoint(x: cx, y: cy + ph * 0.26)))

        let rows: [(String, String)] = [
            ("TARGET",     "\(config.count)×\(config.target.labelText)"),
            ("SPIN LIMIT", "\(config.spins)"),
            ("SEED",       "\(config.seed)"),
            ("BEST TODAY", "\(NexusVault.dailyBestScore(for: config.dayStamp))"),
            ("WIN STREAK", "\(NexusVault.dailyStreak)")
        ]

        let startY = cy + ph * 0.18
        let rowH   = ph * 0.08
        for (idx, row) in rows.enumerated() {
            let y = startY - CGFloat(idx) * rowH
            addChild(makeStatRow(label: row.0, value: row.1, y: y,
                                 labelColor: UIColor(white: 0.62, alpha: 1),
                                 valueColor: UIColor(white: 0.95, alpha: 1),
                                 panelWidth: pw))
        }

        addChild(makeSeparator(width: pw * 0.7,
                               position: CGPoint(x: cx, y: cy - ph * 0.16)))

        addChild(makeButton(title: "START CHALLENGE", color: accent,
                             position: CGPoint(x: cx, y: cy - ph * 0.28),
                             name: "dailyStartBtn"))

        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.40),
                             name: "closeBtn"))
    }

    // MARK: - Lifetime Stats

    func buildLifetimeStatsPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)
        let accent = UIColor(white: 0.85, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.70)))

        addChild(makePanelTitle(text: "LIFETIME STATS",
                                at: CGPoint(x: cx, y: cy + ph * 0.42),
                                color: accent))

        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: cy + ph * 0.36)))

        let stats = NexusVault.loadLifetimeStats()
        let rows: [(String, String)] = [
            ("SESSIONS",             "\(stats.sessions)"),
            ("TOTAL SCORE",          "\(stats.totalScore)"),
            ("TOTAL SPINS",          "\(stats.totalSpins)"),
            ("TOTAL FUSIONS",        "\(stats.totalFusions)"),
            ("BEST COMBO",           "\(stats.bestCombo)"),
            ("BEST APEX",            stats.bestApexLabel),
            ("QUEST CLEARS",         "\(stats.questClears)"),
            ("DAILY WINS",           "\(stats.dailyWins)"),
            ("LONGEST DAILY STREAK", "\(stats.longestDailyStreak)"),
            ("LAST PLAY",            stats.lastPlayedLabel)
        ]

        let rowH   = ph * 0.07
        let startY = cy + ph * 0.28
        for (idx, row) in rows.enumerated() {
            let y = startY - CGFloat(idx) * rowH
            addChild(makeStatRow(label: row.0, value: row.1, y: y,
                                 labelColor: UIColor(white: 0.62, alpha: 1),
                                 valueColor: UIColor(white: 0.95, alpha: 1),
                                 panelWidth: pw))
        }

        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: cy - ph * 0.44),
                             name: "closeBtn"))
    }

    // MARK: - Achievements

    func buildAchievementsPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2
        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.82, 660)
        let accent = UIColor(red: 1, green: 0.82, blue: 0.25, alpha: 1)

        addChild(makePanel(width: pw, height: ph,
                           position: CGPoint(x: cx, y: cy),
                           strokeColor: accent.withAlphaComponent(0.75)))

        addChild(makePanelTitle(text: "ACHIEVEMENTS",
                                at: CGPoint(x: cx, y: cy + ph * 0.44),
                                color: accent))

        let items = NexusVault.loadAchievements()
        let unlocked = items.filter(\.isUnlocked).count
        let progress = SKLabelNode(text: "\(unlocked) / \(items.count) Unlocked")
        progress.fontName  = "AvenirNext-Medium"
        progress.fontSize  = adaptiveFontSize(base: 13)
        progress.fontColor = UIColor(white: 0.62, alpha: 1)
        progress.verticalAlignmentMode = .center
        progress.position  = CGPoint(x: cx, y: cy + ph * 0.38)
        progress.zPosition = 2
        addChild(progress)

        addChild(makeSeparator(width: pw * 0.8,
                               position: CGPoint(x: cx, y: cy + ph * 0.34)))

        let closeY = cy - ph * 0.44
        let startY = cy + ph * 0.30
        let buttonClearance: CGFloat = 34
        let availableH = startY - (closeY + buttonClearance)
        let rowH = items.isEmpty ? 0 : availableH / CGFloat(items.count)

        for (idx, ach) in items.enumerated() {
            let y = startY - CGFloat(idx) * rowH

            let icon = SKLabelNode(text: ach.isUnlocked ? ach.icon : "🔒")
            icon.fontSize = adaptiveFontSize(base: 14)
            icon.verticalAlignmentMode = .center
            icon.position  = CGPoint(x: cx - pw * 0.40, y: y)
            icon.zPosition = 2
            addChild(icon)

            let title = SKLabelNode(text: ach.title)
            title.fontName  = "AvenirNext-DemiBold"
            title.fontSize  = adaptiveFontSize(base: 12)
            title.fontColor = ach.isUnlocked
                ? UIColor(white: 0.95, alpha: 1)
                : UIColor(white: 0.40, alpha: 1)
            title.horizontalAlignmentMode = .left
            title.verticalAlignmentMode   = .center
            title.position  = CGPoint(x: cx - pw * 0.30, y: y)
            title.zPosition = 2
            addChild(title)

            let detail = SKLabelNode(text: ach.detail)
            detail.fontName  = "AvenirNext-Regular"
            detail.fontSize  = adaptiveFontSize(base: 9)
            detail.fontColor = ach.isUnlocked
                ? UIColor(white: 0.62, alpha: 1)
                : UIColor(white: 0.30, alpha: 1)
            detail.horizontalAlignmentMode = .right
            detail.verticalAlignmentMode   = .center
            detail.position  = CGPoint(x: cx + pw * 0.42, y: y)
            detail.zPosition = 2
            addChild(detail)
        }

        addChild(makeButton(title: "CLOSE",
                             color: UIColor(white: 0.55, alpha: 1),
                             position: CGPoint(x: cx, y: closeY),
                             name: "closeBtn"))
    }

    // MARK: - Shared Helpers

    private func makePanelTitle(text: String, at pos: CGPoint, color: UIColor) -> SKLabelNode {
        let l      = SKLabelNode(text: text)
        l.fontName = "AvenirNext-Heavy"
        l.fontSize = adaptiveFontSize(base: 24)
        l.fontColor = color
        l.verticalAlignmentMode = .center
        l.position  = pos
        l.zPosition = 2
        return l
    }

    private func makeSectionHeading(text: String, at pos: CGPoint) -> SKLabelNode {
        let l      = SKLabelNode(text: text)
        l.fontName = "AvenirNext-Bold"
        l.fontSize = adaptiveFontSize(base: 16)
        l.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        l.verticalAlignmentMode = .center
        l.position  = pos
        l.zPosition = 2
        return l
    }
}
