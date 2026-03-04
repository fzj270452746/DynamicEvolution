// VortexBattleground+HUD.swift — HUD Setup & Update
import SpriteKit

// MARK: - VortexBattleground: HUD

extension VortexBattleground {

    // MARK: - HUD Construction

    func setupHUD() {
        buildTopBar()
        buildScoreDisplay()
        buildRightInfoLabels()
        buildBottomLabels()
        buildQuestAndTimerLabels()
        updateHUD()
    }

    // MARK: - Top Bar

    private func buildTopBar() {
        let cx      = size.width / 2
        let topBase = size.height - safeTop
        let barH: CGFloat = 80

        let bar = SKShapeNode(rectOf: CGSize(width: size.width, height: barH))
        bar.fillColor   = UIColor(red: 0.05, green: 0.02, blue: 0.18, alpha: 0.92)
        bar.strokeColor = UIColor(red: 0.22, green: 0.12, blue: 0.44, alpha: 0.9)
        bar.lineWidth   = 1
        bar.position    = CGPoint(x: cx, y: topBase - barH / 2)
        bar.zPosition   = 5
        addChild(bar)

        let back      = makeTextButton(text: "◀ MENU",
                                        color: UIColor(white: 0.55, alpha: 1),
                                        fontSize: 14)
        back.position  = CGPoint(x: 52, y: topBase - 22)
        back.zPosition = 6
        back.name      = "backBtn"
        addChild(back)
    }

    // MARK: - Score Display

    private func buildScoreDisplay() {
        let cx      = size.width / 2
        let topBase = size.height - safeTop

        scoreLbl          = SKLabelNode(text: "0")
        scoreLbl.fontName = "AvenirNext-Heavy"
        scoreLbl.fontSize = adaptiveFontSize(base: 28)
        scoreLbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        scoreLbl.horizontalAlignmentMode = .center
        scoreLbl.verticalAlignmentMode   = .center
        scoreLbl.position  = CGPoint(x: cx, y: topBase - 22)
        scoreLbl.zPosition = 6
        addChild(scoreLbl)

        let sub          = SKLabelNode(text: "SCORE")
        sub.fontName     = "AvenirNext-Medium"
        sub.fontSize     = adaptiveFontSize(base: 10)
        sub.fontColor    = UIColor(white: 0.45, alpha: 1)
        sub.verticalAlignmentMode = .center
        sub.position     = CGPoint(x: cx, y: topBase - 42)
        sub.zPosition    = 6
        addChild(sub)
    }

    // MARK: - Right Info

    private func buildRightInfoLabels() {
        let topBase = size.height - safeTop

        spinsLbl          = SKLabelNode(text: "")
        spinsLbl.fontName = "AvenirNext-Bold"
        spinsLbl.fontSize = adaptiveFontSize(base: 13)
        spinsLbl.fontColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 1)
        spinsLbl.horizontalAlignmentMode = .right
        spinsLbl.verticalAlignmentMode   = .center
        spinsLbl.position  = CGPoint(x: size.width - 16, y: topBase - 22)
        spinsLbl.zPosition = 6
        addChild(spinsLbl)

