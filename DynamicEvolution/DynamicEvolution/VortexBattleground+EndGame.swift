// VortexBattleground+EndGame.swift — Timer, End Game & Navigation
import SpriteKit

// MARK: - VortexBattleground: End Game & Navigation

extension VortexBattleground {

    // MARK: - Per-Frame Update (Timed Blitz)

    /// Called each frame by SpriteKit. Handles the timed blitz countdown clock.
    override func update(_ currentTime: TimeInterval) {
        guard case .timedBlitz = vaultEngine.warpMode else { return }
        guard !timedGameOver else { return }

        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        timeRemaining -= dt

        // Flash the timer label when entering the 10-second danger zone
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

        // Live timer display update
        let secs = Int(ceil(timeRemaining))
        timerLbl.text      = "⏱ \(secs)s"
        timerLbl.fontColor = secs <= 10
            ? UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)
            : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
    }

    // MARK: - Timed Blitz End

    /// Handle the end of a timed blitz session: lock the board,
    /// save the result to the leaderboard, then show the result overlay.
    func endTimedBlitz() {
        isAnimating = true
        setSpinButtonEnabled(false)

        // Persist result before presenting overlay
        let stats = vaultEngine.apexTierStats()
        NexusVault.saveToLeaderboard(
            score:     vaultEngine.totalLuminance,
            apexTier:  stats?.tier,
            apexCount: stats?.count ?? 0
        )

        run(SKAction.wait(forDuration: 0.5)) { [weak self] in
            self?.showTimedEndOverlay()
        }
    }

    /// Build and add the timed blitz result overlay to the scene.
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

    // MARK: - Quest End Game

    /// Build and display the quest win or loss overlay.
    /// - Parameter won: `true` if the player fulfilled the quest goal before running out of spins.
    func showEndOverlay(won: Bool) {
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

    // MARK: - Quest Level Advancement

    /// Increment the quest level, persist the new maximum, reconfigure the engine,
    /// and reset the board so the player can continue without returning to the menu.
    private func advanceToNextQuestLevel() {
        guard case .questRun(let lvl) = vaultEngine.warpMode else { return }
        let nextLvl = lvl + 1
        NexusVault.saveQuestLevel(nextLvl)
        vaultEngine.configureWarpMode(.questRun(level: nextLvl))
        clearBoardForNextRound()
    }

    // MARK: - Game Reset

    /// Reset all tile visuals to empty and re-enable the spin button.
    /// Used by "Play Again" and level advancement flows.
    func restartGame() {
        clearBoardForNextRound()
    }

    /// Internal helper that clears the grid UI and restores interactivity.
    private func clearBoardForNextRound() {
        tileNodes.forEach { $0.showAsEmptySlot() }
        isAnimating = false
        setSpinButtonEnabled(true)
        updateHUD()
    }

    // MARK: - Navigation

    /// Transition back to the main menu scene using a fade effect.
    func goBackToMenu() {
        guard let view = view else { return }
        let menu = CelestialArena(size: size)
        menu.scaleMode = .aspectFill
        view.presentScene(menu, transition: SKTransition.fade(withDuration: 0.5))
    }
}
