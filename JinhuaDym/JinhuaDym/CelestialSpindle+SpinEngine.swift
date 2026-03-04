import UIKit

extension CelestialSpindle {

    // MARK: - Spin Trigger

    @objc func didTapSpin() {
        guard !isSpinning else { return }
        isSpinning = true
        setSpinEnabled(false)
        resultLabel.alpha = 0

        sessionSpins += 1
        reelsStoppedCount = 0

        let result = generateSpinResult()
        for i in 0..<3 {
            reelTargets[i] = result[i]
            reelTickCounts[i] = 0
            startReelSpin(index: i)
        }

        saveProgress()
    }

    // MARK: - Two-Phase Result Generation

    func generateSpinResult() -> [MorphRank] {
        let outcome = rollOutcome()
        switch outcome {
        case .tripleMatch:
            let rank = pickWeighted(from: Self.matchTierWeights)
            return [rank, rank, rank]

        case .nearMiss:
            let pairRank = pickWeighted(from: Self.symbolWeights)
            var thirdRank: MorphRank
            repeat {
                thirdRank = pickWeighted(from: Self.symbolWeights)
            } while thirdRank == pairRank
            var slots = [pairRank, pairRank, thirdRank]
            slots.shuffle()
            return slots

        case .allDifferent:
            var picked: [MorphRank] = []
            var remaining = Self.symbolWeights
            for _ in 0..<3 {
                let rank = pickWeighted(from: remaining)
                picked.append(rank)
                remaining.removeAll { $0.rank == rank }
            }
            picked.shuffle()
            return picked
        }
    }

    func rollOutcome() -> SpinOutcome {
        let total = Self.outcomeTable.reduce(0.0) { $0 + $1.weight }
        var dice = Double.random(in: 0..<total)
        for entry in Self.outcomeTable {
            if dice < entry.weight { return entry.outcome }
            dice -= entry.weight
        }
        return .nearMiss
    }

    func pickWeighted(from table: [(rank: MorphRank, weight: Double)]) -> MorphRank {
        let total = table.reduce(0.0) { $0 + $1.weight }
        var dice = Double.random(in: 0..<total)
        for entry in table {
            if dice < entry.weight { return entry.rank }
            dice -= entry.weight
        }
        return table.last?.rank ?? .germinal
    }

    // MARK: - Reel Spinning

    func startReelSpin(index: Int) {
        let maxTicks = Self.maxTicksPerReel[index]
        reelTimers[index] = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
            self.reelTickCounts[index] += 1
            let tick = self.reelTickCounts[index]

            if tick >= maxTicks {
                timer.invalidate()
                self.reelTimers[index] = nil
                self.settleReel(index: index, finalRank: self.reelTargets[index])
                return
            }

            let remaining = maxTicks - tick
            if remaining <= 5 {
                timer.invalidate()
                self.reelTimers[index] = nil
                self.decelerateReel(index: index, remaining: remaining)
                return
            }

            let randomRank = MorphRank.allCases.randomElement() ?? .germinal
            self.applyReelSymbol(index: index, rank: randomRank, animated: true)
        }
    }

    func decelerateReel(index: Int, remaining: Int) {
        let intervals: [TimeInterval] = [0.08, 0.12, 0.18, 0.25, 0.35]
        var step = 5 - remaining

        func nextTick() {
            guard step < 5 else {
                settleReel(index: index, finalRank: reelTargets[index])
                return
            }
            let delay = intervals[min(step, intervals.count - 1)]
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                if step < 4 {
                    let randomRank = MorphRank.allCases.randomElement() ?? .germinal
                    self.applyReelSymbol(index: index, rank: randomRank, animated: true)
                } else {
                    self.applyReelSymbol(index: index, rank: self.reelTargets[index], animated: true)
                }
                step += 1
                nextTick()
            }
        }
        nextTick()
    }

    func settleReel(index: Int, finalRank: MorphRank) {
        reelResults[index] = finalRank
        applyReelSymbol(index: index, rank: finalRank, animated: false)

        UIView.animate(withDuration: 0.06, animations: {
            self.reelContainers[index].transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.08) {
                self.reelContainers[index].transform = .identity
            }
        }

        reelContainers[index].layer.borderColor = finalRank.pigment.withAlphaComponent(0.7).cgColor

        reelsStoppedCount += 1
        if reelsStoppedCount == 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.evaluateResult()
            }
        }
    }

    func applyReelSymbol(index: Int, rank: MorphRank, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.03) {
                self.reelImageViews[index].transform = CGAffineTransform(translationX: 0, y: -8)
                self.reelImageViews[index].alpha = 0.3
            } completion: { _ in
                self.reelImageViews[index].image = UIImage(named: rank.iconAsset)
                self.reelImageViews[index].transform = CGAffineTransform(translationX: 0, y: 8)
                UIView.animate(withDuration: 0.03) {
                    self.reelImageViews[index].transform = .identity
                    self.reelImageViews[index].alpha = 1
                }
            }
            reelLevelLabels[index].text = "Lv\(rank.rawValue)"
            reelLevelLabels[index].textColor = rank.pigment
        } else {
            reelImageViews[index].image = UIImage(named: rank.iconAsset)
            reelImageViews[index].transform = .identity
            reelImageViews[index].alpha = 1
            reelLevelLabels[index].text = "Lv\(rank.rawValue)"
            reelLevelLabels[index].textColor = rank.pigment
        }
    }

    // MARK: - Result Evaluation

    func evaluateResult() {
        let r0 = reelResults[0]
        let r1 = reelResults[1]
        let r2 = reelResults[2]

        if r0 == r1 && r1 == r2 {
            let xpGain = Self.matchRewards[r0.rawValue - 1]
            currentXP += xpGain
            checkLevelUp()
            showMatchResult(rank: r0, xp: xpGain)
        } else {
            showNoMatch()
        }

        saveProgress()
        refreshUI()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isSpinning = false
            self?.setSpinEnabled(true)
        }
    }

    func checkLevelUp() {
        guard currentLevel != .celestial else { return }
        let nextLevelRaw = currentLevel.rawValue + 1
        guard nextLevelRaw <= Self.xpThresholds.count else { return }
        let threshold = Self.xpThresholds[nextLevelRaw - 1]

        if currentXP >= threshold, let nextRank = MorphRank(rawValue: nextLevelRaw) {
            currentLevel = nextRank
            showLevelUpCelebration(newLevel: nextRank)
            if currentLevel != .celestial {
                checkLevelUp()
            }
        }
    }

    // MARK: - Button State

    func setSpinEnabled(_ enabled: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.invokeButton.alpha = enabled ? 1.0 : 0.45
        }
        invokeButton.isUserInteractionEnabled = enabled
    }
}
