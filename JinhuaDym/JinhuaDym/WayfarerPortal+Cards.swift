import UIKit

extension WayfarerPortal {

    // MARK: - Hero Card (Odyssey)

    func composeHeroCard() {
        let pad: CGFloat = 20
        let cardH: CGFloat = sv(140)
        let gold = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)

        styleCard(heroCard, borderColor: gold, glowColor: gold)
        contentView.addSubview(heroCard)

        let gradBg = CAGradientLayer()
        gradBg.colors = [
            UIColor(red: 0.12, green: 0.10, blue: 0.05, alpha: 0.9).cgColor,
            UIColor(red: 0.06, green: 0.06, blue: 0.16, alpha: 0.95).cgColor,
        ]
        gradBg.startPoint = CGPoint(x: 0, y: 0)
        gradBg.endPoint = CGPoint(x: 1, y: 1)
        gradBg.cornerRadius = 18
        heroCard.layer.insertSublayer(gradBg, at: 0)

        let iconView = UIImageView(image: UIImage(named: MorphRank.celestial.iconAsset))
        iconView.contentMode = .scaleAspectFit
        iconView.alpha = 0.25
        iconView.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(iconView)

        let tagLabel = UILabel()
        tagLabel.text = "⚔  FEATURED"
        tagLabel.font = UIFont.systemFont(ofSize: sv(9), weight: .heavy)
        tagLabel.textColor = gold.withAlphaComponent(0.7)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(tagLabel)

        let heroTitle = UILabel()
        heroTitle.text = "ODYSSEY MODE"
        heroTitle.font = UIFont.systemFont(ofSize: sv(24), weight: .heavy)
        heroTitle.textColor = gold
        heroTitle.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(heroTitle)

        let heroSub = UILabel()
        heroSub.text = "Stage \(ApothicNucleus.preservedStage) · Reach the Target"
        heroSub.font = UIFont.systemFont(ofSize: sv(12), weight: .medium)
        heroSub.textColor = UIColor(white: 0.6, alpha: 1)
        heroSub.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(heroSub)

        let arrow = UILabel()
        arrow.text = "▶"
        arrow.font = UIFont.systemFont(ofSize: sv(22), weight: .bold)
        arrow.textColor = gold.withAlphaComponent(0.5)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(arrow)

