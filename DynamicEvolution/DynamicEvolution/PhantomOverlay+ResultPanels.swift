// PhantomOverlay+ResultPanels.swift — Game Result Panels
import SpriteKit

extension PhantomOverlay {

    // MARK: - Result Panel
    func buildResultPanel(won: Bool, score: Int, apex: String, questLevel: Int?) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.82, 340)
        let ph: CGFloat = min(sceneSize.height * 0.52, 420)

        // panel bg
        let panel = SKShapeNode(rectOf: CGSize(width: pw, height: ph), cornerRadius: 22)
        panel.fillColor   = UIColor(red:0.07,green:0.07,blue:0.18,alpha:0.97)
        panel.strokeColor = won
            ? UIColor(red:1,green:0.84,blue:0,alpha:0.9)
            : UIColor(red:1,green:0.19,blue:0.19,alpha:0.9)
        panel.lineWidth   = 2.2
        panel.position    = CGPoint(x: cx, y: cy)
        panel.zPosition   = 1
        addChild(panel)

        // glow ring
        let ring = SKShapeNode(rectOf: CGSize(width: pw+12, height: ph+12), cornerRadius: 26)
        ring.fillColor   = .clear
        ring.strokeColor = won
            ? UIColor(red:1,green:0.84,blue:0,alpha:0.18)
            : UIColor(red:1,green:0.19,blue:0.19,alpha:0.18)
        ring.lineWidth   = 6
        ring.position    = CGPoint(x: cx, y: cy)
        ring.zPosition   = 0
        addChild(ring)

        // emoji / icon
        let iconLbl = SKLabelNode(text: won ? "🏆" : "💀")
        iconLbl.fontSize = adaptiveFontSize(base: 52)
        iconLbl.verticalAlignmentMode = .center
        iconLbl.position  = CGPoint(x: cx, y: cy + ph*0.32)
        iconLbl.zPosition = 2
        addChild(iconLbl)
        iconLbl.setScale(0.3)
        iconLbl.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))

        // title
        let titleText: String
        if let lvl = questLevel {
            titleText = "LEVEL \(lvl) CLEAR!"
        } else {
            titleText = won ? "VICTORY!" : "GAME OVER"
        }
        let titleLbl = SKLabelNode(text: titleText)
        titleLbl.fontName  = "AvenirNext-Heavy"
        titleLbl.fontSize  = adaptiveFontSize(base: 30)
        titleLbl.fontColor = won
            ? UIColor(red:1,green:0.84,blue:0,alpha:1)
            : UIColor(red:1,green:0.19,blue:0.19,alpha:1)
        titleLbl.verticalAlignmentMode = .center
        titleLbl.position  = CGPoint(x: cx, y: cy + ph*0.14)
        titleLbl.zPosition = 2
        addChild(titleLbl)

        // score
        let scoreLbl = SKLabelNode(text: "SCORE  \(score)")
        scoreLbl.fontName  = "AvenirNext-Bold"
        scoreLbl.fontSize  = adaptiveFontSize(base: 22)
        scoreLbl.fontColor = UIColor(white: 0.95, alpha: 1)
        scoreLbl.verticalAlignmentMode = .center
        scoreLbl.position  = CGPoint(x: cx, y: cy - ph*0.02)
        scoreLbl.zPosition = 2
        addChild(scoreLbl)

        // apex
        let apexLbl = SKLabelNode(text: "APEX  \(apex)")
        apexLbl.fontName  = "AvenirNext-Medium"
        apexLbl.fontSize  = adaptiveFontSize(base: 16)
        apexLbl.fontColor = UIColor(red:0.22,green:1,blue:0.08,alpha:1)
        apexLbl.verticalAlignmentMode = .center
        apexLbl.position  = CGPoint(x: cx, y: cy - ph*0.14)
        apexLbl.zPosition = 2
        addChild(apexLbl)

        // buttons
        if questLevel != nil {
            // Quest win: show Next Level + Main Menu
            let hasNextLevel = questLevel! < NexusVault.questConfigs.count
            if hasNextLevel {
                let nextBtn = makeButton(title: "NEXT LEVEL ▶",
                                         color: UIColor(red:1,green:0.84,blue:0,alpha:1),
                                         position: CGPoint(x: cx, y: cy - ph*0.28),
                                         name: "nextLevelBtn")
                addChild(nextBtn)
            }
            let menuBtn = makeButton(title: "MAIN MENU",
                                     color: UIColor(white:0.6,alpha:1),
                                     position: CGPoint(x: cx, y: cy - ph*0.40),
                                     name: "menuBtn")
            addChild(menuBtn)
        } else {
            let retryBtn = makeButton(title: "PLAY AGAIN",
                                      color: UIColor(red:0,green:0.83,blue:1,alpha:1),
                                      position: CGPoint(x: cx, y: cy - ph*0.28),
                                      name: "retryBtn")
            let menuBtn  = makeButton(title: "MAIN MENU",
                                      color: UIColor(white:0.6,alpha:1),
                                      position: CGPoint(x: cx, y: cy - ph*0.40),
                                      name: "menuBtn")
            addChild(retryBtn)
            addChild(menuBtn)
        }
    }

    // MARK: - Timed Result Panel
    func buildTimedResultPanel(score: Int, apexTier: String, apexCount: Int) {
        let cx = sceneSize.width / 2
        let cy = sceneSize.height / 2

        let pw: CGFloat = min(sceneSize.width * 0.82, 340)
        let ph: CGFloat = min(sceneSize.height * 0.52, 420)

        let panel = SKShapeNode(rectOf: CGSize(width: pw, height: ph), cornerRadius: 22)
        panel.fillColor   = UIColor(red:0.07,green:0.07,blue:0.18,alpha:0.97)
        panel.strokeColor = UIColor(red:0,green:0.83,blue:1,alpha:0.9)
        panel.lineWidth   = 2.2
        panel.position    = CGPoint(x: cx, y: cy)
        panel.zPosition   = 1
        addChild(panel)

        let iconLbl = SKLabelNode(text: "⏱")
        iconLbl.fontSize = adaptiveFontSize(base: 48)
        iconLbl.verticalAlignmentMode = .center
        iconLbl.position  = CGPoint(x: cx, y: cy + ph*0.32)
        iconLbl.zPosition = 2
        addChild(iconLbl)

        let titleLbl = SKLabelNode(text: "TIME'S UP!")
        titleLbl.fontName  = "AvenirNext-Heavy"
        titleLbl.fontSize  = adaptiveFontSize(base: 28)
        titleLbl.fontColor = UIColor(red:0,green:0.83,blue:1,alpha:1)
        titleLbl.verticalAlignmentMode = .center
        titleLbl.position  = CGPoint(x: cx, y: cy + ph*0.16)
        titleLbl.zPosition = 2
        addChild(titleLbl)

        let scoreLbl = SKLabelNode(text: "SCORE  \(score)")
        scoreLbl.fontName  = "AvenirNext-Bold"
        scoreLbl.fontSize  = adaptiveFontSize(base: 22)
        scoreLbl.fontColor = UIColor(red:1,green:0.84,blue:0,alpha:1)
        scoreLbl.verticalAlignmentMode = .center
        scoreLbl.position  = CGPoint(x: cx, y: cy + ph*0.02)
        scoreLbl.zPosition = 2
        addChild(scoreLbl)

        let apexText = apexCount > 0 ? "BEST  \(apexCount) × \(apexTier)" : "BEST  —"
        let apexLbl = SKLabelNode(text: apexText)
        apexLbl.fontName  = "AvenirNext-Medium"
        apexLbl.fontSize  = adaptiveFontSize(base: 16)
        apexLbl.fontColor = UIColor(red:0.22,green:1,blue:0.08,alpha:1)
        apexLbl.verticalAlignmentMode = .center
        apexLbl.position  = CGPoint(x: cx, y: cy - ph*0.08)
        apexLbl.zPosition = 2
        addChild(apexLbl)

        let retryBtn = makeButton(title: "PLAY AGAIN",
                                  color: UIColor(red:0,green:0.83,blue:1,alpha:1),
                                  position: CGPoint(x: cx, y: cy - ph*0.24),
                                  name: "retryBtn")
        let menuBtn = makeButton(title: "MAIN MENU",
                                 color: UIColor(white:0.6,alpha:1),
                                 position: CGPoint(x: cx, y: cy - ph*0.36),
                                 name: "menuBtn")
        addChild(retryBtn)
        addChild(menuBtn)
    }
}
