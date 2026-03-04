// VortexBattleground+HUD.swift — HUD Setup & Update
import SpriteKit

// MARK: - VortexBattleground: HUD

extension VortexBattleground {

    // MARK: - HUD Construction

    /// Build the complete HUD: top bar background, score display, spin counter,
    /// apex label, combo label, weight hint, quest/timer label, and back button.
    func setupHUD() {
        setupTopBar()
        setupScoreDisplay()
        setupRightInfoLabels()
        setupBottomLabels()
        setupQuestAndTimerLabels()
        updateHUD()
    }

    // MARK: - Top Bar

    /// Create the translucent header bar that runs below the safe area.
    private func setupTopBar() {
        let cx    = size.width / 2
        let topBase = size.height - safeTop
        let barH: CGFloat = 80

        let topBar = SKShapeNode(rectOf: CGSize(width: size.width, height: barH))
        topBar.fillColor   = UIColor(red: 0.06, green: 0.06, blue: 0.18, alpha: 0.9)
        topBar.strokeColor = UIColor(red: 0.16, green: 0.16, blue: 0.44, alpha: 1)
        topBar.lineWidth   = 1
        topBar.position    = CGPoint(x: cx, y: topBase - barH / 2)
        topBar.zPosition   = 5
        addChild(topBar)

        // Back button on the left side of the top bar
        let backBtn      = makeTextButton(text: "◀ MENU", color: UIColor(white: 0.6, alpha: 1), fontSize: 14)
        backBtn.position = CGPoint(x: 52, y: topBase - 22)
        backBtn.zPosition = 6
        backBtn.name     = "backBtn"
        addChild(backBtn)
    }

    // MARK: - Score Display

    /// Place the large centered score label and its "SCORE" sub-caption in the top bar.
    private func setupScoreDisplay() {
        let cx      = size.width / 2
        let topBase = size.height - safeTop

        // Main score number
        scoreLbl          = SKLabelNode(text: "0")
        scoreLbl.fontName = "AvenirNext-Heavy"
        scoreLbl.fontSize = adaptiveFontSize(base: 28)
        scoreLbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        scoreLbl.horizontalAlignmentMode = .center
        scoreLbl.verticalAlignmentMode   = .center
        scoreLbl.position  = CGPoint(x: cx, y: topBase - 22)
        scoreLbl.zPosition = 6
        addChild(scoreLbl)

        // "SCORE" caption below the number
        let scoreSub          = SKLabelNode(text: "SCORE")
        scoreSub.fontName     = "AvenirNext-Medium"
        scoreSub.fontSize     = adaptiveFontSize(base: 10)
        scoreSub.fontColor    = UIColor(white: 0.5, alpha: 1)
        scoreSub.verticalAlignmentMode = .center
        scoreSub.position     = CGPoint(x: cx, y: topBase - 42)
        scoreSub.zPosition    = 6
        addChild(scoreSub)
    }

    // MARK: - Right Side Info Labels

    /// Place spin counter and apex labels in the top-right region of the top bar.
    private func setupRightInfoLabels() {
        let topBase = size.height - safeTop

        // Spin count / spins remaining (right-aligned)
        spinsLbl          = SKLabelNode(text: "")
        spinsLbl.fontName = "AvenirNext-Bold"
        spinsLbl.fontSize = adaptiveFontSize(base: 13)
        spinsLbl.fontColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        spinsLbl.horizontalAlignmentMode = .right
        spinsLbl.verticalAlignmentMode   = .center
        spinsLbl.position  = CGPoint(x: size.width - 16, y: topBase - 22)
        spinsLbl.zPosition = 6
        addChild(spinsLbl)

        // Apex tier achieved label below spin count
        apexLbl          = SKLabelNode(text: "APEX: —")
        apexLbl.fontName = "AvenirNext-Bold"
        apexLbl.fontSize = adaptiveFontSize(base: 12)
        apexLbl.fontColor = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        apexLbl.horizontalAlignmentMode = .right
        apexLbl.verticalAlignmentMode   = .center
        apexLbl.position  = CGPoint(x: size.width - 16, y: topBase - 42)
        apexLbl.zPosition = 6
        addChild(apexLbl)
    }

    // MARK: - Bottom Area Labels