        heroCard.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: glowBar.bottomAnchor, constant: 20),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            heroCard.heightAnchor.constraint(equalToConstant: cardH),

            iconView.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -10),
            iconView.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: cardH * 0.75),
            iconView.heightAnchor.constraint(equalToConstant: cardH * 0.75),

            tagLabel.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 16),
            tagLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),

            heroTitle.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 6),
            heroTitle.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),

            heroSub.topAnchor.constraint(equalTo: heroTitle.bottomAnchor, constant: 4),
            heroSub.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),

            arrow.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),
        ])

        heroCard.layoutIfNeeded()
        gradBg.frame = heroCard.bounds

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOdyssey))
        heroCard.addGestureRecognizer(tap)
        allCards.append(heroCard)

        DispatchQueue.main.async {
            gradBg.frame = self.heroCard.bounds
        }
    }

    // MARK: - Dual Row (Chrono + Slot)

    func composeDualRow() {
        let pad: CGFloat = 20
        let gap: CGFloat = 12
        let cyan = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        let purple = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)

        styleCard(chronoCard, borderColor: cyan, glowColor: cyan)
        styleCard(slotCard, borderColor: purple, glowColor: purple)
        contentView.addSubview(chronoCard)
        contentView.addSubview(slotCard)

        fillModeCard(chronoCard, icon: "⏱", title: "CHRONO\nSURGE", detail: "90s Score Attack", accent: cyan)
        let slotStats = CelestialSpindle.fetchSlotStats()
        let slotLevelName = MorphRank(rawValue: slotStats.levelRaw)?.designation ?? "Seed"
        fillModeCard(slotCard, icon: "🎰", title: "SLOT\nASCENT", detail: "Rank: \(slotLevelName)", accent: purple)

        chronoCard.translatesAutoresizingMaskIntoConstraints = false
        slotCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            chronoCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 14),
            chronoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            chronoCard.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -gap / 2),
            chronoCard.heightAnchor.constraint(equalToConstant: sv(130)),

            slotCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 14),
            slotCard.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: gap / 2),
            slotCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            slotCard.heightAnchor.constraint(equalToConstant: sv(130)),
        ])

        let tapChrono = UITapGestureRecognizer(target: self, action: #selector(didTapChronoSurge))
        chronoCard.addGestureRecognizer(tapChrono)
        let tapSlot = UITapGestureRecognizer(target: self, action: #selector(didTapSlotAscent))
        slotCard.addGestureRecognizer(tapSlot)
        allCards.append(contentsOf: [chronoCard, slotCard])
    }

    func fillModeCard(_ card: UIView, icon: String, title: String, detail: String, accent: UIColor) {
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: sv(32))
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: sv(16), weight: .heavy)
        titleLbl.textColor = accent
        titleLbl.numberOfLines = 2
        titleLbl.textAlignment = .center
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLbl)

        let detailLbl = UILabel()
        detailLbl.text = detail
        detailLbl.font = UIFont.systemFont(ofSize: sv(10), weight: .medium)
        detailLbl.textColor = UIColor(white: 0.55, alpha: 1)
        detailLbl.textAlignment = .center
        detailLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(detailLbl)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            iconLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            titleLbl.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 6),
            titleLbl.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            titleLbl.widthAnchor.constraint(equalTo: card.widthAnchor, constant: -16),
            detailLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 4),
            detailLbl.centerXAnchor.constraint(equalTo: card.centerXAnchor),
        ])
    }

    // MARK: - Utility Row (Rankings + Almanac)

    func composeUtilityRow() {
        let pad: CGFloat = 20
        let gap: CGFloat = 12
        let orange = UIColor(red: 0.90, green: 0.32, blue: 0, alpha: 1)
        let green = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)

        styleCard(rankingsCard, borderColor: orange, glowColor: orange)
        styleCard(almanacCard, borderColor: green, glowColor: green)
        contentView.addSubview(rankingsCard)
        contentView.addSubview(almanacCard)

        fillUtilityCard(rankingsCard, icon: "🏆", title: "RANKINGS", accent: orange)
        fillUtilityCard(almanacCard, icon: "📖", title: "ALMANAC", accent: green)

        rankingsCard.translatesAutoresizingMaskIntoConstraints = false
        almanacCard.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rankingsCard.topAnchor.constraint(equalTo: chronoCard.bottomAnchor, constant: 14),
            rankingsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            rankingsCard.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -gap / 2),
            rankingsCard.heightAnchor.constraint(equalToConstant: sv(70)),

            almanacCard.topAnchor.constraint(equalTo: slotCard.bottomAnchor, constant: 14),
            almanacCard.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: gap / 2),
            almanacCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            almanacCard.heightAnchor.constraint(equalToConstant: sv(70)),
        ])

        let tapRank = UITapGestureRecognizer(target: self, action: #selector(didTapRankings))
        rankingsCard.addGestureRecognizer(tapRank)
        let tapAlm = UITapGestureRecognizer(target: self, action: #selector(didTapAlmanac))
        almanacCard.addGestureRecognizer(tapAlm)
        allCards.append(contentsOf: [rankingsCard, almanacCard])
    }

    func fillUtilityCard(_ card: UIView, icon: String, title: String, accent: UIColor) {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false
        card.addSubview(stack)

        let iconLbl = UILabel()
        iconLbl.text = icon
        iconLbl.font = UIFont.systemFont(ofSize: sv(20))
        stack.addArrangedSubview(iconLbl)

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: sv(14), weight: .heavy)
        titleLbl.textColor = accent
        stack.addArrangedSubview(titleLbl)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
    }

    // MARK: - Stats Ribbon

    func composeStatsRibbon() {
        let pad: CGFloat = 20

        statsRibbon.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.14, alpha: 0.9)
        statsRibbon.layer.cornerRadius = 14
        statsRibbon.layer.borderWidth = 1
        statsRibbon.layer.borderColor = UIColor(white: 0.15, alpha: 1).cgColor
        statsRibbon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsRibbon)

        let ribbon = UIStackView()
        ribbon.axis = .horizontal
        ribbon.distribution = .fillEqually
        ribbon.alignment = .center
        ribbon.translatesAutoresizingMaskIntoConstraints = false
        statsRibbon.addSubview(ribbon)

        let divider1 = makeVerticalDivider()
        let divider2 = makeVerticalDivider()

        let col1 = makeStatColumn(top: statOdysseyLabel, label: "ODYSSEY", color: UIColor(red: 1, green: 0.84, blue: 0, alpha: 1))
        let col2 = makeStatColumn(top: statSlotRankLabel, label: "SLOT RANK", color: UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1))
        let col3 = makeStatColumn(top: statSpinsLabel, label: "TOTAL SPINS", color: UIColor(red: 0, green: 0.83, blue: 1, alpha: 1))

        ribbon.addArrangedSubview(col1)
        ribbon.addArrangedSubview(divider1)
        ribbon.addArrangedSubview(col2)
        ribbon.addArrangedSubview(divider2)
        ribbon.addArrangedSubview(col3)

        NSLayoutConstraint.activate([
            statsRibbon.topAnchor.constraint(equalTo: rankingsCard.bottomAnchor, constant: 18),
            statsRibbon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            statsRibbon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),
            statsRibbon.heightAnchor.constraint(equalToConstant: sv(65)),
            statsRibbon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            ribbon.topAnchor.constraint(equalTo: statsRibbon.topAnchor),
            ribbon.bottomAnchor.constraint(equalTo: statsRibbon.bottomAnchor),
            ribbon.leadingAnchor.constraint(equalTo: statsRibbon.leadingAnchor),
            ribbon.trailingAnchor.constraint(equalTo: statsRibbon.trailingAnchor),

            divider1.widthAnchor.constraint(equalToConstant: 1),
            divider2.widthAnchor.constraint(equalToConstant: 1),
        ])

        refreshStats()
    }

    func makeStatColumn(top: UILabel, label: String, color: UIColor) -> UIView {
        let col = UIView()

        top.font = UIFont.systemFont(ofSize: sv(18), weight: .heavy)
        top.textColor = color
        top.textAlignment = .center
        top.translatesAutoresizingMaskIntoConstraints = false
        col.addSubview(top)

        let lbl = UILabel()
        lbl.text = label
        lbl.font = UIFont.systemFont(ofSize: sv(8), weight: .bold)
        lbl.textColor = UIColor(white: 0.4, alpha: 1)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        col.addSubview(lbl)

        NSLayoutConstraint.activate([
            top.centerXAnchor.constraint(equalTo: col.centerXAnchor),
            top.centerYAnchor.constraint(equalTo: col.centerYAnchor, constant: -7),
            lbl.centerXAnchor.constraint(equalTo: col.centerXAnchor),
            lbl.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 2),
        ])
        return col
    }

    func makeVerticalDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.2, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return v
    }
}
