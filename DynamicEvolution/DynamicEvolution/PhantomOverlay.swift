// PhantomOverlay.swift — Custom Modal Overlays
import SpriteKit
import StoreKit

// MARK: - PhantomOverlay

class PhantomOverlay: SKNode {

    // MARK: - Overlay Kinds

    enum OverlayKind {
        case gameWin(score: Int, apex: String)
        case questWin(score: Int, apex: String, level: Int)
        case gameLose(score: Int, apex: String)
        case timedResult(score: Int, apexTier: String, apexCount: Int)
        case dailyResult(score: Int, apex: String, won: Bool,
                          target: String, best: Int, streak: Int, dayLabel: String)
        case leaderboard
        case dailyChallenge
        case lifetimeStats
        case achievements
        case settings
        case codex
    }

    // MARK: - Callbacks

    var onDismiss:    (() -> Void)?
    var onNextLevel:  (() -> Void)?
    var onStartDaily: (() -> Void)?

    // MARK: - Properties

    let sceneSize: CGSize
    let kind: OverlayKind

    // MARK: - Init

    init(size: CGSize, kind: OverlayKind) {
        self.sceneSize = size
        self.kind      = kind
        super.init()
        isUserInteractionEnabled = true
        assemble()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Assembly

    private func assemble() {
        buildDimBg()

        switch kind {
        case .gameWin(let s, let a):
            buildResultPanel(won: true, score: s, apex: a, questLevel: nil)
        case .questWin(let s, let a, let l):
            buildResultPanel(won: true, score: s, apex: a, questLevel: l)
        case .gameLose(let s, let a):
            buildResultPanel(won: false, score: s, apex: a, questLevel: nil)
        case .timedResult(let s, let t, let c):
            buildTimedResultPanel(score: s, apexTier: t, apexCount: c)
        case .dailyResult(let s, let a, let w, let t, let b, let st, let dl):
            buildDailyResultPanel(score: s, apex: a, won: w,
                                  target: t, best: b, streak: st, dayLabel: dl)
        case .leaderboard:    buildLeaderboardPanel()
        case .dailyChallenge: buildDailyChallengePanel()
        case .lifetimeStats:  buildLifetimeStatsPanel()
        case .achievements:   buildAchievementsPanel()
        case .settings:       buildSettingsPanel()
        case .codex:          buildCodexPanel()
        }

        playEntrance()
    }

    private func buildDimBg() {
        let dim       = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.75),
                                     size: sceneSize)
        dim.position  = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        dim.zPosition = 0
        dim.name      = "dimBg"
        addChild(dim)
    }

    private func playEntrance() {
        alpha = 0
        setScale(0.90)
        run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.20),
            SKAction.scale(to: 1.0, duration: 0.20)
        ]))
    }

    // MARK: - Shared Factories

    func makePanel(width: CGFloat, height: CGFloat,
                   position: CGPoint, strokeColor: UIColor) -> SKShapeNode {
        let p = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 24)
        p.fillColor   = UIColor(red: 0.06, green: 0.03, blue: 0.18, alpha: 0.97)
        p.strokeColor = strokeColor
        p.lineWidth   = 2.0
        p.position    = position
        p.zPosition   = 1
        return p
    }

    func makeSeparator(width: CGFloat, position: CGPoint) -> SKShapeNode {
        let s = SKShapeNode(rectOf: CGSize(width: width, height: 0.8))
        s.fillColor   = UIColor(white: 1, alpha: 0.10)
        s.strokeColor = .clear
        s.position    = position
        s.zPosition   = 2
        return s
    }

    func makeStatRow(label: String, value: String, y: CGFloat,
                     labelColor: UIColor, valueColor: UIColor,
                     panelWidth: CGFloat) -> SKNode {
        let cx = sceneSize.width / 2
        let ln = SKLabelNode(text: label)
        ln.fontName  = "AvenirNext-Medium"
        ln.fontSize  = adaptiveFontSize(base: 14)
        ln.fontColor = labelColor
        ln.horizontalAlignmentMode = .left
        ln.verticalAlignmentMode   = .center
        ln.position  = CGPoint(x: cx - panelWidth * 0.38, y: y)
        ln.zPosition = 2

        let vn = SKLabelNode(text: value)
        vn.fontName  = "AvenirNext-Bold"
        vn.fontSize  = adaptiveFontSize(base: 14)
        vn.fontColor = valueColor
        vn.horizontalAlignmentMode = .right
        vn.verticalAlignmentMode   = .center
        vn.position  = CGPoint(x: cx + panelWidth * 0.38, y: y)
        vn.zPosition = 2

        let c = SKNode()
        c.addChild(ln)
        c.addChild(vn)
        return c
    }

    func makeButton(title: String, color: UIColor,
                    position: CGPoint, name: String) -> SKNode {
        let c      = SKNode()
        c.position = position
        c.zPosition = 2
        c.name     = name

        let bw: CGFloat = min(sceneSize.width * 0.55, 220)
        let bh: CGFloat = 46

        let shadow = SKShapeNode(rectOf: CGSize(width: bw + 4, height: bh + 4), cornerRadius: bh / 2)
        shadow.fillColor   = color.withAlphaComponent(0.10)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 1, y: -2)
        shadow.zPosition   = -1
        c.addChild(shadow)

        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: bh / 2)
        bg.fillColor   = UIColor(red: 0.08, green: 0.04, blue: 0.22, alpha: 0.96)
        bg.strokeColor = color.withAlphaComponent(0.80)
        bg.lineWidth   = 1.6
        c.addChild(bg)

        let lbl      = SKLabelNode(text: title)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: 16)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        c.addChild(lbl)

        return c
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        func isIn(_ name: String) -> Bool {
            hit.name == name || hit.parent?.name == name
        }

        if isIn("nextLevelBtn") {
            animateTap(named: "nextLevelBtn") { [weak self] in self?.handleNextLevel() }
        } else if isIn("retryBtn") {
            animateTap(named: "retryBtn") { [weak self] in self?.handleRetry() }
        } else if isIn("rateBtn") {
            animateTap(named: "rateBtn") { [weak self] in self?.openRating() }
        } else if isIn("dailyStartBtn") {
            animateTap(named: "dailyStartBtn") { [weak self] in self?.handleDailyStart() }
        } else if isIn("menuBtn") || isIn("closeBtn") {
            let n = hit.name ?? hit.parent?.name ?? ""
            animateTap(named: n) { [weak self] in self?.dismiss() }
        } else if isIn("dimBg") && isDismissableByTap {
            dismiss()
        }
    }

    private var isDismissableByTap: Bool {
        switch kind {
        case .codex, .leaderboard, .settings,
             .dailyChallenge, .lifetimeStats, .achievements:
            return true
        default:
            return false
        }
    }

    // MARK: - Actions

    private func animateTap(named: String, completion: @escaping () -> Void) {
        guard let node = childNode(withName: "//\(named)") else {
            completion(); return
        }
        node.run(SKAction.sequence([
            SKAction.scale(to: 0.92, duration: 0.06),
            SKAction.scale(to: 1.0,  duration: 0.09),
            SKAction.run(completion)
        ]))
    }

    private func handleNextLevel() {
        run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.18),
                SKAction.scale(to: 0.90, duration: 0.18)
            ]),
            SKAction.run { [weak self] in
                self?.onNextLevel?()
                self?.removeFromParent()
            }
        ]))
    }

    private func handleRetry() {
        guard let scene = scene as? VortexBattleground else { dismiss(); return }
        dismiss()
        scene.vaultEngine.configureWarpMode(scene.vaultEngine.warpMode)
        scene.restartGame()
    }

    private func handleDailyStart() {
        run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.18),
                SKAction.scale(to: 0.90, duration: 0.18)
            ]),
            SKAction.run { [weak self] in
                self?.onStartDaily?()
                self?.removeFromParent()
            }
        ]))
    }

    func dismiss() {
        run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.18),
                SKAction.scale(to: 0.90, duration: 0.18)
            ]),
            SKAction.run { [weak self] in
                self?.onDismiss?()
                self?.removeFromParent()
            }
        ]))
    }

    private func openRating() {
        guard let scene = scene,
              let ws = scene.view?.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: ws)
    }

    // MARK: - Adaptive Font

    func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(sceneSize.width / 390, sceneSize.height / 844)
        return base * max(scale, 0.75)
    }
}

// MARK: - Equatable

extension PhantomOverlay.OverlayKind: Equatable {
    static func == (lhs: PhantomOverlay.OverlayKind,
                    rhs: PhantomOverlay.OverlayKind) -> Bool {
        switch (lhs, rhs) {
        case (.codex, .codex),
             (.questWin, .questWin),
             (.leaderboard, .leaderboard),
             (.settings, .settings),
             (.dailyChallenge, .dailyChallenge),
             (.lifetimeStats, .lifetimeStats),
             (.achievements, .achievements),
             (.dailyResult, .dailyResult),
             (.gameWin, .gameWin),
             (.gameLose, .gameLose),
             (.timedResult, .timedResult):
            return true
        default:
            return false
        }
    }
}
