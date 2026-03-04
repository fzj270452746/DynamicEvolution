import UIKit

protocol PortalNavigationDelegate: AnyObject {
    func portalRequestsOdyssey()
    func portalRequestsChronoSurge()
    func portalRequestsSlotAscent()
}

final class WayfarerPortal: UIViewController {

    weak var navigationDelegate: PortalNavigationDelegate?

    let scrollView = UIScrollView()
    let contentView = UIView()

    let gradientLayer = CAGradientLayer()
    let backdropImage = UIImageView()
    let tintOverlay = UIView()

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let glowBar = UIView()
    let settingsButton = UIButton(type: .system)

    let heroCard = UIView()
    let chronoCard = UIView()
    let slotCard = UIView()
    let rankingsCard = UIView()
    let almanacCard = UIView()

    let statsRibbon = UIView()
    let statOdysseyLabel = UILabel()
    let statSlotRankLabel = UILabel()
    let statSpinsLabel = UILabel()

    var allCards: [UIView] = []
    var emitterLayers: [CAEmitterLayer] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        composeAnimatedBackground()
        composeScrollView()
        composeTitleArea()
        composeHeroCard()
        composeDualRow()
        composeUtilityRow()
        composeStatsRibbon()
        composeSettingsGear()
        
        if let splashVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
            splashVC.view.tag = 614
            splashVC.view.frame = view.bounds
            splashVC.view.isUserInteractionEnabled = false
            view.addSubview(splashVC.view)
            
            view.bringSubviewToFront(splashVC.view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        for layer in emitterLayers {
            layer.frame = view.bounds
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        composeParticleSystems()
        animateEntrance()
        animateGlowBar()
        animateGradientShift()
        refreshStats()
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Scroll View

    func composeScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    // MARK: - Title Area

    func composeTitleArea() {
        let pad: CGFloat = 20

        titleLabel.text = "Dynamic Slot"
        titleLabel.font = UIFont.systemFont(ofSize: sv(38), weight: .heavy)
        titleLabel.textColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        subtitleLabel.text = "Evolution"
        subtitleLabel.font = UIFont.systemFont(ofSize: sv(16), weight: .bold)
        subtitleLabel.textColor = UIColor(red: 0, green: 0.83, blue: 1, alpha: 0.9)
        subtitleLabel.textAlignment = .left
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        glowBar.backgroundColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.9)
        glowBar.layer.cornerRadius = 1.5
        glowBar.layer.shadowColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1).cgColor
        glowBar.layer.shadowOffset = .zero
        glowBar.layer.shadowRadius = 8
        glowBar.layer.shadowOpacity = 0.8
        glowBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(glowBar)

        var safeTop: CGFloat = 50
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            safeTop = windowScene.windows.first?.safeAreaInsets.top ?? 50
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: safeTop + 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -2),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad + 2),

            glowBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            glowBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            glowBar.heightAnchor.constraint(equalToConstant: 3),
            glowBar.widthAnchor.constraint(equalToConstant: 60),
        ])
    }

    func animateGlowBar() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.glowBar.alpha = 0.4
            self.glowBar.transform = CGAffineTransform(scaleX: 2.5, y: 1)
        }
    }

    // MARK: - Settings

    func composeSettingsGear() {
        settingsButton.setTitle("⚙", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: sv(26))
        settingsButton.tintColor = UIColor(white: 0.5, alpha: 1)
        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Actions

    @objc func didTapOdyssey() {
        cardBounce(heroCard) { [weak self] in
            self?.navigationDelegate?.portalRequestsOdyssey()
        }
    }

    @objc func didTapChronoSurge() {
        cardBounce(chronoCard) { [weak self] in
            self?.navigationDelegate?.portalRequestsChronoSurge()
        }
    }

    @objc func didTapSlotAscent() {
        cardBounce(slotCard) { [weak self] in
            self?.navigationDelegate?.portalRequestsSlotAscent()
        }
    }

    @objc func didTapRankings() {
        cardBounce(rankingsCard) { [weak self] in
            self?.presentOverlay(.rankings)
        }
    }

    @objc func didTapAlmanac() {
        cardBounce(almanacCard) { [weak self] in
            self?.presentOverlay(.almanac)
        }
    }

    @objc func didTapSettings() {
        presentOverlay(.guidance)
    }

    func cardBounce(_ card: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.08, animations: {
            card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                card.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }

    func presentOverlay(_ facet: PenumbraSheet.Facet) {
        let sheet = PenumbraSheet(facet: facet)
        sheet.modalPresentationStyle = .overCurrentContext
        sheet.modalTransitionStyle = .crossDissolve
        present(sheet, animated: true)
    }

    func refreshStats() {
        statOdysseyLabel.text = "Stg.\(ApothicNucleus.preservedStage)"
        let slotStats = CelestialSpindle.fetchSlotStats()
        let slotName = MorphRank(rawValue: slotStats.levelRaw)?.designation ?? "Seed"
        statSlotRankLabel.text = slotName
        statSpinsLabel.text = "\(slotStats.spins)"
    }

    // MARK: - Helpers

    func sv(_ base: CGFloat) -> CGFloat {
        let ratio = min(UIScreen.main.bounds.width / 390, UIScreen.main.bounds.height / 844)
        return base * max(ratio, 0.75)
    }
}

