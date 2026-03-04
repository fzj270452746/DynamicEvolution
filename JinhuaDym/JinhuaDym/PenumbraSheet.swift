import UIKit
import StoreKit

final class PenumbraSheet: UIViewController {

    enum Facet {
        case triumph(points: Int, zenith: String)
        case odysseyVictory(points: Int, zenith: String, stage: Int)
        case defeat(points: Int, zenith: String)
        case chronoResult(points: Int, zenithName: String, zenithCount: Int)
        case rankings
        case almanac
        case guidance
    }

    var onReturnToMenu: (() -> Void)?
    var onAdvanceStage: (() -> Void)?
    var onReplaySession: (() -> Void)?

    let facet: Facet
    let dimView = UIView()
    let panelView = UIView()
    let scrollContent = UIScrollView()

    init(facet: Facet) {
        self.facet = facet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        composeDimBackground()
        composePanel()
        populateContent()
        animateIn()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Dim Background

    func composeDimBackground() {
        dimView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.72)
        dimView.frame = view.bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(dimView)

        switch facet {
        case .almanac, .rankings, .guidance:
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDim))
            dimView.addGestureRecognizer(tapGesture)
        default:
            break
        }
    }

    // MARK: - Panel

    func composePanel() {
        let pw = min(view.bounds.width * 0.88, 360)
        let ph: CGFloat

        switch facet {
        case .rankings, .almanac, .guidance:
            ph = min(view.bounds.height * 0.78, 620)
        default:
            ph = min(view.bounds.height * 0.52, 420)
        }

        panelView.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.18, alpha: 0.97)
        panelView.layer.cornerRadius = 22
        panelView.layer.borderWidth = 2.2
        panelView.clipsToBounds = true
        panelView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panelView)

        NSLayoutConstraint.activate([
            panelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panelView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panelView.widthAnchor.constraint(equalToConstant: pw),
            panelView.heightAnchor.constraint(equalToConstant: ph),
        ])
    }

    // MARK: - Content

    func populateContent() {
        let accent: UIColor
        switch facet {
        case .triumph, .odysseyVictory:
            accent = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        case .defeat:
            accent = UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)
        case .chronoResult:
            accent = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        case .rankings:
            accent = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        case .almanac:
            accent = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        case .guidance:
            accent = UIColor(white: 0.5, alpha: 0.8)
        }
        panelView.layer.borderColor = accent.withAlphaComponent(0.9).cgColor

        switch facet {
        case .triumph(let pts, let z):
            buildResultContent(won: true, points: pts, zenith: z, stage: nil)
        case .odysseyVictory(let pts, let z, let stg):
            buildResultContent(won: true, points: pts, zenith: z, stage: stg)
        case .defeat(let pts, let z):
            buildResultContent(won: false, points: pts, zenith: z, stage: nil)
        case .chronoResult(let pts, let zn, let zc):
            buildChronoResultContent(points: pts, zenithName: zn, zenithCount: zc)
        case .rankings:
            buildRankingsContent()
        case .almanac:
            buildAlmanacContent()
        case .guidance:
            buildGuidanceContent()
        }
    }

    // MARK: - Shared UI Factories

    func makeActionButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.24, alpha: 0.95)
        btn.layer.cornerRadius = 23
        btn.layer.borderWidth = 1.8
        btn.layer.borderColor = color.withAlphaComponent(0.85).cgColor
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(color, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: sv(16), weight: .bold)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    func makeSeparator() -> UIView {
        let sep = UIView()
        sep.backgroundColor = UIColor(white: 1, alpha: 0.12)
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.heightAnchor.constraint(equalToConstant: 0.8).isActive = true
        sep.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return sep
    }

    func makeSpacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    // MARK: - Actions

    @objc func didTapAdvance() {
        dismiss(animated: true) { [weak self] in
            self?.onAdvanceStage?()
        }
    }

    @objc func didTapReplay() {
        dismiss(animated: true) { [weak self] in
            self?.onReplaySession?()
        }
    }

    @objc func didTapMenu() {
        dismiss(animated: true) { [weak self] in
            self?.onReturnToMenu?()
        }
    }

    @objc func didTapClose() {
        animateOut()
    }

    @objc func didTapRate() {
        if let windowScene = view.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    @objc func didTapDim() {
        animateOut()
    }

    // MARK: - Transitions

    func animateIn() {
        panelView.alpha = 0
        panelView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        dimView.alpha = 0

        UIView.animate(withDuration: 0.22) {
            self.dimView.alpha = 1
            self.panelView.alpha = 1
            self.panelView.transform = .identity
        }
    }

    func animateOut() {
        UIView.animate(withDuration: 0.18, animations: {
            self.dimView.alpha = 0
            self.panelView.alpha = 0
            self.panelView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - Helpers

    func sv(_ base: CGFloat) -> CGFloat {
        let ratio = min(UIScreen.main.bounds.width / 390, UIScreen.main.bounds.height / 844)
        return base * max(ratio, 0.75)
    }
}
