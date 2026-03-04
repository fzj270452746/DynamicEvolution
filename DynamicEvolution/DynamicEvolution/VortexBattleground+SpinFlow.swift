// VortexBattleground+SpinFlow.swift — Spin & Fusion Logic
import SpriteKit

extension VortexBattleground {

    // MARK: - Spin Flow
    func performSpin() {
        isAnimating = true
        setSpinButtonEnabled(false)

        // Remember which slots were empty before spin (these will get new symbols)
        let emptyBefore = Set(vaultEngine.gridCells.indices.filter { vaultEngine.gridCells[$0] == nil })
        let isFirstSpin = vaultEngine.gridCells.isEmpty

        let newGrid = vaultEngine.executeSpin()

        // slot machine style: stagger by column (left to right)
        for (i, tile) in tileNodes.enumerated() {
            guard let tier = newGrid[i] else { continue }
            if isFirstSpin || emptyBefore.contains(i) {
                // Animate only newly filled slots
                let col = i % 4
                let row = i / 4
                let colDelay = Double(col) * 0.25
                let rowDelay = Double(row) * 0.03
                tile.playSpinReveal(finalTier: tier, delay: colDelay + rowDelay)
            }
            // Existing tiles stay as they are — no animation needed
        }

        // total wait: 3 columns * 0.25 + 3 rows * 0.03 + flicker(8*0.06) + pop(0.18) + buffer
        let totalDelay = 0.75 + 0.09 + 0.48 + 0.18 + 0.1
        run(SKAction.wait(forDuration: totalDelay)) { [weak self] in
            self?.processFusion()
        }
    }

    func processFusion() {
        let result = vaultEngine.runFusionCycle()

        if result.comboCount == 0 {
            finishRound(result: result)
            return
        }

        // animate steps sequentially
        animateFusionSteps(result.steps, stepIndex: 0, result: result)
    }

    func animateFusionSteps(_ steps: [NexusVault.FusionStep], stepIndex: Int, result: NexusVault.FusionResult) {
        guard stepIndex < steps.count else {
            // all steps done
            showComboLabel(result.comboCount)
            if result.comboCount >= 3 { shakeScreen() }
            run(SKAction.wait(forDuration: 0.3)) { [weak self] in
                self?.finishRound(result: result)
            }
            return
        }

        let step = steps[stepIndex]
        let baseIdx = step.baseIndex
        let consumed = step.consumedIndices

        // 1. highlight the 3 matching tiles
        let gold = UIColor(red:1, green:0.84, blue:0, alpha:1)
        tileNodes[baseIdx].bgHighlight(color: gold)
        for ci in consumed { tileNodes[ci].bgHighlight(color: gold) }

        // 2. after brief highlight, fly consumed tiles to base and remove
        run(SKAction.wait(forDuration: 0.25)) { [weak self] in
            guard let self = self else { return }
            let basePos = self.tileNodes[baseIdx].position

            for ci in consumed {
                let tile = self.tileNodes[ci]
                let flyTo = self.convert(basePos, to: tile.parent ?? self)
                let move  = SKAction.move(to: flyTo, duration: 0.25)
                move.timingMode = .easeIn
                let shrink = SKAction.scale(to: 0.3, duration: 0.25)
                let fade   = SKAction.fadeAlpha(to: 0.3, duration: 0.25)
                tile.run(SKAction.group([move, shrink, fade])) {
                    // reset position and show as empty slot
                    tile.position = self.tilePosition(index: ci)
                    tile.setScale(1.0)
                    tile.alpha = 1.0
                    tile.showAsEmptySlot()
                }
            }

            // 3. after fly completes, upgrade base tile with pop
            self.run(SKAction.wait(forDuration: 0.3)) {
                self.tileNodes[baseIdx].updateTier(step.resultTier)
                self.tileNodes[baseIdx].playFusionPop(color: gold)

                // combo counter
                let comboSoFar = stepIndex + 1
                if comboSoFar > 1 {
                    self.showComboLabel(comboSoFar)
                }

                // next step
                self.run(SKAction.wait(forDuration: 0.35)) {
                    self.animateFusionSteps(steps, stepIndex: stepIndex + 1, result: result)
                }
            }
        }
    }

    func finishRound(result: NexusVault.FusionResult) {
        // new apex flash
        if let apex = result.newApex {
            flashNewApex(tier: apex)
        }

        // score pop
        if result.scoreGained > 0 {
            showScorePop(result.scoreGained)
        }

        updateHUD()

        // check game over
        run(SKAction.wait(forDuration: result.newApex != nil ? 1.2 : 0.3)) { [weak self] in
            self?.checkGameState()
        }
    }

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
