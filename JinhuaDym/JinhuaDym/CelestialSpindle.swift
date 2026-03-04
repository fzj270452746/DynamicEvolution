import UIKit

protocol SpindleDelegate: AnyObject {
    func spindleRequestsReturn()
}

final class CelestialSpindle: UIViewController {

    weak var sceneDelegate: SpindleDelegate?

    // MARK: - UI Components

    let backdropImage = UIImageView()
    let tintOverlay = UIView()
    let hudBar = UIView()
    let backButton = UIButton(type: .system)
    let levelTitleLabel = UILabel()
    let levelNameLabel = UILabel()
    let xpBarContainer = UIView()
    let xpBarFill = UIView()
    let xpLabel = UILabel()
    let spinCountLabel = UILabel()
    let slotFrame = UIView()
    var reelContainers: [UIView] = []
    var reelImageViews: [UIImageView] = []
    var reelLevelLabels: [UILabel] = []
    let invokeButton = UIButton(type: .custom)
    let resultLabel = UILabel()
    let maxLevelBadge = UILabel()
    var xpBarFillWidthConstraint: NSLayoutConstraint?

    // MARK: - Game State

    var isSpinning = false
    var currentLevel: MorphRank = .germinal
    var currentXP: Int = 0
    var historicSpins: Int = 0
    var sessionSpins: Int = 0
    var reelResults: [MorphRank] = [.germinal, .germinal, .germinal]
    var reelTimers: [Timer?] = [nil, nil, nil]
    var reelTickCounts: [Int] = [0, 0, 0]
    var reelTargets: [MorphRank] = [.germinal, .germinal, .germinal]
    var reelsStoppedCount = 0

    // MARK: - Constants

    static let xpThresholds: [Int] = [0, 100, 300, 600, 1100, 1800, 3000, 5000]
    static let matchRewards: [Int] = [10, 25, 50, 80, 130, 220, 380, 600]
    static let maxTicksPerReel: [Int] = [18, 25, 33]

    // MARK: - Two-Phase Probability Tables

    enum SpinOutcome {
        case tripleMatch, nearMiss, allDifferent
    }

    static let outcomeTable: [(outcome: SpinOutcome, weight: Double)] = [
        (.tripleMatch,  15),
        (.nearMiss,     67),
        (.allDifferent, 18),
    ]

    static let matchTierWeights: [(rank: MorphRank, weight: Double)] = [
        (.germinal, 35.0), (.verdure, 24.0), (.juvenile, 16.0), (.timber, 10.0),
        (.primeval,  7.0), (.arcane,   4.5), (.fabled,    2.5), (.celestial, 1.0),
    ]

    static let symbolWeights: [(rank: MorphRank, weight: Double)] = [
        (.germinal, 30.0), (.verdure, 22.0), (.juvenile, 17.0), (.timber, 12.0),
        (.primeval,  8.0), (.arcane,   5.5), (.fabled,    3.5), (.celestial, 2.0),
    ]

    // MARK: - Persistence Keys

    static let levelKey = "JinhuaDym_SlotLevel"
    static let xpKey = "JinhuaDym_SlotXP"
    static let spinsKey = "JinhuaDym_SlotSpins"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        loadProgress()
        composeBackdrop()
        composeHUD()
        composeLevelDisplay()
        composeXPBar()
        composeSlotFrame()
        composeReels()
        composeResultLabel()
        composeInvokeButton()
        composeSpinCounter()
        refreshUI()
    }

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    // MARK: - Persistence

    func loadProgress() {
        let savedLevel = UserDefaults.standard.integer(forKey: Self.levelKey)
        if savedLevel > 0, let rank = MorphRank(rawValue: savedLevel) {
            currentLevel = rank
        }
        currentXP = UserDefaults.standard.integer(forKey: Self.xpKey)
        historicSpins = UserDefaults.standard.integer(forKey: Self.spinsKey)
        sessionSpins = 0
    }

    func saveProgress() {
        UserDefaults.standard.set(currentLevel.rawValue, forKey: Self.levelKey)
        UserDefaults.standard.set(currentXP, forKey: Self.xpKey)
        UserDefaults.standard.set(historicSpins + sessionSpins, forKey: Self.spinsKey)
    }

    static func fetchSlotStats() -> (levelRaw: Int, spins: Int) {
        let lv = max(UserDefaults.standard.integer(forKey: levelKey), 1)
        let sp = UserDefaults.standard.integer(forKey: spinsKey)
        return (lv, sp)
    }

    // MARK: - Refresh UI

    func refreshUI() {
        levelNameLabel.text = currentLevel.designation
        levelNameLabel.textColor = currentLevel.pigment

        let isMaxLevel = currentLevel == .celestial
        maxLevelBadge.alpha = isMaxLevel ? 1 : 0

        if isMaxLevel {
            xpLabel.text = "MAX LEVEL"
            let barInnerWidth = min(view.bounds.width * 0.7, 280.0) - 4
            xpBarFillWidthConstraint?.constant = barInnerWidth
            xpBarFill.backgroundColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        } else {
            let currentThreshold = Self.xpThresholds[currentLevel.rawValue - 1]
            let nextThreshold = Self.xpThresholds[currentLevel.rawValue]
            let xpInLevel = currentXP - currentThreshold
            let xpNeeded = nextThreshold - currentThreshold
            let ratio = CGFloat(xpInLevel) / CGFloat(max(xpNeeded, 1))
            let barInnerWidth = min(view.bounds.width * 0.7, 280.0) - 4
            xpBarFillWidthConstraint?.constant = max(barInnerWidth * min(ratio, 1.0), 2)
            xpBarFill.backgroundColor = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
            xpLabel.text = "\(xpInLevel) / \(xpNeeded) XP"
        }

        view.layoutIfNeeded()
        spinCountLabel.text = "SPINS: \(sessionSpins)"

        for (i, rank) in reelResults.enumerated() {
            reelImageViews[i].image = UIImage(named: rank.iconAsset)
            reelLevelLabels[i].text = "Lv\(rank.rawValue)"
            reelLevelLabels[i].textColor = rank.pigment
            reelContainers[i].layer.borderColor = rank.pigment.withAlphaComponent(0.5).cgColor
        }
    }

    // MARK: - Navigation

    @objc func didTapBack() {
        saveProgress()
        for timer in reelTimers { timer?.invalidate() }
        sceneDelegate?.spindleRequestsReturn()
    }

    // MARK: - Helpers

    func sv(_ base: CGFloat) -> CGFloat {
        let ratio = min(UIScreen.main.bounds.width / 390, UIScreen.main.bounds.height / 844)
        return base * max(ratio, 0.75)
    }
}
