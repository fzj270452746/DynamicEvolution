// VortexBattleground+HUD.swift — HUD Setup & Update
import SpriteKit

extension VortexBattleground {

    // MARK: - HUD
    func setupHUD() {
        let cx = size.width / 2
        let topBase = size.height - safeTop

        // top bar background (below safe area)
        let barH: CGFloat = 80
        let topBar = SKShapeNode(rectOf: CGSize(width: size.width, height: barH))
        topBar.fillColor   = UIColor(red:0.06,green:0.06,blue:0.18,alpha:0.9)
        topBar.strokeColor = UIColor(red:0.16,green:0.16,blue:0.44,alpha:1)
        topBar.lineWidth   = 1
        topBar.position    = CGPoint(x: cx, y: topBase - barH/2)
        topBar.zPosition   = 5
        addChild(topBar)

        // back button
        let backBtn = makeTextButton(text: "◀ MENU", color: UIColor(white:0.6,alpha:1), fontSize: 14)
        backBtn.position  = CGPoint(x: 52, y: topBase - 22)
        backBtn.zPosition = 6
        backBtn.name      = "backBtn"
        addChild(backBtn)

        // score
        scoreLbl = SKLabelNode(text: "0")
        scoreLbl.fontName  = "AvenirNext-Heavy"
        scoreLbl.fontSize  = adaptiveFontSize(base: 28)
        scoreLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        scoreLbl.horizontalAlignmentMode = .center
        scoreLbl.verticalAlignmentMode   = .center
        scoreLbl.position  = CGPoint(x: cx, y: topBase - 22)
        scoreLbl.zPosition = 6
        addChild(scoreLbl)

        let scoreSub = SKLabelNode(text: "SCORE")
        scoreSub.fontName  = "AvenirNext-Medium"
        scoreSub.fontSize  = adaptiveFontSize(base: 10)
        scoreSub.fontColor = UIColor(white:0.5,alpha:1)
        scoreSub.verticalAlignmentMode = .center
        scoreSub.position  = CGPoint(x: cx, y: topBase - 42)
        scoreSub.zPosition = 6
        addChild(scoreSub)

        // spins left (top right)
        spinsLbl = SKLabelNode(text: "")
        spinsLbl.fontName  = "AvenirNext-Bold"
        spinsLbl.fontSize  = adaptiveFontSize(base: 13)
        spinsLbl.fontColor = UIColor(red:0,green:0.83,blue:1,alpha:1)
        spinsLbl.horizontalAlignmentMode = .right
        spinsLbl.verticalAlignmentMode   = .center
        spinsLbl.position  = CGPoint(x: size.width - 16, y: topBase - 22)
        spinsLbl.zPosition = 6
        addChild(spinsLbl)

        // apex label
        apexLbl = SKLabelNode(text: "APEX: —")
        apexLbl.fontName  = "AvenirNext-Bold"
        apexLbl.fontSize  = adaptiveFontSize(base: 12)
        apexLbl.fontColor = UIColor(red:0.22,green:1,blue:0.08,alpha:1)
        apexLbl.horizontalAlignmentMode = .right
        apexLbl.verticalAlignmentMode   = .center
        apexLbl.position  = CGPoint(x: size.width - 16, y: topBase - 42)
        apexLbl.zPosition = 6
        addChild(apexLbl)

        // combo label (center, below grid) — ensure above spin button
        let spinClearY = size.height * 0.1 + 65 // spin button top + text height + margin
        comboLbl = SKLabelNode(text: "")
        comboLbl.fontName  = "AvenirNext-Heavy"
        comboLbl.fontSize  = adaptiveFontSize(base: 26)
        comboLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        comboLbl.position  = CGPoint(x: cx, y: max(gridOriginY - tileSize*2.4, spinClearY + 10))
        comboLbl.zPosition = 6
        addChild(comboLbl)

        // weight hint label — styled as a panel, avoid spin button overlap
        weightLbl = SKLabelNode(text: "")
        weightLbl.fontName  = "Menlo-Regular"
        weightLbl.fontSize  = adaptiveFontSize(base: 10)
        weightLbl.fontColor = UIColor(red:0,green:0.83,blue:1,alpha:0.8)
        weightLbl.numberOfLines = 0
        weightLbl.preferredMaxLayoutWidth = size.width - 40
        weightLbl.horizontalAlignmentMode = .center
        weightLbl.verticalAlignmentMode   = .top
        weightLbl.position  = CGPoint(x: cx, y: max(gridOriginY - tileSize*2.7, spinClearY))
        weightLbl.zPosition = 6
        addChild(weightLbl)

        // quest goal label — prominent display above grid
        questGoalLbl = SKLabelNode(text: "")
        questGoalLbl.fontName  = "AvenirNext-Heavy"
        questGoalLbl.fontSize  = adaptiveFontSize(base: 15)
        questGoalLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        questGoalLbl.horizontalAlignmentMode = .center
        questGoalLbl.verticalAlignmentMode   = .center
        questGoalLbl.position  = CGPoint(x: cx, y: gridOriginY + tileSize * 2.6)
        questGoalLbl.zPosition = 6
        addChild(questGoalLbl)

        // timer label for timed blitz mode
        timerLbl = SKLabelNode(text: "")
        timerLbl.fontName  = "AvenirNext-Heavy"
        timerLbl.fontSize  = adaptiveFontSize(base: 18)
        timerLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        timerLbl.horizontalAlignmentMode = .center
        timerLbl.verticalAlignmentMode   = .center
        timerLbl.position  = CGPoint(x: cx, y: gridOriginY + tileSize * 2.6)
        timerLbl.zPosition = 6
        addChild(timerLbl)

        updateHUD()
    }

