// PhantomOverlay+InfoPanels.swift — Info & Reference Panels
import SpriteKit

extension PhantomOverlay {

    // MARK: - Leaderboard Panel
    func buildLeaderboardPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)

        let panel = SKShapeNode(rectOf: CGSize(width: pw, height: ph), cornerRadius: 22)
        panel.fillColor   = UIColor(red:0.07,green:0.07,blue:0.18,alpha:0.97)
        panel.strokeColor = UIColor(red:1,green:0.84,blue:0,alpha:0.8)
        panel.lineWidth   = 2
        panel.position    = CGPoint(x: cx, y: cy)
        panel.zPosition   = 1
        addChild(panel)

        let titleLbl = SKLabelNode(text: "LEADERBOARD")
        titleLbl.fontName  = "AvenirNext-Heavy"
        titleLbl.fontSize  = adaptiveFontSize(base: 24)
        titleLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        titleLbl.verticalAlignmentMode = .center
        titleLbl.position  = CGPoint(x: cx, y: cy + ph*0.42)
        titleLbl.zPosition = 2
        addChild(titleLbl)

        let entries = NexusVault.loadLeaderboard()
        let rowH: CGFloat = ph * 0.075
        let startY = cy + ph*0.30

        if entries.isEmpty {
            let emptyLbl = SKLabelNode(text: "No records yet")
            emptyLbl.fontName  = "AvenirNext-Medium"
            emptyLbl.fontSize  = adaptiveFontSize(base: 16)
            emptyLbl.fontColor = UIColor(white:0.5,alpha:1)
            emptyLbl.verticalAlignmentMode = .center
            emptyLbl.position  = CGPoint(x: cx, y: cy)
            emptyLbl.zPosition = 2
            addChild(emptyLbl)
        } else {
            for (i, entry) in entries.prefix(10).enumerated() {
                let y = startY - CGFloat(i) * rowH
                let medals = ["🥇","🥈","🥉"]
                let rank = i < 3 ? medals[i] : "#\(i+1)"

                let rankLbl = SKLabelNode(text: rank)
                rankLbl.fontName  = "AvenirNext-Bold"
                rankLbl.fontSize  = adaptiveFontSize(base: 14)
                rankLbl.fontColor = i < 3
                    ? UIColor(red:1,green:0.84,blue:0,alpha:1)
                    : UIColor(white:0.7,alpha:1)
                rankLbl.horizontalAlignmentMode = .left
                rankLbl.verticalAlignmentMode   = .center
                rankLbl.position  = CGPoint(x: cx - pw*0.40, y: y)
                rankLbl.zPosition = 2
                addChild(rankLbl)

                let scoreLbl = SKLabelNode(text: "\(entry.score)")
                scoreLbl.fontName  = "AvenirNext-Heavy"
                scoreLbl.fontSize  = adaptiveFontSize(base: 14)
                scoreLbl.fontColor = UIColor(white:0.95,alpha:1)
                scoreLbl.horizontalAlignmentMode = .center
                scoreLbl.verticalAlignmentMode   = .center
                scoreLbl.position  = CGPoint(x: cx - pw*0.05, y: y)
                scoreLbl.zPosition = 2
                addChild(scoreLbl)

                let tierName = GlyphTier(rawValue: entry.apexTier)?.labelText ?? "—"
                let detail = entry.apexCount > 0 ? "\(entry.apexCount)×\(tierName)" : "—"
                let detailLbl = SKLabelNode(text: detail)
                detailLbl.fontName  = "AvenirNext-Medium"
                detailLbl.fontSize  = adaptiveFontSize(base: 12)
                detailLbl.fontColor = UIColor(red:0,green:0.83,blue:1,alpha:0.9)
                detailLbl.horizontalAlignmentMode = .right
                detailLbl.verticalAlignmentMode   = .center
                detailLbl.position  = CGPoint(x: cx + pw*0.40, y: y)
                detailLbl.zPosition = 2
                addChild(detailLbl)
            }
        }

        let closeBtn = makeButton(title: "CLOSE",
                                  color: UIColor(white:0.6,alpha:1),
                                  position: CGPoint(x: cx, y: cy - ph*0.44),
                                  name: "closeBtn")
        addChild(closeBtn)
    }

    // MARK: - Settings Panel
    func buildSettingsPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)

        let panel = SKShapeNode(rectOf: CGSize(width: pw, height: ph), cornerRadius: 22)
        panel.fillColor   = UIColor(red:0.07,green:0.07,blue:0.18,alpha:0.97)
        panel.strokeColor = UIColor(white:0.5,alpha:0.8)
        panel.lineWidth   = 2
        panel.position    = CGPoint(x: cx, y: cy)
        panel.zPosition   = 1
        addChild(panel)

        let titleLbl = SKLabelNode(text: "⚙ SETTINGS")
        titleLbl.fontName  = "AvenirNext-Heavy"
        titleLbl.fontSize  = adaptiveFontSize(base: 24)
        titleLbl.fontColor = UIColor(white:0.95,alpha:1)
        titleLbl.verticalAlignmentMode = .center
        titleLbl.position  = CGPoint(x: cx, y: cy + ph*0.42)
        titleLbl.zPosition = 2
        addChild(titleLbl)

        // How to Play section
        let howTitle = SKLabelNode(text: "HOW TO PLAY")
        howTitle.fontName  = "AvenirNext-Bold"
        howTitle.fontSize  = adaptiveFontSize(base: 16)
        howTitle.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        howTitle.verticalAlignmentMode = .center
        howTitle.position  = CGPoint(x: cx, y: cy + ph*0.30)
        howTitle.zPosition = 2
        addChild(howTitle)

        let instructions = [
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

        let lineH: CGFloat = ph * 0.048
        let startY = cy + ph*0.22
        for (i, line) in instructions.enumerated() {
            let lbl = SKLabelNode(text: line)
            lbl.fontName  = "AvenirNext-Regular"
            lbl.fontSize  = adaptiveFontSize(base: 11)
            lbl.fontColor = UIColor(white:0.75,alpha:1)
            lbl.verticalAlignmentMode = .center
            lbl.horizontalAlignmentMode = .center
            lbl.position  = CGPoint(x: cx, y: startY - CGFloat(i) * lineH)
            lbl.zPosition = 2
            addChild(lbl)
        }

        // Rate App button
        let rateBtn = makeButton(title: "⭐ RATE THIS APP",
                                 color: UIColor(red:1,green:0.84,blue:0,alpha:1),
                                 position: CGPoint(x: cx, y: cy - ph*0.30),
                                 name: "rateBtn")
        addChild(rateBtn)

        // Close button
        let closeBtn = makeButton(title: "CLOSE",
                                  color: UIColor(white:0.6,alpha:1),
                                  position: CGPoint(x: cx, y: cy - ph*0.42),
                                  name: "closeBtn")
        addChild(closeBtn)
    }

    // MARK: - Codex Panel
    func buildCodexPanel() {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.88, 360)
        let ph: CGFloat = min(sceneSize.height * 0.78, 620)

        let panel = SKShapeNode(rectOf: CGSize(width: pw, height: ph), cornerRadius: 22)
        panel.fillColor   = UIColor(red:0.07,green:0.07,blue:0.18,alpha:0.97)
        panel.strokeColor = UIColor(red:0,green:0.83,blue:1,alpha:0.8)
        panel.lineWidth   = 2
        panel.position    = CGPoint(x: cx, y: cy)
        panel.zPosition   = 1
        addChild(panel)

        let titleLbl = SKLabelNode(text: "CODEX")
        titleLbl.fontName  = "AvenirNext-Heavy"
        titleLbl.fontSize  = adaptiveFontSize(base: 26)
        titleLbl.fontColor = UIColor(red:0,green:0.83,blue:1,alpha:1)
        titleLbl.verticalAlignmentMode = .center
        titleLbl.position  = CGPoint(x: cx, y: cy + ph*0.42)
        titleLbl.zPosition = 2
        addChild(titleLbl)

        let rowH: CGFloat = ph * 0.09
        let startY = cy + ph*0.28

        for (i, tier) in GlyphTier.allCases.enumerated() {
            let y = startY - CGFloat(i) * rowH

            let icon = SKSpriteNode(imageNamed: tier.assetName)
            icon.size     = CGSize(width: rowH*0.7, height: rowH*0.7)
            icon.position = CGPoint(x: cx - pw*0.32, y: y)
            icon.zPosition = 2
            addChild(icon)

            let nameLbl = SKLabelNode(text: "Lv\(tier.rawValue)  \(tier.labelText)")
            nameLbl.fontName  = "AvenirNext-Bold"
            nameLbl.fontSize  = adaptiveFontSize(base: 15)
            nameLbl.fontColor = UIColor(white:0.9,alpha:1)
            nameLbl.horizontalAlignmentMode = .left
            nameLbl.verticalAlignmentMode   = .center
            nameLbl.position  = CGPoint(x: cx - pw*0.18, y: y)
            nameLbl.zPosition = 2
            addChild(nameLbl)

            let pts = tier.rawValue * tier.rawValue * 20
            let ptsLbl = SKLabelNode(text: "\(pts)pt")
            ptsLbl.fontName  = "AvenirNext-Medium"
            ptsLbl.fontSize  = adaptiveFontSize(base: 13)
            ptsLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:0.9)
            ptsLbl.horizontalAlignmentMode = .right
            ptsLbl.verticalAlignmentMode   = .center
            ptsLbl.position  = CGPoint(x: cx + pw*0.40, y: y)
            ptsLbl.zPosition = 2
            addChild(ptsLbl)
        }

        let closeBtn = makeButton(title: "CLOSE",
                                  color: UIColor(white:0.6,alpha:1),
                                  position: CGPoint(x: cx, y: cy - ph*0.44),
                                  name: "closeBtn")
        addChild(closeBtn)
    }
}
