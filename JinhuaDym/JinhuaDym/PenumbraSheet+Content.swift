import UIKit

extension PenumbraSheet {

    // MARK: - Result Panel

    func buildResultContent(won: Bool, points: Int, zenith: String, stage: Int?) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(stack)

        let icon = UILabel()
        icon.text = won ? "🏆" : "💀"
        icon.font = UIFont.systemFont(ofSize: sv(52))
        icon.textAlignment = .center
        stack.addArrangedSubview(icon)

        let titleText: String
        if let stg = stage { titleText = "STAGE \(stg) CLEAR!" }
        else { titleText = won ? "TRIUMPH!" : "GAME OVER" }

        let titleLbl = UILabel()
        titleLbl.text = titleText
        titleLbl.font = UIFont.systemFont(ofSize: sv(28), weight: .heavy)
        titleLbl.textColor = won
            ? UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            : UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)
        titleLbl.textAlignment = .center
        stack.addArrangedSubview(titleLbl)

        let ptsLbl = UILabel()
        ptsLbl.text = "POINTS  \(points)"
        ptsLbl.font = UIFont.systemFont(ofSize: sv(22), weight: .bold)
        ptsLbl.textColor = UIColor(white: 0.95, alpha: 1)
        ptsLbl.textAlignment = .center
        stack.addArrangedSubview(ptsLbl)

        let zenLbl = UILabel()
        zenLbl.text = "ZENITH  \(zenith)"
        zenLbl.font = UIFont.systemFont(ofSize: sv(16), weight: .bold)
        zenLbl.textColor = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        zenLbl.textAlignment = .center
        stack.addArrangedSubview(zenLbl)

        let sep = makeSeparator()
        stack.addArrangedSubview(sep)
        sep.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.7).isActive = true

        if let stg = stage {
            let hasNext = stg < ApothicNucleus.stageManifest.count
            if hasNext {
                let nextBtn = makeActionButton(
                    title: "NEXT STAGE ▶",
                    color: UIColor(red: 1, green: 0.84, blue: 0, alpha: 1),
                    action: #selector(didTapAdvance)
                )
                stack.addArrangedSubview(nextBtn)
                nextBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
                nextBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
            }
        } else {
            let retryBtn = makeActionButton(
                title: "PLAY AGAIN",
                color: UIColor(red: 0, green: 0.83, blue: 1, alpha: 1),
                action: #selector(didTapReplay)
            )
            stack.addArrangedSubview(retryBtn)
            retryBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
            retryBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        }

        let menuBtn = makeActionButton(
            title: "MAIN MENU",
            color: UIColor(white: 0.6, alpha: 1),
            action: #selector(didTapMenu)
        )
        stack.addArrangedSubview(menuBtn)
        menuBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
        menuBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: panelView.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -32),
        ])
    }

    // MARK: - Chrono Result

    func buildChronoResultContent(points: Int, zenithName: String, zenithCount: Int) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(stack)

        let icon = UILabel()
        icon.text = "⏱"
        icon.font = UIFont.systemFont(ofSize: sv(48))
        stack.addArrangedSubview(icon)

        let titleLbl = UILabel()
        titleLbl.text = "TIME'S UP!"
        titleLbl.font = UIFont.systemFont(ofSize: sv(28), weight: .heavy)
        titleLbl.textColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        stack.addArrangedSubview(titleLbl)

        let ptsLbl = UILabel()
        ptsLbl.text = "POINTS  \(points)"
        ptsLbl.font = UIFont.systemFont(ofSize: sv(22), weight: .bold)
        ptsLbl.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        stack.addArrangedSubview(ptsLbl)

        let bestText = zenithCount > 0 ? "BEST  \(zenithCount) × \(zenithName)" : "BEST  —"
        let bestLbl = UILabel()
        bestLbl.text = bestText
        bestLbl.font = UIFont.systemFont(ofSize: sv(16), weight: .medium)
        bestLbl.textColor = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        stack.addArrangedSubview(bestLbl)

        stack.addArrangedSubview(makeSeparator())

        let retryBtn = makeActionButton(title: "PLAY AGAIN", color: UIColor(red: 0, green: 0.83, blue: 1, alpha: 1), action: #selector(didTapReplay))
        stack.addArrangedSubview(retryBtn)
        retryBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
        retryBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        let menuBtn = makeActionButton(title: "MAIN MENU", color: UIColor(white: 0.6, alpha: 1), action: #selector(didTapMenu))
        stack.addArrangedSubview(menuBtn)
        menuBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
        menuBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: panelView.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -32),
        ])
    }

    // MARK: - Rankings

    func buildRankingsContent() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(stack)

        let titleLbl = UILabel()
        titleLbl.text = "RANKINGS"
        titleLbl.font = UIFont.systemFont(ofSize: sv(24), weight: .heavy)
        titleLbl.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        stack.addArrangedSubview(titleLbl)
        stack.addArrangedSubview(makeSeparator())

        let entries = ApothicNucleus.fetchRankings()
        if entries.isEmpty {
            let empty = UILabel()
            empty.text = "No records yet"
            empty.font = UIFont.systemFont(ofSize: sv(16), weight: .medium)
            empty.textColor = UIColor(white: 0.5, alpha: 1)
            stack.addArrangedSubview(empty)
        } else {
            let medals = ["🥇", "🥈", "🥉"]
            for (i, entry) in entries.prefix(10).enumerated() {
                let row = buildRankingRow(
                    rank: i < 3 ? medals[i] : "#\(i + 1)",
                    score: "\(entry.points)",
                    detail: buildRankDetail(entry),
                    isTop3: i < 3,
                    isEven: i.isMultiple(of: 2)
                )
                stack.addArrangedSubview(row)
                row.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -20).isActive = true
                row.heightAnchor.constraint(equalToConstant: 32).isActive = true
            }
        }

        stack.addArrangedSubview(makeSpacer(height: 6))
        stack.addArrangedSubview(makeSeparator())
        stack.addArrangedSubview(makeSpacer(height: 4))

        let slotHeader = UILabel()
        slotHeader.text = "🎰 SLOT ASCENT"
        slotHeader.font = UIFont.systemFont(ofSize: sv(16), weight: .heavy)
        slotHeader.textColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
        stack.addArrangedSubview(slotHeader)

        let slotStats = CelestialSpindle.fetchSlotStats()
        let slotLevelName = MorphRank(rawValue: slotStats.levelRaw)?.designation ?? "Seed"
        let slotLevelColor = MorphRank(rawValue: slotStats.levelRaw)?.pigment ?? UIColor(white: 0.7, alpha: 1)

        let slotRow = UIView()
        slotRow.backgroundColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.08)
        slotRow.layer.cornerRadius = 6

        let rankIcon = UIImageView()
        if let slotRank = MorphRank(rawValue: slotStats.levelRaw) {
            rankIcon.image = UIImage(named: slotRank.iconAsset)
        }
        rankIcon.contentMode = .scaleAspectFit
        rankIcon.translatesAutoresizingMaskIntoConstraints = false
        slotRow.addSubview(rankIcon)

        let slotLevelLbl = UILabel()
        slotLevelLbl.text = "Rank: \(slotLevelName)"
        slotLevelLbl.font = UIFont.systemFont(ofSize: sv(14), weight: .bold)
        slotLevelLbl.textColor = slotLevelColor
        slotLevelLbl.translatesAutoresizingMaskIntoConstraints = false
        slotRow.addSubview(slotLevelLbl)

        let slotSpinsLbl = UILabel()
        slotSpinsLbl.text = "Spins: \(slotStats.spins)"
        slotSpinsLbl.font = UIFont.systemFont(ofSize: sv(13), weight: .medium)
        slotSpinsLbl.textColor = UIColor(white: 0.7, alpha: 1)
        slotSpinsLbl.textAlignment = .right
        slotSpinsLbl.translatesAutoresizingMaskIntoConstraints = false
        slotRow.addSubview(slotSpinsLbl)

        NSLayoutConstraint.activate([
            rankIcon.leadingAnchor.constraint(equalTo: slotRow.leadingAnchor, constant: 8),
            rankIcon.centerYAnchor.constraint(equalTo: slotRow.centerYAnchor),
            rankIcon.widthAnchor.constraint(equalToConstant: 28),
            rankIcon.heightAnchor.constraint(equalToConstant: 28),
            slotLevelLbl.leadingAnchor.constraint(equalTo: rankIcon.trailingAnchor, constant: 8),
            slotLevelLbl.centerYAnchor.constraint(equalTo: slotRow.centerYAnchor),
            slotSpinsLbl.trailingAnchor.constraint(equalTo: slotRow.trailingAnchor, constant: -8),
            slotSpinsLbl.centerYAnchor.constraint(equalTo: slotRow.centerYAnchor),
        ])

        stack.addArrangedSubview(slotRow)
        slotRow.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -20).isActive = true
        slotRow.heightAnchor.constraint(equalToConstant: 40).isActive = true

        stack.addArrangedSubview(makeSpacer(height: 6))

        let closeBtn = makeActionButton(title: "CLOSE", color: UIColor(white: 0.6, alpha: 1), action: #selector(didTapClose))
        stack.addArrangedSubview(closeBtn)
        closeBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.55).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: panelView.bottomAnchor, constant: -16),
            stack.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -32),
        ])
    }

    func buildRankDetail(_ entry: ApothicNucleus.RankingEntry) -> String {
        guard let rank = MorphRank(rawValue: entry.zenithLevel), entry.zenithQuantity > 0 else { return "—" }
        return "\(entry.zenithQuantity)×\(rank.designation)"
    }

    func buildRankingRow(rank: String, score: String, detail: String, isTop3: Bool, isEven: Bool) -> UIView {
        let container = UIView()
        if isEven {
            container.backgroundColor = UIColor(white: 1, alpha: 0.03)
        }
        container.layer.cornerRadius = 4

        let rankLbl = UILabel()
        rankLbl.text = rank
        rankLbl.font = UIFont.systemFont(ofSize: sv(14), weight: .bold)
        rankLbl.textColor = isTop3 ? UIColor(red: 1, green: 0.84, blue: 0, alpha: 1) : UIColor(white: 0.7, alpha: 1)
        rankLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(rankLbl)

        let scoreLbl = UILabel()
        scoreLbl.text = score
        scoreLbl.font = UIFont.systemFont(ofSize: sv(14), weight: .heavy)
        scoreLbl.textColor = UIColor(white: 0.95, alpha: 1)
        scoreLbl.textAlignment = .center
        scoreLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(scoreLbl)

        let detailLbl = UILabel()
        detailLbl.text = detail
        detailLbl.font = UIFont.systemFont(ofSize: sv(12), weight: .medium)
        detailLbl.textColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 0.9)
        detailLbl.textAlignment = .right
        detailLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(detailLbl)

        NSLayoutConstraint.activate([
            rankLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            rankLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            scoreLbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            scoreLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            detailLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            detailLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    // MARK: - Almanac

    func buildAlmanacContent() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(stack)

        let titleLbl = UILabel()
        titleLbl.text = "ALMANAC"
        titleLbl.font = UIFont.systemFont(ofSize: sv(24), weight: .heavy)
        titleLbl.textColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        stack.addArrangedSubview(titleLbl)
        stack.addArrangedSubview(makeSeparator())

        let header = buildAlmanacHeader()
        stack.addArrangedSubview(header)
        header.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -20).isActive = true
        stack.addArrangedSubview(makeSeparator())

        for rank in MorphRank.allCases {
            let row = buildAlmanacRow(rank: rank)
            stack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -20).isActive = true
            row.heightAnchor.constraint(equalToConstant: 46).isActive = true
        }

        stack.addArrangedSubview(makeSpacer(height: 8))

        let closeBtn = makeActionButton(title: "CLOSE", color: UIColor(white: 0.6, alpha: 1), action: #selector(didTapClose))
        stack.addArrangedSubview(closeBtn)
        closeBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.55).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: panelView.bottomAnchor, constant: -12),
            stack.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -20),
        ])
    }

    func buildAlmanacHeader() -> UIView {
        let container = UIView()
        let headers: [(String, NSLayoutConstraint.Axis)] = [("Symbol", .horizontal), ("Tier", .horizontal), ("Base Pts", .horizontal)]
        let labels = headers.map { text, _ -> UILabel in
            let lbl = UILabel()
            lbl.text = text
            lbl.font = UIFont.systemFont(ofSize: sv(10), weight: .medium)
            lbl.textColor = UIColor(white: 0.5, alpha: 1)
            lbl.translatesAutoresizingMaskIntoConstraints = false
            return lbl
        }
        labels.forEach { container.addSubview($0) }

        container.heightAnchor.constraint(equalToConstant: 20).isActive = true
        NSLayoutConstraint.activate([
            labels[0].leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            labels[0].centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labels[1].centerXAnchor.constraint(equalTo: container.centerXAnchor),
            labels[1].centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labels[2].trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            labels[2].centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        return container
    }

    func buildAlmanacRow(rank: MorphRank) -> UIView {
        let container = UIView()

        let icon = UIImageView(image: UIImage(named: rank.iconAsset))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)

        let nameLbl = UILabel()
        nameLbl.text = "Lv\(rank.rawValue)  \(rank.designation)"
        nameLbl.font = UIFont.systemFont(ofSize: sv(15), weight: .bold)
        nameLbl.textColor = rank.pigment
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLbl)

        let pts = rank.rawValue * rank.rawValue * 20
        let ptsText = rank.supplementalScore > 0 ? "\(pts)+\(rank.supplementalScore)pt" : "\(pts)pt"
        let ptsLbl = UILabel()
        ptsLbl.text = ptsText
        ptsLbl.font = UIFont.systemFont(ofSize: sv(13), weight: .medium)
        ptsLbl.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.9)
        ptsLbl.textAlignment = .right
        ptsLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(ptsLbl)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),
            nameLbl.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            nameLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ptsLbl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            ptsLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        return container
    }

    // MARK: - Guidance

    func buildGuidanceContent() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        panelView.addSubview(stack)

        let titleLbl = UILabel()
        titleLbl.text = "⚙ SETTINGS"
        titleLbl.font = UIFont.systemFont(ofSize: sv(24), weight: .heavy)
        titleLbl.textColor = UIColor(white: 0.95, alpha: 1)
        stack.addArrangedSubview(titleLbl)
        stack.addArrangedSubview(makeSeparator())

        let headingLbl = UILabel()
        headingLbl.text = "HOW TO PLAY"
        headingLbl.font = UIFont.systemFont(ofSize: sv(16), weight: .bold)
        headingLbl.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        stack.addArrangedSubview(headingLbl)

        let instructions = [
            "Tap SPIN to fill empty slots with symbols.",
            "3 matching symbols fuse into a higher tier.",
            "Fused slots become empty until next INVOKE.",
            "",
            "ODYSSEY: Reach the target tier within limited turns.",
            "CHRONO: Score as high as possible in 90 seconds.",
            "SLOT ASCENT: Spin 3 reels to match symbols,",
            "earn XP and rank up from Seed to Divine!",
            "",
            "Tiers: Seed → Sprout → Sapling → Tree",
            "→ Ancient → Mystic → Legendary → Divine",
        ]
        for line in instructions {
            let lbl = UILabel()
            lbl.text = line
            lbl.font = UIFont.systemFont(ofSize: sv(11), weight: .regular)
            lbl.textColor = UIColor(white: 0.75, alpha: 1)
            lbl.textAlignment = .center
            stack.addArrangedSubview(lbl)
        }

        stack.addArrangedSubview(makeSeparator())

        let rateBtn = makeActionButton(title: "⭐ RATE THIS APP", color: UIColor(red: 1, green: 0.84, blue: 0, alpha: 1), action: #selector(didTapRate))
        stack.addArrangedSubview(rateBtn)
        rateBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
        rateBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        let closeBtn = makeActionButton(title: "CLOSE", color: UIColor(white: 0.6, alpha: 1), action: #selector(didTapClose))
        stack.addArrangedSubview(closeBtn)
        closeBtn.widthAnchor.constraint(equalTo: panelView.widthAnchor, multiplier: 0.6).isActive = true
        closeBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: panelView.bottomAnchor, constant: -16),
            stack.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -32),
        ])
    }
}
