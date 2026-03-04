// PhantomOverlay.swift — Custom Modal Overlays
import SpriteKit
import StoreKit

class PhantomOverlay: SKNode {

    enum OverlayKind {
        case gameWin(score: Int, apex: String)
        case questWin(score: Int, apex: String, level: Int)
        case gameLose(score: Int, apex: String)
        case timedResult(score: Int, apexTier: String, apexCount: Int)
        case leaderboard
        case settings
        case codex
    }

    var onDismiss: (() -> Void)?
    var onNextLevel: (() -> Void)?
    let sceneSize: CGSize
    let kind: OverlayKind

    init(size: CGSize, kind: OverlayKind) {
        self.sceneSize = size
        self.kind = kind
        super.init()
        isUserInteractionEnabled = true
        buildOverlay()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Build
    private func buildOverlay() {
        // dim background
        let dim = SKSpriteNode(color: UIColor(red:0,green:0,blue:0,alpha:0.72), size: sceneSize)
        dim.position  = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        dim.zPosition = 0
        dim.name      = "dimBg"
        addChild(dim)

        switch kind {
        case .gameWin(let score, let apex):
            buildResultPanel(won: true, score: score, apex: apex, questLevel: nil)
        case .questWin(let score, let apex, let level):
            buildResultPanel(won: true, score: score, apex: apex, questLevel: level)
        case .gameLose(let score, let apex):
            buildResultPanel(won: false, score: score, apex: apex, questLevel: nil)
        case .timedResult(let score, let apexTier, let apexCount):
            buildTimedResultPanel(score: score, apexTier: apexTier, apexCount: apexCount)
        case .leaderboard:
            buildLeaderboardPanel()
        case .settings:
            buildSettingsPanel()
        case .codex:
            buildCodexPanel()
        }

        // entrance animation
        alpha = 0
        setScale(0.92)
        run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.22),
            SKAction.scale(to: 1.0, duration: 0.22)
        ]))
    }

    // MARK: - Button Factory
    func makeButton(title: String, color: UIColor,
                    position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position  = position
        container.zPosition = 2
        container.name      = name

        let bw: CGFloat = min(sceneSize.width * 0.55, 220)
        let bh: CGFloat = 46

        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 23)
        bg.fillColor   = UIColor(red:0.1,green:0.1,blue:0.24,alpha:0.95)
        bg.strokeColor = color.withAlphaComponent(0.85)
        bg.lineWidth   = 1.8
        container.addChild(bg)

        let lbl = SKLabelNode(text: title)
        lbl.fontName  = "AvenirNext-Bold"
        lbl.fontSize  = adaptiveFontSize(base: 16)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        container.addChild(lbl)

        return container
    }

    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        func isIn(_ name: String) -> Bool {
            hit.name == name || hit.parent?.name == name
        }

        if isIn("nextLevelBtn") {
            animateTap(named: "nextLevelBtn") { [weak self] in
                self?.handleNextLevel()
            }
        } else if isIn("retryBtn") {
            animateTap(named: "retryBtn") { [weak self] in
                self?.handleRetry()
            }
        } else if isIn("rateBtn") {
            animateTap(named: "rateBtn") { [weak self] in
                self?.openAppRating()
            }
        } else if isIn("menuBtn") || isIn("closeBtn") {
            animateTap(named: hit.name ?? hit.parent?.name ?? "") { [weak self] in
                self?.dismiss()
            }
        } else if isIn("dimBg") && (kind == .codex || kind == .leaderboard || kind == .settings) {
            dismiss()
        }
    }

    private func animateTap(named: String, completion: @escaping () -> Void) {
        guard let node = childNode(withName: "//\(named)") else { completion(); return }
        let shrink  = SKAction.scale(to: 0.93, duration: 0.07)
        let restore = SKAction.scale(to: 1.0,  duration: 0.10)
        node.run(SKAction.sequence([shrink, restore, SKAction.run(completion)]))
    }

    private func handleNextLevel() {
        run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.18),
                SKAction.scale(to: 0.92, duration: 0.18)
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

    func dismiss() {
        run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.18),
                SKAction.scale(to: 0.92, duration: 0.18)
            ]),
            SKAction.run { [weak self] in
                self?.onDismiss?()
                self?.removeFromParent()
            }
        ]))
    }

    private func openAppRating() {
        guard let scene = scene else { return }
        if let windowScene = scene.view?.window?.windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    // MARK: - Adaptive
    func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(sceneSize.width / 390, sceneSize.height / 844)
        return base * max(scale, 0.75)
    }
}

// Make OverlayKind equatable for codex tap-outside check
extension PhantomOverlay.OverlayKind: Equatable {
    static func == (lhs: PhantomOverlay.OverlayKind, rhs: PhantomOverlay.OverlayKind) -> Bool {
        switch (lhs, rhs) {
        case (.codex, .codex): return true
        case (.questWin, .questWin): return true
        case (.leaderboard, .leaderboard): return true
        case (.settings, .settings): return true
        default: return false
        }
    }
}