        apexLbl          = SKLabelNode(text: "APEX: —")
        apexLbl.fontName = "AvenirNext-Bold"
        apexLbl.fontSize = adaptiveFontSize(base: 12)
        apexLbl.fontColor = UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)
        apexLbl.horizontalAlignmentMode = .right
        apexLbl.verticalAlignmentMode   = .center
        apexLbl.position  = CGPoint(x: size.width - 16, y: topBase - 42)
        apexLbl.zPosition = 6
        addChild(apexLbl)
    }

    // MARK: - Bottom Labels

    private func buildBottomLabels() {
        let cx         = size.width / 2
        let spinClearY = size.height * 0.1 + 65

        comboLbl          = SKLabelNode(text: "")
        comboLbl.fontName = "AvenirNext-Heavy"
        comboLbl.fontSize = adaptiveFontSize(base: 26)
        comboLbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        comboLbl.position  = CGPoint(x: cx, y: max(gridOriginY - tileSize * 2.4, spinClearY + 10))
        comboLbl.zPosition = 6
        addChild(comboLbl)

        weightLbl                         = SKLabelNode(text: "")
        weightLbl.fontName                = "Menlo-Regular"
        weightLbl.fontSize                = adaptiveFontSize(base: 10)
        weightLbl.fontColor               = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.75)
        weightLbl.numberOfLines           = 0
        weightLbl.preferredMaxLayoutWidth  = size.width - 40
        weightLbl.horizontalAlignmentMode = .center
        weightLbl.verticalAlignmentMode   = .top
        weightLbl.position                = CGPoint(x: cx, y: max(gridOriginY - tileSize * 2.7, spinClearY))
        weightLbl.zPosition               = 6
        addChild(weightLbl)
    }

    // MARK: - Quest & Timer Labels

    private func buildQuestAndTimerLabels() {
        let cx     = size.width / 2
        let labelY = gridOriginY + tileSize * 2.6

        questGoalLbl          = SKLabelNode(text: "")
        questGoalLbl.fontName = "AvenirNext-Heavy"
        questGoalLbl.fontSize = adaptiveFontSize(base: 15)
        questGoalLbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        questGoalLbl.horizontalAlignmentMode = .center
        questGoalLbl.verticalAlignmentMode   = .center
        questGoalLbl.position  = CGPoint(x: cx, y: labelY)
        questGoalLbl.zPosition = 6
        addChild(questGoalLbl)

        timerLbl          = SKLabelNode(text: "")
        timerLbl.fontName = "AvenirNext-Heavy"
        timerLbl.fontSize = adaptiveFontSize(base: 18)
        timerLbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        timerLbl.horizontalAlignmentMode = .center
        timerLbl.verticalAlignmentMode   = .center
        timerLbl.position  = CGPoint(x: cx, y: labelY)
        timerLbl.zPosition = 6
        addChild(timerLbl)
    }

    // MARK: - Text Button

    func makeTextButton(text: String, color: UIColor, fontSize: CGFloat) -> SKLabelNode {
        let lbl      = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: fontSize)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        return lbl
    }

    // MARK: - HUD Refresh

    func updateHUD() {
        updateScoreLabel()
        updateApexLabel()

        switch vaultEngine.warpMode {
        case .questRun:       updateQuestHUD()
        case .dailyChallenge: updateDailyHUD()
        case .timedBlitz:     updateTimedBlitzHUD()
        }
    }

    private func updateScoreLabel() {
        scoreLbl.text = "\(vaultEngine.totalLuminance)"
    }

    private func updateApexLabel() {
        if let apex = vaultEngine.apexTierReached {
            apexLbl.text = "APEX: \(apex.labelText)"
        } else {
            apexLbl.text = "APEX: —"
        }
    }

    private func updateQuestHUD() {
        guard case .questRun(let lvl) = vaultEngine.warpMode else { return }

        spinsLbl.text  = "SPINS: \(vaultEngine.questSpinsLeft)"
        timerLbl.text  = ""

        let target  = vaultEngine.questTarget.labelText
        let count   = vaultEngine.questTargetCount
        let current = vaultEngine.questTargetCountOnGrid

        questGoalLbl.text = "⚔ LEVEL \(lvl)  ▸  \(current)/\(count) × \(target)"
        questGoalLbl.fontColor = current >= count
            ? UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)
            : UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)

        weightLbl.text = formatWeights()
    }

    private func updateDailyHUD() {
        spinsLbl.text  = "SPINS: \(vaultEngine.questSpinsLeft)"
        timerLbl.text  = ""

        let target  = vaultEngine.questTarget.labelText
        let count   = vaultEngine.questTargetCount
        let current = vaultEngine.questTargetCountOnGrid

        questGoalLbl.text = "DAILY CHALLENGE  ▸  \(current)/\(count) × \(target)"
        questGoalLbl.fontColor = current >= count
            ? UIColor(red: 0.35, green: 1, blue: 0.56, alpha: 1)
            : UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)

        weightLbl.text = formatWeights()
    }

    private func updateTimedBlitzHUD() {
        spinsLbl.text     = "SPIN ×\(vaultEngine.spinCount)"
        questGoalLbl.text = ""

        let secs = Int(ceil(timeRemaining))
        timerLbl.text      = "⏱ \(secs)s"
        timerLbl.fontColor = secs <= 10
            ? UIColor(red: 1, green: 0.37, blue: 0.42, alpha: 1)
            : UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)

        weightLbl.text = formatWeights()
    }

    // MARK: - Weight Formatting

    func formatWeights() -> String {
        let tiers = GlyphTier.allCases
        let top   = tiers.prefix(4).map { t in
            String(format: "%@:%.0f%%", t.shortLabel, vaultEngine.orbitalWeights[t] ?? 0)
        }.joined(separator: "  ")
        let bot   = tiers.suffix(4).map { t in
            String(format: "%@:%.0f%%", t.shortLabel, vaultEngine.orbitalWeights[t] ?? 0)
        }.joined(separator: "  ")
        return top + "\n" + bot
    }
}
