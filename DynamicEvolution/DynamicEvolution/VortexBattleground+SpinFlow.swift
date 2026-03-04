// VortexBattleground+SpinFlow.swift — Spin & Fusion Logic
import SpriteKit

// MARK: - VortexBattleground: Spin & Fusion Flow

extension VortexBattleground {

    // MARK: - Spin Execution

    /// Begin a spin: sample glyphs into empty slots, animate reveals column-by-column,
    /// then hand off to fusion resolution when all animations settle.
    func performSpin() {
        isAnimating = true
        setSpinButtonEnabled(false)

        // Capture which slots were empty before this spin (they'll receive new symbols)
        let emptyBefore  = Set(vaultEngine.gridCells.indices.filter { vaultEngine.gridCells[$0] == nil })
        let isFirstSpin  = vaultEngine.gridCells.isEmpty

        // Sample glyphs and update the model
        let newGrid = vaultEngine.executeSpin()

        // Animate only newly filled tiles using a slot-machine cascade delay
        for (i, tile) in tileNodes.enumerated() {
            guard let tier = newGrid[i] else { continue }
            guard isFirstSpin || emptyBefore.contains(i) else { continue }
            let delay = columnRevealDelay(for: i)
            tile.playSpinReveal(finalTier: tier, delay: delay)
        }

        // Wait for the full animation window, then resolve fusions
        run(SKAction.wait(forDuration: totalRevealDuration())) { [weak self] in
            self?.processFusion()
        }
    }

    /// Stagger delay for tile at index `i` based on column then row offset.
    /// Creates a left-to-right, top-to-bottom waterfall reveal effect.
    private func columnRevealDelay(for index: Int) -> TimeInterval {
        let col = index % 4
        let row = index / 4
        return Double(col) * 0.25 + Double(row) * 0.03
    }

    /// Total duration to wait before starting fusion processing.
    /// Accounts for: max column stagger + max row stagger + flicker time + pop + buffer.
    private func totalRevealDuration() -> TimeInterval {
        // column stagger (3 * 0.25) + row stagger (3 * 0.03) + flicker (8 * 0.06) + pop + buffer
        return 0.75 + 0.09 + 0.48 + 0.18 + 0.1
    }

    // MARK: - Fusion Processing

    /// Ask the engine to resolve all pending fusions, then either animate the steps
    /// or skip straight to round completion if no fusions occurred.
    func processFusion() {
        let result = vaultEngine.runFusionCycle()

        if result.comboCount == 0 {
            // No fusions — immediately finish the round
            finishRound(result: result)
            return
        }

        // Animate each fusion step in sequence before finishing
        animateFusionSteps(result.steps, stepIndex: 0, result: result)
    }

    // MARK: - Fusion Step Animation

    /// Recursively animate one fusion step at a time:
    /// highlight → consume fly → upgrade pop → recurse.
    func animateFusionSteps(
        _ steps: [NexusVault.FusionStep],
        stepIndex: Int,
        result: NexusVault.FusionResult
    ) {
        guard stepIndex < steps.count else {
            // All steps complete — show combo label and shake on large cascades
            showComboLabel(result.comboCount)
            if result.comboCount >= 3 { shakeScreen() }
            run(SKAction.wait(forDuration: 0.3)) { [weak self] in
                self?.finishRound(result: result)
            }
            return
        }

        let step     = steps[stepIndex]
        let baseIdx  = step.baseIndex
        let consumed = step.consumedIndices
        let gold     = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)

        // Phase 1: Highlight all three matched tiles simultaneously
        tileNodes[baseIdx].bgHighlight(color: gold)
        consumed.forEach { tileNodes[$0].bgHighlight(color: gold) }

        // Phase 2: Animate consumed tiles flying toward the base tile and vanishing
        run(SKAction.wait(forDuration: 0.25)) { [weak self] in
            guard let self = self else { return }
            self.animateConsumedTiles(consumed, toward: baseIdx)

            // Phase 3: After the fly completes, upgrade the base tile with a pop
            self.run(SKAction.wait(forDuration: 0.3)) {
                self.applyFusionUpgrade(
                    baseIdx: baseIdx,
                    step: step,
                    stepIndex: stepIndex,
                    steps: steps,
                    result: result,
                    highlightColor: gold
                )
            }
        }
    }

    /// Animate two consumed tiles shrinking and flying toward the base tile position.
    private func animateConsumedTiles(_ consumed: [Int], toward baseIdx: Int) {
        let basePos = tileNodes[baseIdx].position

        for ci in consumed {
            let tile   = tileNodes[ci]
            let flyTo  = convert(basePos, to: tile.parent ?? self)
            let move   = SKAction.move(to: flyTo, duration: 0.25)
            move.timingMode = .easeIn
            let shrink = SKAction.scale(to: 0.3, duration: 0.25)
            let fade   = SKAction.fadeAlpha(to: 0.3, duration: 0.25)

            tile.run(SKAction.group([move, shrink, fade])) { [weak tile, weak self] in
                guard let tile = tile, let self = self else { return }
                // Reset consumed tile to empty slot at its original position
                tile.position = self.tilePosition(index: ci)
                tile.setScale(1.0)
                tile.alpha = 1.0
                tile.showAsEmptySlot()
            }
        }
    }

    /// Upgrade the base tile to the result tier and trigger the pop animation,
    /// then advance to the next fusion step after a short delay.
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

        // Show running combo counter after the first fusion
        let comboSoFar = stepIndex + 1
        if comboSoFar > 1 { showComboLabel(comboSoFar) }

        // Advance to the next fusion step
        run(SKAction.wait(forDuration: 0.35)) { [weak self] in
            self?.animateFusionSteps(steps, stepIndex: stepIndex + 1, result: result)
        }
    }

    // MARK: - Round Completion

    /// Finalize the round: trigger apex flash, score pop, HUD refresh, and game-state check.
    func finishRound(result: NexusVault.FusionResult) {
        if let apex = result.newApex {
            flashNewApex(tier: apex)
        }

        if result.scoreGained > 0 {
            showScorePop(result.scoreGained)
        }

        updateHUD()

        // Delay before evaluating win/lose/continue so effects are visible
        let postDelay: TimeInterval = result.newApex != nil ? 1.2 : 0.3
        run(SKAction.wait(forDuration: postDelay)) { [weak self] in
            self?.checkGameState()
        }
    }

    /// Evaluate the current game state and either end the game or re-enable the spin button.
    func checkGameState() {
        if vaultEngine.isQuestComplete {
            showEndOverlay(won: true)
        } else if vaultEngine.isQuestFailed {
            showEndOverlay(won: false)
        } else {
            isAnimating = false
            setSpinButtonEnabled(true)
        }
    }
}
