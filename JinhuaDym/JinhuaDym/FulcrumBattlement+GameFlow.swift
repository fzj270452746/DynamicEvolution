import UIKit

extension FulcrumBattlement {

    // MARK: - Invoke Action

    @objc func didTapInvoke() {
        guard !isPerforming else { return }
        if chronoExpired { return }
        isPerforming = true
        invokeButton.isEnabled = false

        nucleus.dispenseTurn()

        animateRevealPhase {
            let outcome = self.nucleus.resolveAmalgamations()

            if outcome.steps.isEmpty {
                self.onTurnResolved(outcome)
            } else {
                self.animateAmalgamChain(steps: outcome.steps) {
                    self.onTurnResolved(outcome)
                }
            }
        }
    }

    // MARK: - Turn Resolution

    func onTurnResolved(_ outcome: ApothicNucleus.AmalgamOutcome) {
        refreshHUD()

        if outcome.chainLength > 0 {
            animateChainBanner(depth: outcome.chainLength)
        }

        if let apex = outcome.newZenith {
            flashZenith(rank: apex)
        }

        if case .odyssey(let stg) = sessionMode {
            if nucleus.isOdysseyAccomplished {
                ApothicNucleus.preserveStage(stg + 1)
                let zenith = nucleus.zenithRank?.designation ?? "—"
                let zenithCount = nucleus.zenithStatistics()?.quantity ?? 0
                ApothicNucleus.archiveRanking(
                    points: nucleus.cumulativePoints,
                    zenithRank: nucleus.zenithRank,
                    zenithQuantity: zenithCount
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presentResultSheet(
                        .odysseyVictory(points: self.nucleus.cumulativePoints, zenith: zenith, stage: stg)
                    )
                }
                return
            }

            if nucleus.isOdysseyForfeited {
                let zenith = nucleus.zenithRank?.designation ?? "—"
                let zenithCount = nucleus.zenithStatistics()?.quantity ?? 0
                ApothicNucleus.archiveRanking(
                    points: nucleus.cumulativePoints,
                    zenithRank: nucleus.zenithRank,
                    zenithQuantity: zenithCount
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presentResultSheet(
                        .defeat(points: self.nucleus.cumulativePoints, zenith: zenith)
                    )
                }
                return
            }
        }

        isPerforming = false
        invokeButton.isEnabled = true
    }

    // MARK: - Chrono Countdown

    func beginCountdown() {
        chronoRemaining = 90
        lastFrameTime = CACurrentMediaTime()

        let link = CADisplayLink(target: self, selector: #selector(frameUpdate(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    @objc func frameUpdate(_ link: CADisplayLink) {
        let now = CACurrentMediaTime()
        let dt = now - lastFrameTime
        lastFrameTime = now

        chronoRemaining -= dt
        if chronoRemaining <= 0 {
            chronoRemaining = 0
            chronoExpired = true
            displayLink?.invalidate()
            displayLink = nil

            refreshHUD()
            finishChronoSession()
            return
        }

        let secs = Int(ceil(chronoRemaining))
        countdownLabel.text = "⏱ \(secs)s"
        countdownLabel.textColor = secs <= 10
            ? UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)
            : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
    }

    func finishChronoSession() {
        let stats = nucleus.zenithStatistics()
        let zenithName = stats?.rank.designation ?? "—"
        let zenithCount = stats?.quantity ?? 0
        ApothicNucleus.archiveRanking(
            points: nucleus.cumulativePoints,
            zenithRank: nucleus.zenithRank,
            zenithQuantity: zenithCount
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.presentResultSheet(
                .chronoResult(
                    points: self.nucleus.cumulativePoints,
                    zenithName: zenithName,
                    zenithCount: zenithCount
                )
            )
        }
    }

    // MARK: - Result Presentation

    func presentResultSheet(_ facet: PenumbraSheet.Facet) {
        isPerforming = false
        invokeButton.isEnabled = false

        let sheet = PenumbraSheet(facet: facet)
        sheet.modalPresentationStyle = .overCurrentContext
        sheet.modalTransitionStyle = .crossDissolve

        sheet.onReturnToMenu = { [weak self] in
            self?.sceneDelegate?.battlementRequestsReturn()
        }

        sheet.onReplaySession = { [weak self] in
            guard let self = self else { return }
            self.nucleus.initializeBlueprint(self.sessionMode)
            self.chronoRemaining = 90
            self.chronoExpired = false
            self.gridView.reloadData()
            self.refreshHUD()
            self.isPerforming = false
            self.invokeButton.isEnabled = true
            if case .chronoSurge = self.sessionMode {
                self.beginCountdown()
            }
        }

        sheet.onAdvanceStage = { [weak self] in
            guard let self = self else { return }
            if case .odyssey(let stg) = self.sessionMode {
                let nextStage = stg + 1
                self.sessionMode = .odyssey(stage: nextStage)
                self.nucleus.initializeBlueprint(self.sessionMode)
                self.gridView.reloadData()
                self.refreshHUD()
                self.isPerforming = false
                self.invokeButton.isEnabled = true
            }
        }

        present(sheet, animated: true)
    }
}
