// VortexBattleground+EndGame.swift — Timer, End Game & Navigation
import SpriteKit

// MARK: - VortexBattleground: End Game & Navigation

extension VortexBattleground {

    // MARK: - Per-Frame Update (Timed Blitz)

    override func update(_ currentTime: TimeInterval) {
        guard case .timedBlitz = vaultEngine.warpMode else { return }
        guard !timedGameOver else { return }

        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        timeRemaining -= dt

        let secsNow  = Int(ceil(timeRemaining))
        let secsPrev = Int(ceil(timeRemaining + dt))
        if secsNow == 10 && secsPrev > 10 {
            flashTimerWarning()
        }

        if timeRemaining <= 0 {
            timeRemaining = 0
            timedGameOver = true
            endTimedBlitz()
        }

        let secs = Int(ceil(timeRemaining))
        timerLbl.text      = "⏱ \(secs)s"
        timerLbl.fontColor = secs <= 10
            ? UIColor(red: 1, green: 0.37, blue: 0.42, alpha: 1)
            : UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
    }

    // MARK: - Timed Blitz End

    func endTimedBlitz() {
        isAnimating = true
        setSpinButtonEnabled(false)

        let stats = vaultEngine.apexTierStats()
        NexusVault.saveToLeaderboard(
            score:     vaultEngine.totalLuminance,
            apexTier:  stats?.tier,
            apexCount: stats?.count ?? 0
        )

        recordSessionIfNeeded(won: false)

        run(SKAction.wait(forDuration: 0.5)) { [weak self] in
            self?.showTimedEndOverlay()
        }
    }

    func showTimedEndOverlay() {
        let stats   = vaultEngine.apexTierStats()
        let overlay = PhantomOverlay(size: size, kind: .timedResult(
            score:     vaultEngine.totalLuminance,
            apexTier:  stats?.tier.labelText ?? "—",
            apexCount: stats?.count ?? 0
        ))
        overlay.zPosition = 100
        overlay.onDismiss = { [weak self] in
            self?.goBackToMenu()
        }
        addChild(overlay)
    }

    // MARK: - Quest End

    func showEndOverlay(won: Bool) {
        recordSessionIfNeeded(won: won)

        let apexText = vaultEngine.apexTierReached?.labelText ?? "—"
        let score    = vaultEngine.totalLuminance

        let kind: PhantomOverlay.OverlayKind
        if won, case .questRun(let lvl) = vaultEngine.warpMode {
            kind = .questWin(score: score, apex: apexText, level: lvl)
        } else if won {
            kind = .gameWin(score: score, apex: apexText)
        } else {
            kind = .gameLose(score: score, apex: apexText)
        }

        let overlay = PhantomOverlay(size: size, kind: kind)
        overlay.zPosition = 100
        overlay.onDismiss = { [weak self] in
            self?.goBackToMenu()
        }
        overlay.onNextLevel = { [weak self] in
            self?.advanceToNextQuestLevel()
        }
        addChild(overlay)
    }

    // MARK: - Daily Challenge End

    func showDailyEndOverlay(won: Bool) {
        recordSessionIfNeeded(won: won)

        let dayStamp = vaultEngine.warpMode.dayStamp ?? NexusVault.dayStamp()
        let best     = NexusVault.dailyBestScore(for: dayStamp)
        let streak   = NexusVault.dailyStreak
        let target   = "\(vaultEngine.questTargetCount)×\(vaultEngine.questTarget.labelText)"
        let apexText = vaultEngine.apexTierReached?.labelText ?? "—"

        let overlay = PhantomOverlay(size: size, kind: .dailyResult(
            score: vaultEngine.totalLuminance,
            apex: apexText,
            won: won,
            target: target,
            best: best,
            streak: streak,
            dayLabel: NexusVault.dailyLabel(for: dayStamp)
        ))
        overlay.zPosition = 100
        overlay.onDismiss = { [weak self] in
            self?.goBackToMenu()
        }
        addChild(overlay)
    }

    // MARK: - Level Advancement

    private func advanceToNextQuestLevel() {
        guard case .questRun(let lvl) = vaultEngine.warpMode else { return }
        let nextLvl = lvl + 1
        NexusVault.saveQuestLevel(nextLvl)
        vaultEngine.configureWarpMode(.questRun(level: nextLvl))
        clearBoardForNextRound()
    }

    // MARK: - Reset

    func restartGame() {
        clearBoardForNextRound()
    }

    private func clearBoardForNextRound() {
        tileNodes.forEach { $0.showAsEmptySlot() }
        isAnimating      = false
        timedGameOver    = false
        lastUpdateTime   = 0
        timeRemaining    = 90
        didRecordSession = false
        setSpinButtonEnabled(true)
        updateHUD()
    }

    // MARK: - Session Recording

    private func recordSessionIfNeeded(won: Bool) {
        guard !didRecordSession else { return }
        didRecordSession = true

        NexusVault.recordSession(
            mode:      vaultEngine.warpMode,
            score:     vaultEngine.totalLuminance,
            spins:     vaultEngine.spinCount,
            fusions:   vaultEngine.totalFusionsPerformed,
            bestCombo: vaultEngine.peakCascade,
            apex:      vaultEngine.apexTierReached,
            won:       won
        )
    }

    // MARK: - Navigation

    func goBackToMenu() {
        guard let view = view else { return }
        let menu = CelestialArena(size: size)
        menu.scaleMode = .aspectFill
        view.presentScene(menu, transition: SKTransition.fade(withDuration: 0.5))
    }
}
