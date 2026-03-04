import UIKit

extension CelestialSpindle {

    // MARK: - Backdrop

    func composeBackdrop() {
        backdropImage.image = UIImage(named: "bg_main_menu")
        backdropImage.contentMode = .scaleAspectFill
        backdropImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropImage)

        tintOverlay.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 0.78)
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tintOverlay)

        for v in [backdropImage, tintOverlay] {
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: view.topAnchor),
                v.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
    }

    // MARK: - HUD

    func composeHUD() {
        hudBar.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.18, alpha: 0.9)
        hudBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hudBar)

        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(separator)

        backButton.setTitle("◀ MENU", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: sv(14), weight: .bold)
        backButton.tintColor = UIColor(white: 0.6, alpha: 1)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(backButton)

        let modeLabel = UILabel()
        modeLabel.text = "SLOT ASCENT"
        modeLabel.font = UIFont.systemFont(ofSize: sv(20), weight: .heavy)
        modeLabel.textColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
        modeLabel.textAlignment = .center
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(modeLabel)

        NSLayoutConstraint.activate([
            hudBar.topAnchor.constraint(equalTo: view.topAnchor),
            hudBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hudBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hudBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            separator.leadingAnchor.constraint(equalTo: hudBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: hudBar.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: hudBar.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            backButton.leadingAnchor.constraint(equalTo: hudBar.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: hudBar.bottomAnchor, constant: -12),
            modeLabel.centerXAnchor.constraint(equalTo: hudBar.centerXAnchor),
            modeLabel.bottomAnchor.constraint(equalTo: hudBar.bottomAnchor, constant: -12),
        ])
    }

    // MARK: - Level Display

    func composeLevelDisplay() {
        levelTitleLabel.text = "RANK"
        levelTitleLabel.font = UIFont.systemFont(ofSize: sv(11), weight: .medium)
        levelTitleLabel.textColor = UIColor(white: 0.5, alpha: 1)
        levelTitleLabel.textAlignment = .center
        levelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelTitleLabel)

        levelNameLabel.text = "Seed"
        levelNameLabel.font = UIFont.systemFont(ofSize: sv(32), weight: .heavy)
        levelNameLabel.textColor = MorphRank.germinal.pigment
        levelNameLabel.textAlignment = .center
        levelNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelNameLabel)

        maxLevelBadge.text = "★ MAX ★"
        maxLevelBadge.font = UIFont.systemFont(ofSize: sv(14), weight: .heavy)
        maxLevelBadge.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        maxLevelBadge.textAlignment = .center
        maxLevelBadge.alpha = 0
        maxLevelBadge.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(maxLevelBadge)

        NSLayoutConstraint.activate([
            levelTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelTitleLabel.topAnchor.constraint(equalTo: hudBar.bottomAnchor, constant: 12),
            levelNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelNameLabel.topAnchor.constraint(equalTo: levelTitleLabel.bottomAnchor, constant: 2),
            maxLevelBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maxLevelBadge.topAnchor.constraint(equalTo: levelNameLabel.bottomAnchor, constant: 2),
        ])
    }

    // MARK: - XP Bar

    func composeXPBar() {
        let barWidth = min(view.bounds.width * 0.7, 280.0)

        xpBarContainer.backgroundColor = UIColor(white: 0.15, alpha: 1)
        xpBarContainer.layer.cornerRadius = 6
        xpBarContainer.layer.borderWidth = 1
        xpBarContainer.layer.borderColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.6).cgColor
        xpBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(xpBarContainer)

        xpBarFill.backgroundColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
        xpBarFill.layer.cornerRadius = 4
        xpBarFill.translatesAutoresizingMaskIntoConstraints = false
        xpBarContainer.addSubview(xpBarFill)

        xpLabel.font = UIFont.systemFont(ofSize: sv(11), weight: .bold)
        xpLabel.textColor = UIColor(white: 0.85, alpha: 1)
        xpLabel.textAlignment = .center
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(xpLabel)

        NSLayoutConstraint.activate([
            xpBarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            xpBarContainer.topAnchor.constraint(equalTo: maxLevelBadge.bottomAnchor, constant: 6),
            xpBarContainer.widthAnchor.constraint(equalToConstant: barWidth),
            xpBarContainer.heightAnchor.constraint(equalToConstant: 12),
            xpBarFill.leadingAnchor.constraint(equalTo: xpBarContainer.leadingAnchor, constant: 2),
            xpBarFill.topAnchor.constraint(equalTo: xpBarContainer.topAnchor, constant: 2),
            xpBarFill.bottomAnchor.constraint(equalTo: xpBarContainer.bottomAnchor, constant: -2),
            xpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            xpLabel.topAnchor.constraint(equalTo: xpBarContainer.bottomAnchor, constant: 3),
        ])

        xpBarFillWidthConstraint = xpBarFill.widthAnchor.constraint(equalToConstant: 0)
        xpBarFillWidthConstraint?.isActive = true
    }

    // MARK: - Slot Frame

    func composeSlotFrame() {
        let frameWidth = min(view.bounds.width * 0.88, 340.0)
        let frameHeight: CGFloat = frameWidth * 0.42

        slotFrame.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.16, alpha: 0.95)
        slotFrame.layer.cornerRadius = 18
        slotFrame.layer.borderWidth = 2.5
        slotFrame.layer.borderColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.7).cgColor
        slotFrame.layer.shadowColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.3).cgColor
        slotFrame.layer.shadowOffset = .zero
        slotFrame.layer.shadowRadius = 15
        slotFrame.layer.shadowOpacity = 1
        slotFrame.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slotFrame)

        NSLayoutConstraint.activate([
            slotFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slotFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            slotFrame.widthAnchor.constraint(equalToConstant: frameWidth),
            slotFrame.heightAnchor.constraint(equalToConstant: frameHeight),
        ])
    }

    // MARK: - Reels

    func composeReels() {
        let reelSize: CGFloat = min(view.bounds.width * 0.24, 90)
        let spacing: CGFloat = 12

        for i in 0..<3 {
            let container = UIView()
            container.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.22, alpha: 1)
            container.layer.cornerRadius = 12
            container.layer.borderWidth = 1.5
            container.layer.borderColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.4).cgColor
            container.clipsToBounds = true
            container.translatesAutoresizingMaskIntoConstraints = false
            slotFrame.addSubview(container)

            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: MorphRank.germinal.iconAsset)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(imageView)

            let lvLabel = UILabel()
            lvLabel.text = "Lv1"
            lvLabel.font = UIFont.systemFont(ofSize: sv(11), weight: .bold)
            lvLabel.textColor = MorphRank.germinal.pigment
            lvLabel.textAlignment = .center
            lvLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(lvLabel)

            let xOffset = CGFloat(i - 1) * (reelSize + spacing)
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: slotFrame.centerXAnchor, constant: xOffset),
                container.centerYAnchor.constraint(equalTo: slotFrame.centerYAnchor),
                container.widthAnchor.constraint(equalToConstant: reelSize),
                container.heightAnchor.constraint(equalToConstant: reelSize),
                imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
                imageView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.65),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                lvLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                lvLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            ])

            reelContainers.append(container)
            reelImageViews.append(imageView)
            reelLevelLabels.append(lvLabel)
        }

        let divider1 = makeReelDivider()
        let divider2 = makeReelDivider()
        slotFrame.addSubview(divider1)
        slotFrame.addSubview(divider2)

        NSLayoutConstraint.activate([
            divider1.centerXAnchor.constraint(equalTo: reelContainers[0].trailingAnchor, constant: spacing / 2),
            divider1.centerYAnchor.constraint(equalTo: slotFrame.centerYAnchor),
            divider1.widthAnchor.constraint(equalToConstant: 1.5),
            divider1.heightAnchor.constraint(equalTo: slotFrame.heightAnchor, multiplier: 0.6),
            divider2.centerXAnchor.constraint(equalTo: reelContainers[1].trailingAnchor, constant: spacing / 2),
            divider2.centerYAnchor.constraint(equalTo: slotFrame.centerYAnchor),
            divider2.widthAnchor.constraint(equalToConstant: 1.5),
            divider2.heightAnchor.constraint(equalTo: slotFrame.heightAnchor, multiplier: 0.6),
        ])
    }

    func makeReelDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - Result Label

    func composeResultLabel() {
        resultLabel.font = UIFont.systemFont(ofSize: sv(22), weight: .heavy)
        resultLabel.textAlignment = .center
        resultLabel.alpha = 0
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.topAnchor.constraint(equalTo: slotFrame.bottomAnchor, constant: 16),
        ])
    }

    // MARK: - Invoke Button

    func composeInvokeButton() {
        let bw = min(view.bounds.width * 0.55, 220)
        invokeButton.backgroundColor = UIColor(red: 0.12, green: 0.08, blue: 0.28, alpha: 1)
        invokeButton.layer.cornerRadius = 29
        invokeButton.layer.borderWidth = 2.2
        invokeButton.layer.borderColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1).cgColor
        invokeButton.layer.shadowColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.25).cgColor
        invokeButton.layer.shadowOffset = CGSize(width: 2, height: -3)
        invokeButton.layer.shadowRadius = 6
        invokeButton.layer.shadowOpacity = 1

        let lbl = UILabel()
        lbl.text = "S P I N"
        lbl.font = UIFont.systemFont(ofSize: sv(22), weight: .heavy)
        lbl.textColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
        lbl.isUserInteractionEnabled = false
        lbl.translatesAutoresizingMaskIntoConstraints = false
        invokeButton.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: invokeButton.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: invokeButton.centerYAnchor),
        ])

        invokeButton.addTarget(self, action: #selector(didTapSpin), for: .touchUpInside)
        invokeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(invokeButton)

        NSLayoutConstraint.activate([
            invokeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            invokeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            invokeButton.widthAnchor.constraint(equalToConstant: bw),
            invokeButton.heightAnchor.constraint(equalToConstant: 58),
        ])

        pulseInvokeButton()
    }

    func pulseInvokeButton() {
        UIView.animate(withDuration: 0.9, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction, .curveEaseInOut]) {
            self.invokeButton.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
        }
    }

    // MARK: - Spin Counter

    func composeSpinCounter() {
        spinCountLabel.font = UIFont.systemFont(ofSize: sv(13), weight: .bold)
        spinCountLabel.textColor = UIColor(white: 0.5, alpha: 1)
        spinCountLabel.textAlignment = .center
        spinCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinCountLabel)

        NSLayoutConstraint.activate([
            spinCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinCountLabel.topAnchor.constraint(equalTo: invokeButton.bottomAnchor, constant: 8),
        ])
    }
}
