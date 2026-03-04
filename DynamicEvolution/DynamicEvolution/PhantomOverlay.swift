// PhantomOverlay.swift — Custom Modal Overlays
import SpriteKit
import StoreKit

// MARK: - PhantomOverlay

/// A modal overlay node presented on top of the active scene.
/// Supports multiple content types: result panels, info panels, and reference panels.
/// All overlays share a dimmed background and animated entrance/exit transitions.
class PhantomOverlay: SKNode {

    // MARK: - Overlay Kinds

    /// The type of content this overlay displays.
    enum OverlayKind {
        /// Generic win screen (not quest-specific)
        case gameWin(score: Int, apex: String)
        /// Quest level completion screen with level number
        case questWin(score: Int, apex: String, level: Int)
        /// Game over / quest failed screen
        case gameLose(score: Int, apex: String)
        /// Timed blitz session result
        case timedResult(score: Int, apexTier: String, apexCount: Int)
        /// Top-10 leaderboard browser
        case leaderboard
        /// How-to-play instructions and app rating
        case settings
        /// Symbol collection and base score reference
        case codex
    }

    // MARK: - Callbacks

    /// Called when the player dismisses the overlay (menu button or close button).
    var onDismiss: (() -> Void)?

    /// Called when the player taps "Next Level" on a quest win overlay.
    var onNextLevel: (() -> Void)?

    // MARK: - Properties

    /// The size of the parent scene, used for positioning all child nodes.
    let sceneSize: CGSize

    /// The type of content being displayed.
    let kind: OverlayKind

    // MARK: - Initialization

    init(size: CGSize, kind: OverlayKind) {
        self.sceneSize = size
        self.kind      = kind
        super.init()
        isUserInteractionEnabled = true
        buildOverlay()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Overlay Construction

    /// Assemble the dim background and delegate to the appropriate content builder.
    private func buildOverlay() {
        buildDimBackground()

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

        animateEntrance()
    }

    /// Create the semi-transparent black background that dims the scene behind the overlay.
    private func buildDimBackground() {
        let dim          = SKSpriteNode(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.72),
                                        size: sceneSize)
        dim.position     = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        dim.zPosition    = 0
        dim.name         = "dimBg"
        addChild(dim)
    }