    /// Place the combo label and weight hint display below the grid.
    private func setupBottomLabels() {
        let cx         = size.width / 2
        let spinClearY = size.height * 0.1 + 65

        // Combo notification label (center, between grid and spin button)
        comboLbl          = SKLabelNode(text: "")
        comboLbl.fontName = "AvenirNext-Heavy"
        comboLbl.fontSize = adaptiveFontSize(base: 26)
        comboLbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        comboLbl.position  = CGPoint(x: cx, y: max(gridOriginY - tileSize * 2.4, spinClearY + 10))
        comboLbl.zPosition = 6
        addChild(comboLbl)

        // Probability weight hint (multi-line, small font)
        weightLbl                      = SKLabelNode(text: "")
        weightLbl.fontName             = "Menlo-Regular"
        weightLbl.fontSize             = adaptiveFontSize(base: 10)
        weightLbl.fontColor            = UIColor(red: 0, green: 0.83, blue: 1, alpha: 0.8)
        weightLbl.numberOfLines        = 0
        weightLbl.preferredMaxLayoutWidth = size.width - 40
        weightLbl.horizontalAlignmentMode = .center
        weightLbl.verticalAlignmentMode   = .top
        weightLbl.position             = CGPoint(x: cx, y: max(gridOriginY - tileSize * 2.7, spinClearY))
        weightLbl.zPosition            = 6
        addChild(weightLbl)
    }

    // MARK: - Quest & Timer Labels

    /// Place the quest progress label and timed blitz timer label above the grid.
    /// Both occupy the same position; only one is visible at a time.
    private func setupQuestAndTimerLabels() {
        let cx    = size.width / 2
        let labelY = gridOriginY + tileSize * 2.6

        // Quest goal display (above grid)
        questGoalLbl          = SKLabelNode(text: "")
        questGoalLbl.fontName = "AvenirNext-Heavy"
        questGoalLbl.fontSize = adaptiveFontSize(base: 15)
        questGoalLbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        questGoalLbl.horizontalAlignmentMode = .center
        questGoalLbl.verticalAlignmentMode   = .center
        questGoalLbl.position  = CGPoint(x: cx, y: labelY)
        questGoalLbl.zPosition = 6
        addChild(questGoalLbl)

        // Countdown timer for timed blitz (same position as quest label)
        timerLbl          = SKLabelNode(text: "")
        timerLbl.fontName = "AvenirNext-Heavy"
        timerLbl.fontSize = adaptiveFontSize(base: 18)
        timerLbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        timerLbl.horizontalAlignmentMode = .center
        timerLbl.verticalAlignmentMode   = .center
        timerLbl.position  = CGPoint(x: cx, y: labelY)
        timerLbl.zPosition = 6
        addChild(timerLbl)
    }

    // MARK: - Text Button Factory

    /// Create a simple text label styled as a pressable button.
    func makeTextButton(text: String, color: UIColor, fontSize: CGFloat) -> SKLabelNode {
        let lbl      = SKLabelNode(text: text)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: fontSize)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        return lbl
    }

    // MARK: - HUD Update

    /// Refresh all HUD labels to reflect the current engine state.
    /// Routes to mode-specific sub-methods for quest vs. timed blitz.
    func updateHUD() {
        updateScoreLabel()
        updateApexLabel()

        if case .questRun = vaultEngine.warpMode {
            updateQuestHUD()
        } else {
            updateTimedBlitzHUD()
        }
    }

    /// Sync the score label with the current total luminance value.
    private func updateScoreLabel() {
        scoreLbl.text = "\(vaultEngine.totalLuminance)"
    }

    /// Sync the apex label with the highest tier reached this session.
    private func updateApexLabel() {
        if let apex = vaultEngine.apexTierReached {
            apexLbl.text = "APEX: \(apex.labelText)"
        } else {
            apexLbl.text = "APEX: —"
        }
    }

    /// Refresh HUD elements specific to quest mode.
    private func updateQuestHUD() {
        guard case .questRun(let lvl) = vaultEngine.warpMode else { return }

        spinsLbl.text  = "SPINS: \(vaultEngine.questSpinsLeft)"
        timerLbl.text  = ""

        let target  = vaultEngine.questTarget.labelText
        let count   = vaultEngine.questTargetCount
        let current = vaultEngine.questTargetCountOnGrid

        questGoalLbl.text = "⚔ LEVEL \(lvl)  ▸  \(current)/\(count) × \(target)"
        questGoalLbl.fontColor = current >= count
            ? UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
            : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)

        weightLbl.text = formatWeights()
    }

    /// Refresh HUD elements specific to timed blitz mode.
    private func updateTimedBlitzHUD() {
        spinsLbl.text    = "SPIN ×\(vaultEngine.spinCount)"
        questGoalLbl.text = ""

        let secs = Int(ceil(timeRemaining))
        timerLbl.text      = "⏱ \(secs)s"
        timerLbl.fontColor = secs <= 10
            ? UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)
            : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)

        weightLbl.text = formatWeights()
    }

    // MARK: - Weight Formatting

    /// Produce a compact two-row string showing all eight tier weights.
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
