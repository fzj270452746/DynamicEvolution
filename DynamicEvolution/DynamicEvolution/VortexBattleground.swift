// VortexBattleground.swift — Main Game Scene
import SpriteKit

// MARK: - VortexBattleground

/// The primary gameplay scene hosting the 4×4 glyph grid, HUD elements,
/// spin button, and all game logic interactions.
class VortexBattleground: SKScene {

    // MARK: - Core Engine

    let vaultEngine = NexusVault()

    // MARK: - Grid State

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

    var isAnimating = false
    var timeRemaining: TimeInterval = 90
    var lastUpdateTime: TimeInterval = 0
    var timedGameOver = false
    var didRecordSession = false

    // MARK: - Layout Constants

    var tileSize: CGFloat { min(size.width * 0.21, 80) }
    var gridOriginX: CGFloat { size.width / 2 }
    var gridOriginY: CGFloat {
        let spinAreaTop     = size.height * 0.1 + 29
        let neededBelow     = (tileSize + 6) * 2 + 75
        return max(size.height * 0.46, spinAreaTop + neededBelow)
    }
    var safeTop: CGFloat = 54

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        safeTop = max(view.safeAreaInsets.top, 20)
        buildBackground()
        setupHUD()
        buildGrid()
        buildSpinButton()
    }

    // MARK: - Background

    func buildBackground() {
        let bg       = SKSpriteNode(imageNamed: "bg_main_menu")
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)

        let overlay = SKSpriteNode(
            color: UIColor(red: 0.04, green: 0.02, blue: 0.14, alpha: 0.75),
            size: size
        )
        overlay.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -9
        addChild(overlay)
    }

    // MARK: - Grid Construction

    func buildGrid() {
        let gap    = tileSize + 6
        let startX = gridOriginX - gap * 1.5
        let startY = gridOriginY + gap * 1.5

        buildGridFrame(gap: gap)
        buildGridDividers(startX: startX, startY: startY, gap: gap)
        populateEmptyTiles(startX: startX, startY: startY, gap: gap)
    }

    private func buildGridFrame(gap: CGFloat) {
        let frameW = gap * 4 + 22
        let frameH = gap * 4 + 22

        let bg = SKShapeNode(rectOf: CGSize(width: frameW, height: frameH), cornerRadius: 18)
        bg.fillColor   = UIColor(red: 0.05, green: 0.03, blue: 0.16, alpha: 0.94)
        bg.strokeColor = UIColor(red: 0, green: 0.90, blue: 0.80, alpha: 0.45)
        bg.lineWidth   = 2.0
        bg.position    = CGPoint(x: gridOriginX, y: gridOriginY)
        bg.zPosition   = 1
        addChild(bg)

        let glow = SKShapeNode(
            rectOf: CGSize(width: frameW + 12, height: frameH + 12), cornerRadius: 22
        )
        glow.fillColor   = .clear
        glow.strokeColor = UIColor(red: 0.61, green: 0.37, blue: 1, alpha: 0.12)
        glow.lineWidth   = 5
        glow.position    = CGPoint(x: gridOriginX, y: gridOriginY)
        glow.zPosition   = 0
        addChild(glow)
    }

    private func buildGridDividers(startX: CGFloat, startY: CGFloat, gap: CGFloat) {
        let frameW = gap * 4 + 22
        let frameH = gap * 4 + 22
        let dColor = UIColor(red: 0.22, green: 0.12, blue: 0.44, alpha: 0.45)

        for r in 1..<4 {
            let lineY = startY - CGFloat(r) * gap + gap / 2
            let line  = SKShapeNode(rectOf: CGSize(width: frameW - 18, height: 0.5))
            line.fillColor   = dColor
            line.strokeColor = .clear
            line.position    = CGPoint(x: gridOriginX, y: lineY)
            line.zPosition   = 2
            addChild(line)
        }

        for c in 1..<4 {
            let lineX = startX + CGFloat(c) * gap - gap / 2
            let line  = SKShapeNode(rectOf: CGSize(width: 0.5, height: frameH - 18))
            line.fillColor   = dColor
            line.strokeColor = .clear
            line.position    = CGPoint(x: lineX, y: gridOriginY)
            line.zPosition   = 2
            addChild(line)
        }
    }

    private func populateEmptyTiles(startX: CGFloat, startY: CGFloat, gap: CGFloat) {
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

    func tilePosition(index: Int) -> CGPoint {
        let gap    = tileSize + 6
        let startX = gridOriginX - gap * 1.5
        let startY = gridOriginY + gap * 1.5
        let row    = index / 4
        let col    = index % 4
        return CGPoint(x: startX + CGFloat(col) * gap, y: startY - CGFloat(row) * gap)
    }

    // MARK: - Spin Button

    func buildSpinButton() {
        let cx   = size.width / 2
        let btnY = size.height * 0.1

        let container      = SKNode()
        container.position = CGPoint(x: cx, y: btnY)
        container.zPosition = 8
        container.name     = "spinBtn"

        let bw: CGFloat = min(size.width * 0.55, 220)
        let bh: CGFloat = 56

        let shadow = SKShapeNode(rectOf: CGSize(width: bw + 6, height: bh + 6), cornerRadius: bh / 2)
        shadow.fillColor   = UIColor(red: 0, green: 0.90, blue: 0.80, alpha: 0.14)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 2, y: -3)
        container.addChild(shadow)

        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: bh / 2)
        bg.fillColor   = UIColor(red: 0.08, green: 0.05, blue: 0.22, alpha: 1)
        bg.strokeColor = UIColor(red: 0, green: 0.90, blue: 0.80, alpha: 1)
        bg.lineWidth   = 2.2
        bg.name        = "spinBtnBg"
        container.addChild(bg)

        let lbl      = SKLabelNode(text: "S P I N")
        lbl.fontName = "AvenirNext-Heavy"
        lbl.fontSize = adaptiveFontSize(base: 22)
        lbl.fontColor = UIColor(red: 0, green: 0.92, blue: 0.82, alpha: 1)
        lbl.verticalAlignmentMode = .center
        container.addChild(lbl)

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

        if hit.name == "backBtn" || hit.parent?.name == "backBtn" {
            goBackToMenu()
            return
        }

        if !isAnimating && !timedGameOver &&
           (hit.name == "spinBtn" || hit.inParentHierarchy(spinButton)) {
            performSpin()
        }
    }

    // MARK: - Adaptive Sizing

    func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(size.width / 390, size.height / 844)
        return base * max(scale, 0.75)
    }
}
