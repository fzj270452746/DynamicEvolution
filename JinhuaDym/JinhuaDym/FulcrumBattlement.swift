import UIKit

protocol BattlementDelegate: AnyObject {
    func battlementRequestsReturn()
}

final class FulcrumBattlement: UIViewController {

    weak var sceneDelegate: BattlementDelegate?
    let nucleus = ApothicNucleus()
    var sessionMode: SessionBlueprint = .chronoSurge

    var gridView: UICollectionView!
    let backdropImage = UIImageView()
    let tintOverlay = UIView()
    let hudBar = UIView()
    let backButton = UIButton(type: .system)
    let pointsLabel = UILabel()
    let pointsCaptionLabel = UILabel()
    let turnsLabel = UILabel()
    let zenithLabel = UILabel()
    let objectiveLabel = UILabel()
    let countdownLabel = UILabel()
    let chainLabel = UILabel()
    let distributionLabel = UILabel()
    let invokeButton = UIButton(type: .custom)
    let gridFrame = UIView()

    var isPerforming = false
    var chronoRemaining: TimeInterval = 90
    var displayLink: CADisplayLink?
    var lastFrameTime: CFTimeInterval = 0
    var chronoExpired = false

    var cellDimension: CGFloat {
        let gridWidth = min(view.bounds.width - 48, 340.0)
        return floor((gridWidth - 18) / 4)
    }

    var gridSide: CGFloat {
        cellDimension * 4 + 18
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        nucleus.initializeBlueprint(sessionMode)
        composeBackdrop()
        composeHUD()
        composeObjectiveLabel()
        composeGridFrame()
        composeGrid()
        composeChainLabel()
        composeDistributionLabel()
        composeInvokeButton()
        refreshHUD()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if case .chronoSurge = sessionMode {
            beginCountdown()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink?.invalidate()
        displayLink = nil
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    // MARK: - HUD Refresh

    func refreshHUD() {
        pointsLabel.text = "\(nucleus.cumulativePoints)"

        if let apex = nucleus.zenithRank {
            zenithLabel.text = "ZENITH: \(apex.designation)"
        } else {
            zenithLabel.text = "ZENITH: —"
        }

        if case .odyssey(let stg) = nucleus.blueprint {
            turnsLabel.text = "TURNS: \(nucleus.odysseyTurnsLeft)"
            countdownLabel.text = ""

            let target  = nucleus.odysseyObjective.designation
            let count   = nucleus.odysseyRequiredCount
            let current = nucleus.objectiveCountOnLattice
            objectiveLabel.text = "⚔ STAGE \(stg)  ▸  \(current)/\(count) × \(target)"
            objectiveLabel.textColor = current >= count
                ? UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
                : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        } else {
            turnsLabel.text = "TURN ×\(nucleus.turnCount)"
            objectiveLabel.text = ""

            let secs = Int(ceil(chronoRemaining))
            countdownLabel.text = "⏱ \(secs)s"
            countdownLabel.textColor = secs <= 10
                ? UIColor(red: 1, green: 0.19, blue: 0.19, alpha: 1)
                : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        }

        let rows = nucleus.distributionRows()
        distributionLabel.text = rows.upper + "\n" + rows.lower
    }

    // MARK: - Navigation

    @objc func didTapBack() {
        displayLink?.invalidate()
        displayLink = nil
        sceneDelegate?.battlementRequestsReturn()
    }

    // MARK: - Helpers

    func sv(_ base: CGFloat) -> CGFloat {
        let ratio = min(UIScreen.main.bounds.width / 390, UIScreen.main.bounds.height / 844)
        return base * max(ratio, 0.75)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension FulcrumBattlement: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        16
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IncunableCell.reuseTag, for: indexPath) as! IncunableCell
        if indexPath.item < nucleus.lattice.count, let rank = nucleus.lattice[indexPath.item] {
            cell.configureWith(rank: rank)
        } else {
            cell.configureAsVacant()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = cellDimension
        return CGSize(width: side, height: side)
    }
}
