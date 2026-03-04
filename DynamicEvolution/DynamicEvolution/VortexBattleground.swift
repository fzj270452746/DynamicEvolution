// VortexBattleground.swift — Main Game Scene
import SpriteKit

// MARK: - VortexBattleground

/// The primary gameplay scene hosting the 4×4 glyph grid, HUD elements,
/// spin button, and all game logic interactions.
/// Subclasses or extensions handle spin flow, HUD layout, animations, and end-game.
class VortexBattleground: SKScene {

    // MARK: - Core Engine

    /// The model layer managing all game state, probability weights, and fusion logic.
    let vaultEngine = NexusVault()

    // MARK: - Grid State

    /// Ordered array of 16 tile nodes matching `vaultEngine.gridCells` by index.
    var tileNodes: [GlyphTileNode] = []

    // MARK: - HUD Label References

    var scoreLbl:     SKLabelNode!
    var comboLbl:     SKLabelNode!
    var apexLbl:      SKLabelNode!
    var spinsLbl:     SKLabelNode!
    var weightLbl:    SKLabelNode!
    var questGoalLbl: SKLabelNode!
    var timerLbl:     SKLabelNode!

    // MARK: - Control Nodes

    var spinButton: SKNode!

    // MARK: - Animation & Timer State

    /// True while a spin or fusion animation sequence is in progress.
    /// Spin button taps are ignored during this window.
    var isAnimating = false

    /// Remaining seconds in timed blitz mode; counts down each frame.
    var timeRemaining: TimeInterval = 90

    /// Timestamp from the previous `update(_:)` call, used to compute delta time.
    var lastUpdateTime: TimeInterval = 0

    /// Latched true once the timed blitz timer reaches zero to prevent re-entry.
    var timedGameOver = false

    // MARK: - Layout Constants

    /// Uniform tile size derived from screen width, capped for legibility.
    var tileSize: CGFloat { min(size.width * 0.21, 80) }

    /// Horizontal center of the grid (same as scene horizontal center).
    var gridOriginX: CGFloat { size.width / 2 }

    /// Vertical center of the grid. Pushed upward on shorter screens to ensure
    /// the spin button and weight label fit below without overlap.
    var gridOriginY: CGFloat {
        let spinAreaTop       = size.height * 0.1 + 29
        let neededBelowGrid   = (tileSize + 6) * 2 + 75
        return max(size.height * 0.46, spinAreaTop + neededBelowGrid)
    }

