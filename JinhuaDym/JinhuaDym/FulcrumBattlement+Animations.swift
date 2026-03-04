import UIKit

extension FulcrumBattlement {

    // MARK: - Reveal Phase

    func animateRevealPhase(completion: @escaping () -> Void) {
        let lattice = nucleus.lattice
        let flickDuration: TimeInterval = 0.06 * 8

        for i in 0..<16 {
            guard i < lattice.count, let rank = lattice[i] else { continue }
            let cell = gridView.cellForItem(at: IndexPath(item: i, section: 0)) as? IncunableCell
            let delay = Double(i) * 0.03
            cell?.performReveal(finalRank: rank, delay: delay)
        }

        let totalDelay = flickDuration + Double(15) * 0.03 + 0.15
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            completion()
        }
    }

    // MARK: - Amalgam Chain

    func animateAmalgamChain(steps: [ApothicNucleus.AmalgamStep], completion: @escaping () -> Void) {
        guard !steps.isEmpty else { completion(); return }

        var stepIndex = 0
        let stepDelay: TimeInterval = 0.55

        func nextStep() {
            guard stepIndex < steps.count else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    completion()
                }
                return
            }

            let step = steps[stepIndex]
            stepIndex += 1

            for idx in step.absorbedIndices {
                let cell = gridView.cellForItem(at: IndexPath(item: idx, section: 0)) as? IncunableCell
                cell?.performAmalgamPop(tint: step.sourceRank.pigment)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                for idx in step.absorbedIndices {
                    let cell = self.gridView.cellForItem(at: IndexPath(item: idx, section: 0)) as? IncunableCell
                    cell?.configureAsVacant()
                }

                let anchorCell = self.gridView.cellForItem(at: IndexPath(item: step.anchorIndex, section: 0)) as? IncunableCell
                anchorCell?.configureWith(rank: step.productRank)
                anchorCell?.highlightBorder(tint: step.productRank.pigment)

                self.gridView.reloadData()
                self.refreshHUD()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + stepDelay) {
                nextStep()
            }
        }

        nextStep()
    }

    // MARK: - Chain Banner

    func animateChainBanner(depth: Int) {
        guard depth >= 2 else { return }

        chainLabel.text = "⚡ CHAIN ×\(depth) ⚡"
        chainLabel.alpha = 0
        chainLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0) {
            self.chainLabel.alpha = 1
            self.chainLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.chainLabel.transform = .identity
            }
            UIView.animate(withDuration: 0.3, delay: 1.2) {
                self.chainLabel.alpha = 0
            }
        }
    }

    // MARK: - Zenith Flash

    func flashZenith(rank: MorphRank) {
        let lattice = nucleus.lattice
        for i in 0..<lattice.count {
            guard lattice[i] == rank else { continue }
            let cell = gridView.cellForItem(at: IndexPath(item: i, section: 0)) as? IncunableCell
            cell?.performZenithFlash(tint: rank.pigment)
        }

        zenithLabel.text = "ZENITH: \(rank.designation)"
        zenithLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0) {
            self.zenithLabel.transform = .identity
        }
    }
}
