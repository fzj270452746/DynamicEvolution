// VortexBattleground.swift — Main Game Scene
import SpriteKit

class VortexBattleground: SKScene {

    let vaultEngine = NexusVault()

    var tileNodes: [GlyphTileNode] = []
    var spinButton: SKNode!
    var scoreLbl: SKLabelNode!
    var comboLbl: SKLabelNode!
    var apexLbl: SKLabelNode!
    var spinsLbl: SKLabelNode!
    var weightLbl: SKLabelNode!
    var questGoalLbl: SKLabelNode!
    var timerLbl: SKLabelNode!
    var isAnimating = false
    var timeRemaining: TimeInterval = 90
    var lastUpdateTime: TimeInterval = 0
    var timedGameOver = false

    // layout constants
    var tileSize: CGFloat { min(size.width * 0.21, 80) }
    var gridOriginX: CGFloat { size.width / 2 }
    var gridOriginY: CGFloat {
        // On shorter screens (iPad compat), push grid up to leave room for bottom labels
        let spinAreaTop = size.height * 0.1 + 29 // top edge of spin button
        let neededBelowGrid = (tileSize + 6) * 2 + 75 // half frame height + labels clearance
        return max(size.height * 0.46, spinAreaTop + neededBelowGrid)
    }
    var safeTop: CGFloat = 54

    override func didMove(to view: SKView) {
        let insets = view.safeAreaInsets
        safeTop = max(insets.top, 20)
        setupBackground()
        setupHUD()
        setupGrid()
        setupSpinButton()
    }

    // MARK: - Background
    func setupBackground() {
        let bg = SKSpriteNode(imageNamed: "bg_main_menu")
        bg.position  = CGPoint(x: size.width/2, y: size.height/2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)
        let overlay = SKSpriteNode(color: UIColor(red:0.04,green:0.04,blue:0.12,alpha:0.72), size: size)
        overlay.position  = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = -9
        addChild(overlay)
    }

    // MARK: - Grid
    func setupGrid() {
        let gap: CGFloat = tileSize + 6
        let startX = gridOriginX - gap * 1.5
        let startY = gridOriginY + gap * 1.5

        // Slot machine frame
        let frameW = gap * 4 + 20
        let frameH = gap * 4 + 20
        let frameBg = SKShapeNode(rectOf: CGSize(width: frameW, height: frameH), cornerRadius: 16)
        frameBg.fillColor   = UIColor(red:0.06,green:0.06,blue:0.16,alpha:0.92)
        frameBg.strokeColor = UIColor(red:1,green:0.84,blue:0,alpha:0.5)
        frameBg.lineWidth   = 2.0
        frameBg.position    = CGPoint(x: gridOriginX, y: gridOriginY)
        frameBg.zPosition   = 1
        addChild(frameBg)

        // outer glow ring
        let glowFrame = SKShapeNode(rectOf: CGSize(width: frameW + 10, height: frameH + 10), cornerRadius: 20)
        glowFrame.fillColor   = .clear
        glowFrame.strokeColor = UIColor(red:1,green:0.84,blue:0,alpha:0.15)
        glowFrame.lineWidth   = 5
        glowFrame.position    = CGPoint(x: gridOriginX, y: gridOriginY)
        glowFrame.zPosition   = 0
        addChild(glowFrame)

        // horizontal divider lines between rows
        for r in 1..<4 {
            let lineY = startY - CGFloat(r) * gap + gap / 2
            let line = SKShapeNode(rectOf: CGSize(width: frameW - 16, height: 0.5))
            line.fillColor   = UIColor(red:0.16,green:0.16,blue:0.44,alpha:0.5)
            line.strokeColor = .clear
            line.position    = CGPoint(x: gridOriginX, y: lineY)
            line.zPosition   = 2
            addChild(line)
        }

        // vertical divider lines between columns
        for c in 1..<4 {
            let lineX = startX + CGFloat(c) * gap - gap / 2
            let line = SKShapeNode(rectOf: CGSize(width: 0.5, height: frameH - 16))
            line.fillColor   = UIColor(red:0.16,green:0.16,blue:0.44,alpha:0.5)
            line.strokeColor = .clear
            line.position    = CGPoint(x: lineX, y: gridOriginY)
            line.zPosition   = 2
            addChild(line)
        }

        // tiles — default to empty slots
        for row in 0..<4 {
            for col in 0..<4 {
                let tile = GlyphTileNode(tier: .seedling, size: tileSize)
                tile.showAsEmptySlot()
                tile.position  = CGPoint(x: startX + CGFloat(col)*gap,
                                         y: startY - CGFloat(row)*gap)
                tile.zPosition = 3
                addChild(tile)
                tileNodes.append(tile)
            }
        }
    }

    func tilePosition(index: Int) -> CGPoint {
        let gap: CGFloat = tileSize + 6
        let startX = gridOriginX - gap * 1.5
        let startY = gridOriginY + gap * 1.5
        let row = index / 4; let col = index % 4
        return CGPoint(x: startX + CGFloat(col)*gap, y: startY - CGFloat(row)*gap)
    }

    // MARK: - Spin Button
    func setupSpinButton() {
        let cx = size.width / 2
        let btnY = size.height * 0.1

        let container = SKNode()
        container.position  = CGPoint(x: cx, y: btnY)
        container.zPosition = 8
        container.name      = "spinBtn"

        let bw: CGFloat = min(size.width * 0.55, 220)
        let bh: CGFloat = 58

        let shadow = SKShapeNode(rectOf: CGSize(width: bw+6, height: bh+6), cornerRadius: 29)
        shadow.fillColor   = UIColor(red:1,green:0.84,blue:0,alpha:0.18)
        shadow.strokeColor = .clear
        shadow.position    = CGPoint(x: 2, y: -3)
        container.addChild(shadow)

        let bg = SKShapeNode(rectOf: CGSize(width: bw, height: bh), cornerRadius: 29)
        bg.fillColor   = UIColor(red:0.12,green:0.12,blue:0.28,alpha:1)
        bg.strokeColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        bg.lineWidth   = 2.2
        bg.name        = "spinBtnBg"
        container.addChild(bg)

        let lbl = SKLabelNode(text: "S P I N")
        lbl.fontName  = "AvenirNext-Heavy"
        lbl.fontSize  = adaptiveFontSize(base: 22)
        lbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        lbl.verticalAlignmentMode = .center
        container.addChild(lbl)

        // idle pulse
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.04, duration: 0.9),
            SKAction.scale(to: 1.0,  duration: 0.9)
        ])
        container.run(SKAction.repeatForever(pulse))

        spinButton = container
        addChild(container)
    }

    // MARK: - Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let hit = atPoint(loc)

        if hit.name == "backBtn" || hit.parent?.name == "backBtn" {
            goBackToMenu(); return
        }

        if !isAnimating && !timedGameOver && (hit.name == "spinBtn" || hit.inParentHierarchy(spinButton)) {
            performSpin()
        }
    }

    // MARK: - Adaptive
    func adaptiveFontSize(base: CGFloat) -> CGFloat {
        let scale = min(size.width / 390, size.height / 844)
        return base * max(scale, 0.75)
    }
}