    /// Effective top of the safe area; accounts for Dynamic Island / notch.
    var safeTop: CGFloat = 54

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        safeTop = max(view.safeAreaInsets.top, 20)
        setupBackground()
        setupHUD()
        setupGrid()
        setupSpinButton()
    }

    // MARK: - Background

    /// Build a two-layer background: theme image + dark translucent overlay.
    func setupBackground() {
        let bg       = SKSpriteNode(imageNamed: "bg_main_menu")
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)

        let overlay  = SKSpriteNode(
            color: UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 0.72),
            size: size
        )
        overlay.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -9
        addChild(overlay)
    }

    // MARK: - Grid Construction

    /// Build the 4×4 tile grid with its decorative frame, divider lines, and initial empty tiles.
    func setupGrid() {
        let gap    = tileSize + 6
        let startX = gridOriginX - gap * 1.5
        let startY = gridOriginY + gap * 1.5

        setupGridFrame(gap: gap)
        setupGridDividers(startX: startX, startY: startY, gap: gap)
        populateGridTiles(startX: startX, startY: startY, gap: gap)
    }

    /// Create the rounded background frame and outer glow ring for the grid.
    private func setupGridFrame(gap: CGFloat) {
        let frameW = gap * 4 + 20
        let frameH = gap * 4 + 20

        // Inner frame background
        let frameBg = SKShapeNode(rectOf: CGSize(width: frameW, height: frameH), cornerRadius: 16)
        frameBg.fillColor   = UIColor(red: 0.06, green: 0.06, blue: 0.16, alpha: 0.92)
        frameBg.strokeColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.5)
        frameBg.lineWidth   = 2.0
        frameBg.position    = CGPoint(x: gridOriginX, y: gridOriginY)
        frameBg.zPosition   = 1
        addChild(frameBg)

        // Outer glow ring for visual depth
        let glowFrame = SKShapeNode(
            rectOf: CGSize(width: frameW + 10, height: frameH + 10), cornerRadius: 20
        )
        glowFrame.fillColor   = .clear
        glowFrame.strokeColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.15)
        glowFrame.lineWidth   = 5
        glowFrame.position    = CGPoint(x: gridOriginX, y: gridOriginY)
        glowFrame.zPosition   = 0
        addChild(glowFrame)
    }

    /// Draw horizontal and vertical divider lines between grid cells.
    private func setupGridDividers(startX: CGFloat, startY: CGFloat, gap: CGFloat) {
        let frameW = gap * 4 + 20
        let frameH = gap * 4 + 20
        let dividerColor = UIColor(red: 0.16, green: 0.16, blue: 0.44, alpha: 0.5)

        // Horizontal dividers between rows
        for r in 1..<4 {
            let lineY = startY - CGFloat(r) * gap + gap / 2
            let line  = SKShapeNode(rectOf: CGSize(width: frameW - 16, height: 0.5))
            line.fillColor   = dividerColor
            line.strokeColor = .clear
            line.position    = CGPoint(x: gridOriginX, y: lineY)
            line.zPosition   = 2
            addChild(line)
        }

        // Vertical dividers between columns
        for c in 1..<4 {
            let lineX = startX + CGFloat(c) * gap - gap / 2
            let line  = SKShapeNode(rectOf: CGSize(width: 0.5, height: frameH - 16))
            line.fillColor   = dividerColor
            line.strokeColor = .clear
            line.position    = CGPoint(x: lineX, y: gridOriginY)
            line.zPosition   = 2
            addChild(line)
        }
    }

    /// Instantiate 16 `GlyphTileNode` objects at their grid positions, all initially empty.
    private func populateGridTiles(startX: CGFloat, startY: CGFloat, gap: CGFloat) {
        for row in 0..<4 {
            for col in 0..<4 {
                let tile = GlyphTileNode(tier: .seedling, size: tileSize)
                tile.showAsEmptySlot()
                tile.position  = CGPoint(
                    x: startX + CGFloat(col) * gap,
                    y: startY - CGFloat(row) * gap
                )
                tile.zPosition = 3
                addChild(tile)
                tileNodes.append(tile)
            }
        }
    }

    /// Calculate the scene-space position for a tile at a given flat grid index.
    func tilePosition(index: Int) -> CGPoint {
        let gap    = tileSize + 6
        let startX = gridOriginX - gap * 1.5
        let startY = gridOriginY + gap * 1.5
        let row    = index / 4
        let col    = index % 4
        return CGPoint(x: startX + CGFloat(col) * gap, y: startY - CGFloat(row) * gap)
    }

    // MARK: - Spin Button

    /// Build and position the central SPIN button below the grid.
    func setupSpinButton() {
        let cx   = size.width / 2
        let btnY = size.height * 0.1

        let container      = SKNode()
        container.position = CGPoint(x: cx, y: btnY)
        container.zPosition = 8
        container.name     = "spinBtn"

        let bw: CGFloat = min(size.width * 0.55, 220)
        let bh: CGFloat = 58

        // Outer shadow glow
        let shadow = SKShapeNode(rectOf: CGSize(width: bw + 6, height: bh + 6), cornerRadius: 29)
        shadow.fillColor   = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.18)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 2, y: -3)
        container.addChild(shadow)

        // Button background capsule
        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 29)
        bg.fillColor   = UIColor(red: 0.12, green: 0.12, blue: 0.28, alpha: 1)
        bg.strokeColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        bg.lineWidth   = 2.2
        bg.name        = "spinBtnBg"
        container.addChild(bg)

        // "S P I N" text label
        let lbl      = SKLabelNode(text: "S P I N")
        lbl.fontName = "AvenirNext-Heavy"
        lbl.fontSize = adaptiveFontSize(base: 22)
        lbl.fontColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        lbl.verticalAlignmentMode = .center
        container.addChild(lbl)

        // Idle breathing pulse to draw attention
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 0.9),
            SKAction.scale(to: 1.0,  duration: 0.9)
        ])
        container.run(SKAction.repeatForever(pulse))

        spinButton = container
        addChild(container)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        // Back-to-menu button (created in setupHUD)
        if hit.name == "backBtn" || hit.parent?.name == "backBtn" {
            goBackToMenu()
            return
        }

        // Spin button — only active when no animation is running
        if !isAnimating && !timedGameOver &&
           (hit.name == "spinBtn" || hit.inParentHierarchy(spinButton)) {
            performSpin()
        }
    }

    // MARK: - Adaptive Sizing

    /// Scale a base font size proportionally to the current scene dimensions.
    func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(size.width / 390, size.height / 844)
        return base * max(scale, 0.75)
    }
}
