// VortexBattleground+EndGame.swift — Timer, End Game & Navigation
import SpriteKit

extension VortexBattleground {

    // MARK: - Timer (Timed Blitz)
    override func update(_ currentTime: TimeInterval) {
        guard case .timedBlitz = vaultEngine.warpMode else { return }
        guard !timedGameOver else { return }

        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        timeRemaining -= dt
        if timeRemaining <= 0 {
            timeRemaining = 0
            timedGameOver = true
            endTimedBlitz()
        }

        let secs = Int(ceil(timeRemaining))
        timerLbl.text = "⏱ \(secs)s"
        timerLbl.fontColor = secs <= 10
            ? UIColor(red:1,green:0.19,blue:0.19,alpha:1)
            : UIColor(red:1,green:0.84,blue:0,alpha:1)
    }

    func endTimedBlitz() {
        isAnimating = true
        setSpinButtonEnabled(false)

        // save to leaderboard
        let stats = vaultEngine.apexTierStats()
        NexusVault.saveToLeaderboard(
            score: vaultEngine.totalLuminance,
            apexTier: stats?.tier,
            apexCount: stats?.count ?? 0
        )

        // short delay then show result
        run(SKAction.wait(forDuration: 0.5)) { [weak self] in
            self?.showTimedEndOverlay()
        }
    }

    func showTimedEndOverlay() {
        let stats = vaultEngine.apexTierStats()
        let overlay = PhantomOverlay(size: size, kind: .timedResult(
            score: vaultEngine.totalLuminance,
            apexTier: stats?.tier.labelText ?? "—",
            apexCount: stats?.count ?? 0
        ))
        overlay.zPosition = 100
        overlay.onDismiss = { [weak self] in
            self?.goBackToMenu()
        }
        addChild(overlay)
    }

    // MARK: - End Game
    func showEndOverlay(won: Bool) {
        let apexText = vaultEngine.apexTierReached?.labelText ?? "—"
        let score = vaultEngine.totalLuminance

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
            guard let self = self else { return }
            if case .questRun(let lvl) = self.vaultEngine.warpMode {
                let nextLvl = lvl + 1
                NexusVault.saveQuestLevel(nextLvl)
                self.vaultEngine.configureWarpMode(.questRun(level: nextLvl))
                self.tileNodes.forEach { $0.showAsEmptySlot() }
                self.isAnimating = false
                self.setSpinButtonEnabled(true)
                self.updateHUD()
            }
        }
        addChild(overlay)
    }

    func restartGame() {
        tileNodes.forEach { $0.showAsEmptySlot() }
        isAnimating = false
        setSpinButtonEnabled(true)
        updateHUD()
    }

    func goBackToMenu() {
        guard let view = view else { return }
        let menu = CelestialArena(size: size)
        menu.scaleMode = .aspectFill
        view.presentScene(menu, transition: SKTransition.fade(withDuration: 0.5))
    }
}
