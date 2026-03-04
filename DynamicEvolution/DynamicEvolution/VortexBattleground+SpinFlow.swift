// VortexBattleground+SpinFlow.swift — Spin & Fusion Logic
import SpriteKit
import UIKit

// MARK: - VortexBattleground: Spin & Fusion Flow

extension VortexBattleground {

    // MARK: - Spin Execution

    func performSpin() {
        isAnimating = true
        setSpinButtonEnabled(false)
        triggerHaptic(.medium)

        let emptyBefore = Set(vaultEngine.gridCells.indices.filter { vaultEngine.gridCells[$0] == nil })
        let isFirstSpin = vaultEngine.gridCells.isEmpty

        let newGrid = vaultEngine.executeSpin()

        for (i, tile) in tileNodes.enumerated() {
            guard let tier = newGrid[i] else { continue }
            guard isFirstSpin || emptyBefore.contains(i) else { continue }
            let delay = spiralRevealDelay(for: i)
            tile.playSpinReveal(finalTier: tier, delay: delay)
        }

        run(SKAction.wait(forDuration: spiralTotalDuration())) { [weak self] in
            self?.processFusion()
        }
    }

    /// Spiral reveal: tiles closest to center appear first, radiating outward.
    private func spiralRevealDelay(for index: Int) -> TimeInterval {
        let row = index / 4
        let col = index % 4
        let cr  = 1.5
        let cc  = 1.5
        let dist = max(abs(Double(row) - cr), abs(Double(col) - cc))
        return dist * 0.22
    }

    private func spiralTotalDuration() -> TimeInterval {
        // max dist 1.5 * 0.22 + flicker (8*0.06) + pop + buffer
        return 0.33 + 0.48 + 0.18 + 0.15
    }

    // MARK: - Fusion Processing

    func processFusion() {
        let result = vaultEngine.runFusionCycle()

        if result.comboCount == 0 {
            if vaultEngine.dormantStreak >= 2 {
                showDormantWarning()
            }
            if vaultEngine.dormantStreak >= 3 && vaultEngine.spinCount >= 3 {
                showStrategyTip()
            }
            finishRound(result: result)
            return
        }

        triggerHaptic(.light)
        animateFusionSteps(result.steps, stepIndex: 0, result: result)
    }

    // MARK: - Fusion Step Animation

    func animateFusionSteps(
        _ steps: [NexusVault.FusionStep],
        stepIndex: Int,
        result: NexusVault.FusionResult
    ) {
        guard stepIndex < steps.count else {
            showComboLabel(result.comboCount)
            if result.comboCount >= 3 {
                shakeScreen()
                triggerHaptic(.heavy)
            }
            run(SKAction.wait(forDuration: 0.3)) { [weak self] in
                self?.finishRound(result: result)
            }
            return
        }

        let step     = steps[stepIndex]
        let baseIdx  = step.baseIndex
        let consumed = step.consumedIndices
        let teal     = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)

        tileNodes[baseIdx].bgHighlight(color: teal)
        consumed.forEach { tileNodes[$0].bgHighlight(color: teal) }

        run(SKAction.wait(forDuration: 0.25)) { [weak self] in
            guard let self = self else { return }
            self.animateConsumedTiles(consumed, toward: baseIdx)

            self.run(SKAction.wait(forDuration: 0.3)) {
                self.applyFusionUpgrade(
                    baseIdx: baseIdx,
                    step: step,
                    stepIndex: stepIndex,
                    steps: steps,
                    result: result,
                    highlightColor: teal
                )
            }
        }
    }

    private func animateConsumedTiles(_ consumed: [Int], toward baseIdx: Int) {
        let basePos = tileNodes[baseIdx].position

        for ci in consumed {
            let tile  = tileNodes[ci]
            let flyTo = convert(basePos, to: tile.parent ?? self)
            let move  = SKAction.move(to: flyTo, duration: 0.25)
            move.timingMode = .easeIn
            let shrink = SKAction.scale(to: 0.3, duration: 0.25)
            let fade   = SKAction.fadeAlpha(to: 0.3, duration: 0.25)

            tile.run(SKAction.group([move, shrink, fade])) { [weak tile, weak self] in
                guard let tile = tile, let self = self else { return }
                tile.position = self.tilePosition(index: ci)
                tile.setScale(1.0)
                tile.alpha = 1.0
                tile.showAsEmptySlot()
            }
        }
    }

    private func applyFusionUpgrade(
        baseIdx: Int,
        step: NexusVault.FusionStep,
        stepIndex: Int,
        steps: [NexusVault.FusionStep],
        result: NexusVault.FusionResult,
        highlightColor: UIColor
    ) {
        tileNodes[baseIdx].updateTier(step.resultTier)
        tileNodes[baseIdx].playFusionPop(color: highlightColor)
        triggerHaptic(.light)

        let comboSoFar = stepIndex + 1
        if comboSoFar > 1 { showComboLabel(comboSoFar) }

        run(SKAction.wait(forDuration: 0.35)) { [weak self] in
            self?.animateFusionSteps(steps, stepIndex: stepIndex + 1, result: result)
        }
    }

    // MARK: - Round Completion

    func finishRound(result: NexusVault.FusionResult) {
        if let apex = result.newApex {
            flashNewApex(tier: apex)
            triggerHaptic(.heavy)
        }

        if result.scoreGained > 0 {
            showScorePop(result.scoreGained)
        }

        updateHUD()

        let postDelay: TimeInterval = result.newApex != nil ? 1.2 : 0.3
        run(SKAction.wait(forDuration: postDelay)) { [weak self] in
            self?.checkGameState()
        }
    }

    func checkGameState() {
        if vaultEngine.isQuestComplete {
            triggerHaptic(.heavy)
            if case .dailyChallenge = vaultEngine.warpMode {
                showDailyEndOverlay(won: true)
            } else {
                showEndOverlay(won: true)
            }
        } else if vaultEngine.isQuestFailed {
            triggerHaptic(.medium)
            if case .dailyChallenge = vaultEngine.warpMode {
                showDailyEndOverlay(won: false)
            } else {
                showEndOverlay(won: false)
            }
        } else {
            isAnimating = false
            setSpinButtonEnabled(true)
        }
    }

    // MARK: - Haptic Feedback

    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
    }
}
