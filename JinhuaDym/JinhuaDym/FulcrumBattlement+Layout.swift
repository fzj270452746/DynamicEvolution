import UIKit

extension FulcrumBattlement {

    // MARK: - Backdrop

    func composeBackdrop() {
        backdropImage.image = UIImage(named: "bg_main_menu")
        backdropImage.contentMode = .scaleAspectFill
        backdropImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropImage)

        tintOverlay.backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 0.72)
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
        separator.backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.44, alpha: 1)
        separator.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(separator)

        backButton.setTitle("◀ MENU", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: sv(14), weight: .bold)
        backButton.tintColor = UIColor(white: 0.6, alpha: 1)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(backButton)

        pointsLabel.text = "0"
        pointsLabel.font = UIFont.systemFont(ofSize: sv(28), weight: .heavy)
        pointsLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        pointsLabel.textAlignment = .center
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(pointsLabel)

        pointsCaptionLabel.text = "POINTS"
        pointsCaptionLabel.font = UIFont.systemFont(ofSize: sv(10), weight: .medium)
        pointsCaptionLabel.textColor = UIColor(white: 0.5, alpha: 1)
        pointsCaptionLabel.textAlignment = .center
        pointsCaptionLabel.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(pointsCaptionLabel)

        turnsLabel.font = UIFont.systemFont(ofSize: sv(13), weight: .bold)
        turnsLabel.textColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        turnsLabel.textAlignment = .right
        turnsLabel.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(turnsLabel)

        zenithLabel.text = "ZENITH: —"
        zenithLabel.font = UIFont.systemFont(ofSize: sv(12), weight: .bold)
        zenithLabel.textColor = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        zenithLabel.textAlignment = .right
        zenithLabel.translatesAutoresizingMaskIntoConstraints = false
        hudBar.addSubview(zenithLabel)

        NSLayoutConstraint.activate([
            hudBar.topAnchor.constraint(equalTo: view.topAnchor),
            hudBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hudBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hudBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),

            separator.leadingAnchor.constraint(equalTo: hudBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: hudBar.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: hudBar.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            backButton.leadingAnchor.constraint(equalTo: hudBar.leadingAnchor, constant: 12),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),

            pointsLabel.centerXAnchor.constraint(equalTo: hudBar.centerXAnchor),
            pointsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            pointsCaptionLabel.centerXAnchor.constraint(equalTo: hudBar.centerXAnchor),
            pointsCaptionLabel.topAnchor.constraint(equalTo: pointsLabel.bottomAnchor, constant: 0),

            turnsLabel.trailingAnchor.constraint(equalTo: hudBar.trailingAnchor, constant: -16),
            turnsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            zenithLabel.trailingAnchor.constraint(equalTo: hudBar.trailingAnchor, constant: -16),
            zenithLabel.topAnchor.constraint(equalTo: turnsLabel.bottomAnchor, constant: 2),
        ])
    }

    // MARK: - Objective Label

    func composeObjectiveLabel() {
        objectiveLabel.font = UIFont.systemFont(ofSize: sv(15), weight: .heavy)
        objectiveLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        objectiveLabel.textAlignment = .center
        objectiveLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(objectiveLabel)

        countdownLabel.font = UIFont.systemFont(ofSize: sv(18), weight: .heavy)
        countdownLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        countdownLabel.textAlignment = .center
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownLabel)
    }

    // MARK: - Grid Frame

    func composeGridFrame() {
        gridFrame.backgroundColor = UIColor(red: 0.06, green: 0.06, blue: 0.16, alpha: 0.92)
        gridFrame.layer.cornerRadius = 16
        gridFrame.layer.borderWidth = 2.0
        gridFrame.layer.borderColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.5).cgColor
        gridFrame.layer.shadowColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.15).cgColor
        gridFrame.layer.shadowOffset = .zero
        gridFrame.layer.shadowRadius = 10
        gridFrame.layer.shadowOpacity = 1
        gridFrame.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridFrame)

        let side = gridSide + 20
        NSLayoutConstraint.activate([
            gridFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            gridFrame.widthAnchor.constraint(equalToConstant: side),
            gridFrame.heightAnchor.constraint(equalToConstant: side),
        ])
    }

    // MARK: - Grid (UICollectionView)

    func composeGrid() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        layout.sectionInset = .zero

        gridView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        gridView.register(IncunableCell.self, forCellWithReuseIdentifier: IncunableCell.reuseTag)
        gridView.dataSource = self
        gridView.delegate = self
        gridView.backgroundColor = .clear
        gridView.isScrollEnabled = false
        gridView.clipsToBounds = false
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)

        let side = gridSide
        NSLayoutConstraint.activate([
            gridView.centerXAnchor.constraint(equalTo: gridFrame.centerXAnchor),
            gridView.centerYAnchor.constraint(equalTo: gridFrame.centerYAnchor),
            gridView.widthAnchor.constraint(equalToConstant: side),
            gridView.heightAnchor.constraint(equalToConstant: side),

            objectiveLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            objectiveLabel.bottomAnchor.constraint(equalTo: gridFrame.topAnchor, constant: -12),
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.bottomAnchor.constraint(equalTo: gridFrame.topAnchor, constant: -12),
        ])
    }

    // MARK: - Chain Label

    func composeChainLabel() {
        chainLabel.font = UIFont.systemFont(ofSize: sv(26), weight: .heavy)
        chainLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        chainLabel.textAlignment = .center
        chainLabel.alpha = 0
        chainLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chainLabel)

        NSLayoutConstraint.activate([
            chainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chainLabel.topAnchor.constraint(equalTo: gridFrame.bottomAnchor, constant: 8),
        ])
    }

    // MARK: - Distribution Label

    func composeDistributionLabel() {
        distributionLabel.font = UIFont(name: "Menlo", size: sv(10)) ?? UIFont.monospacedSystemFont(ofSize: sv(10), weight: .regular)
        distributionLabel.textColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 0.8)
        distributionLabel.numberOfLines = 2
        distributionLabel.textAlignment = .center
        distributionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(distributionLabel)

        NSLayoutConstraint.activate([
            distributionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distributionLabel.topAnchor.constraint(equalTo: chainLabel.bottomAnchor, constant: 4),
        ])
    }

    // MARK: - Invoke Button

    func composeInvokeButton() {
        let bw = min(view.bounds.width * 0.55, 220)
        invokeButton.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.28, alpha: 1)
        invokeButton.layer.cornerRadius = 29
        invokeButton.layer.borderWidth = 2.2
        invokeButton.layer.borderColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1).cgColor
        invokeButton.layer.shadowColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.18).cgColor
        invokeButton.layer.shadowOffset = CGSize(width: 2, height: -3)
        invokeButton.layer.shadowRadius = 6
        invokeButton.layer.shadowOpacity = 1

        let lbl = UILabel()
        lbl.text = "S P I N"
        lbl.font = UIFont.systemFont(ofSize: sv(22), weight: .heavy)
        lbl.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        lbl.isUserInteractionEnabled = false
        lbl.translatesAutoresizingMaskIntoConstraints = false
        invokeButton.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: invokeButton.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: invokeButton.centerYAnchor),
        ])

        invokeButton.addTarget(self, action: #selector(didTapInvoke), for: .touchUpInside)
        invokeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(invokeButton)

        NSLayoutConstraint.activate([
            invokeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            invokeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
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
}