    /// Play the pop-in entrance animation when the overlay first appears.
    private func animateEntrance() {
        alpha = 0
        setScale(0.92)
        run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.22),
            SKAction.scale(to: 1.0, duration: 0.22)
        ]))
    }

    // MARK: - Shared UI Factories

    /// Create a rounded panel background shape node.
    /// - Parameters:
    ///   - width: Panel width.
    ///   - height: Panel height.
    ///   - position: Scene-space center position.
    ///   - strokeColor: Border color.
    /// - Returns: Configured `SKShapeNode` for use as a panel background.
    func makePanel(width: CGFloat, height: CGFloat,
                   position: CGPoint, strokeColor: UIColor) -> SKShapeNode {
        let panel = SKShapeNode(
            rectOf: CGSize(width: width, height: height), cornerRadius: 22
        )
        panel.fillColor   = UIColor(red: 0.07, green: 0.07, blue: 0.18, alpha: 0.97)
        panel.strokeColor = strokeColor
        panel.lineWidth   = 2.2
        panel.position    = position
        panel.zPosition   = 1
        return panel
    }

    /// Create a thin horizontal separator line.
    /// - Parameters:
    ///   - width: Total line width.
    ///   - position: Scene-space center position.
    /// - Returns: A hairline `SKShapeNode` separator.
    func makeSeparator(width: CGFloat, position: CGPoint) -> SKShapeNode {
        let sep = SKShapeNode(rectOf: CGSize(width: width, height: 0.8))
        sep.fillColor   = UIColor(white: 1, alpha: 0.12)
        sep.strokeColor = .clear
        sep.position    = position
        sep.zPosition   = 2
        return sep
    }

    /// Create a label-value pair row for displaying a single stat.
    /// - Parameters:
    ///   - label: Left-aligned descriptor text.
    ///   - value: Right-aligned value text.
    ///   - y: Vertical center position of this row.
    ///   - labelColor: Color for the label text.
    ///   - valueColor: Color for the value text.
    ///   - panelWidth: The panel width used to calculate x offsets.
    func makeStatRow(label: String, value: String, y: CGFloat,
                     labelColor: UIColor, valueColor: UIColor, panelWidth: CGFloat) -> SKNode {
        let cx = sceneSize.width / 2

        let labelNode = SKLabelNode(text: label)
        labelNode.fontName  = "AvenirNext-Medium"
        labelNode.fontSize  = adaptiveFontSize(base: 14)
        labelNode.fontColor = labelColor
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode   = .center
        labelNode.position    = CGPoint(x: cx - panelWidth * 0.38, y: y)
        labelNode.zPosition   = 2

        let valueNode = SKLabelNode(text: value)
        valueNode.fontName  = "AvenirNext-Bold"
        valueNode.fontSize  = adaptiveFontSize(base: 14)
        valueNode.fontColor = valueColor
        valueNode.horizontalAlignmentMode = .right
        valueNode.verticalAlignmentMode   = .center
        valueNode.position    = CGPoint(x: cx + panelWidth * 0.38, y: y)
        valueNode.zPosition   = 2

        let container = SKNode()
        container.addChild(labelNode)
        container.addChild(valueNode)
        return container
    }

    /// Create a styled overlay button with colored border and text label.
    /// - Parameters:
    ///   - title: Button label text.
    ///   - color: Stroke and text color.
    ///   - position: Center position.
    ///   - name: Node name for touch-hit detection.
    func makeButton(title: String, color: UIColor,
                    position: CGPoint, name: String) -> SKNode {
        let container      = SKNode()
        container.position = position
        container.zPosition = 2
        container.name     = name

        let bw: CGFloat = min(sceneSize.width * 0.55, 220)
        let bh: CGFloat = 46

        // Drop shadow for depth
        let shadow = SKShapeNode(rectOf: CGSize(width: bw + 4, height: bh + 4), cornerRadius: 23)
        shadow.fillColor   = color.withAlphaComponent(0.12)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 1, y: -2)
        shadow.zPosition   = -1
        container.addChild(shadow)

        // Button background
        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 23)
        bg.fillColor   = UIColor(red: 0.1, green: 0.1, blue: 0.24, alpha: 0.95)
        bg.strokeColor = color.withAlphaComponent(0.85)
        bg.lineWidth   = 1.8
        container.addChild(bg)

        // Label
        let lbl      = SKLabelNode(text: title)
        lbl.fontName = "AvenirNext-Bold"
        lbl.fontSize = adaptiveFontSize(base: 16)
        lbl.fontColor = color
        lbl.verticalAlignmentMode = .center
        container.addChild(lbl)

        return container
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
            animateTap(named: "rateBtn") { [weak self] in self?.openAppRating() }
        } else if isIn("menuBtn") || isIn("closeBtn") {
            let name = hit.name ?? hit.parent?.name ?? ""
            animateTap(named: name) { [weak self] in self?.dismiss() }
        } else if isIn("dimBg") && (kind == .codex || kind == .leaderboard || kind == .settings) {
            dismiss()
        }
    }

    // MARK: - Button Action Handlers

    /// Play a scale-down-and-restore animation on a named descendant node, then execute a block.
    private func animateTap(named: String, completion: @escaping () -> Void) {
        guard let node = childNode(withName: "//\(named)") else {
            completion()
            return
        }
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

    // MARK: - Dismiss

    /// Animate the overlay out and then remove it from the node tree.
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

    // MARK: - App Rating

    private func openAppRating() {
        guard let scene = scene,
              let windowScene = scene.view?.window?.windowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }

    // MARK: - Adaptive Sizing

    /// Scale a base font size proportionally to the current scene size.
    func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(sceneSize.width / 390, sceneSize.height / 844)
        return base * max(scale, 0.75)
    }
}

// MARK: - OverlayKind: Equatable

/// Equatable conformance used for tap-outside dismissal guard in touch handling.
extension PhantomOverlay.OverlayKind: Equatable {
    static func == (lhs: PhantomOverlay.OverlayKind,
                    rhs: PhantomOverlay.OverlayKind) -> Bool {
        switch (lhs, rhs) {
        case (.codex,       .codex):       return true
        case (.questWin,    .questWin):    return true
        case (.leaderboard, .leaderboard): return true
        case (.settings,    .settings):    return true
        default:                           return false
        }
    }
}