    func makeTextButton(text: String, color: UIColor, fontSize: CGFloat) -> SKLabelNode {
        let lbl = SKLabelNode(text: text)
        lbl.fontName  = "AvenirNext-Bold"
        lbl.fontSize  = adaptiveFontSize(base: fontSize)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        return lbl
    }

    func updateHUD() {
        scoreLbl.text = "\(vaultEngine.totalLuminance)"
        if let apex = vaultEngine.apexTierReached {
            apexLbl.text = "APEX: \(apex.labelText)"
        } else {
            apexLbl.text = "APEX: —"
        }
        if case .questRun(let lvl) = vaultEngine.warpMode {
            spinsLbl.text = "SPINS: \(vaultEngine.questSpinsLeft)"
            let target = vaultEngine.questTarget.labelText
            let count  = vaultEngine.questTargetCount
            let current = vaultEngine.gridCells.compactMap({ $0 }).filter { $0.rawValue >= vaultEngine.questTarget.rawValue }.count
            questGoalLbl.text = "⚔ LEVEL \(lvl)  ▸  \(current)/\(count) × \(target)"
            questGoalLbl.fontColor = current >= count
                ? UIColor(red:0.22,green:1,blue:0.08,alpha:1)
                : UIColor(red:1,green:0.84,blue:0,alpha:1)
            timerLbl.text = ""
            weightLbl.text = formatWeights()
        } else {
            spinsLbl.text = "SPIN ×\(vaultEngine.spinCount)"
            questGoalLbl.text = ""
            let secs = Int(ceil(timeRemaining))
            timerLbl.text = "⏱ \(secs)s"
            timerLbl.fontColor = secs <= 10
                ? UIColor(red:1,green:0.19,blue:0.19,alpha:1)
                : UIColor(red:1,green:0.84,blue:0,alpha:1)
            weightLbl.text = formatWeights()
        }
    }

    func formatWeights() -> String {
        let tiers = GlyphTier.allCases
        let top = tiers.prefix(4).map { t in
            String(format: "%@:%.0f%%", String(t.labelText.prefix(3)), vaultEngine.orbitalWeights[t] ?? 0)
        }.joined(separator: "  ")
        let bot = tiers.suffix(4).map { t in
            String(format: "%@:%.0f%%", String(t.labelText.prefix(3)), vaultEngine.orbitalWeights[t] ?? 0)
        }.joined(separator: "  ")
        return top + "\n" + bot
    }
}
