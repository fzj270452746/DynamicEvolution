import UIKit

extension WayfarerPortal {

    // MARK: - Animated Background

    func composeAnimatedBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1).cgColor,
            UIColor(red: 0.06, green: 0.03, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.06, blue: 0.14, alpha: 1).cgColor,
            UIColor(red: 0.0,  green: 0.0,  blue: 0.04, alpha: 1).cgColor,
        ]
        gradientLayer.locations = [0, 0.35, 0.7, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)

        backdropImage.image = UIImage(named: "bg_main_menu")
        backdropImage.contentMode = .scaleAspectFill
        backdropImage.alpha = 0.15
        backdropImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdropImage)
        NSLayoutConstraint.activate([
            backdropImage.topAnchor.constraint(equalTo: view.topAnchor),
            backdropImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backdropImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tintOverlay.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tintOverlay)
        NSLayoutConstraint.activate([
            tintOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tintOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func animateGradientShift() {
        let anim = CABasicAnimation(keyPath: "colors")
        anim.toValue = [
            UIColor(red: 0.03, green: 0.0,  blue: 0.12, alpha: 1).cgColor,
            UIColor(red: 0.08, green: 0.02, blue: 0.22, alpha: 1).cgColor,
            UIColor(red: 0.0,  green: 0.04, blue: 0.10, alpha: 1).cgColor,
            UIColor(red: 0.02, green: 0.0,  blue: 0.06, alpha: 1).cgColor,
        ]
        anim.duration = 6.0
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(anim, forKey: "gradientShift")
    }

    // MARK: - Particle Systems

    func composeParticleSystems() {
        guard emitterLayers.isEmpty else { return }

        let goldEmitter = CAEmitterLayer()
        goldEmitter.emitterShape = .line
        goldEmitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.maxY + 10)
        goldEmitter.emitterSize = CGSize(width: view.bounds.width * 1.2, height: 1)
        goldEmitter.renderMode = .additive

        let goldCell = CAEmitterCell()
        goldCell.birthRate = 2.5
        goldCell.lifetime = 8
        goldCell.velocity = 30
        goldCell.velocityRange = 20
        goldCell.emissionLongitude = -.pi / 2
        goldCell.emissionRange = .pi / 8
        goldCell.alphaSpeed = -0.08
        goldCell.scale = 0.04
        goldCell.scaleRange = 0.03
        goldCell.color = UIColor(red: 1, green: 0.84, blue: 0, alpha: 0.6).cgColor
        goldCell.contents = dotImage()?.cgImage
        goldEmitter.emitterCells = [goldCell]

        view.layer.insertSublayer(goldEmitter, above: tintOverlay.layer)
        emitterLayers.append(goldEmitter)

        let cyanEmitter = CAEmitterLayer()
        cyanEmitter.emitterShape = .line
        cyanEmitter.emitterPosition = CGPoint(x: -10, y: view.bounds.midY)
        cyanEmitter.emitterSize = CGSize(width: 1, height: view.bounds.height * 0.6)
        cyanEmitter.renderMode = .additive

        let cyanCell = CAEmitterCell()
        cyanCell.birthRate = 1.2
        cyanCell.lifetime = 10
        cyanCell.velocity = 15
        cyanCell.velocityRange = 10
        cyanCell.emissionLongitude = 0
        cyanCell.emissionRange = .pi / 10
        cyanCell.alphaSpeed = -0.06
        cyanCell.scale = 0.05
        cyanCell.scaleRange = 0.03
        cyanCell.color = UIColor(red: 0, green: 0.83, blue: 1, alpha: 0.35).cgColor
        cyanCell.contents = dotImage()?.cgImage
        cyanEmitter.emitterCells = [cyanCell]

        view.layer.insertSublayer(cyanEmitter, above: tintOverlay.layer)
        emitterLayers.append(cyanEmitter)

        let purpleEmitter = CAEmitterLayer()
        purpleEmitter.emitterShape = .point
        purpleEmitter.emitterPosition = CGPoint(x: view.bounds.maxX + 10, y: view.bounds.height * 0.3)
        purpleEmitter.renderMode = .additive

        let purpleCell = CAEmitterCell()
        purpleCell.birthRate = 0.8
        purpleCell.lifetime = 12
        purpleCell.velocity = 12
        purpleCell.velocityRange = 8
        purpleCell.emissionLongitude = .pi
        purpleCell.emissionRange = .pi / 6
        purpleCell.alphaSpeed = -0.05
        purpleCell.scale = 0.06
        purpleCell.scaleRange = 0.04
        purpleCell.color = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 0.4).cgColor
        purpleCell.contents = dotImage()?.cgImage
        purpleEmitter.emitterCells = [purpleCell]

        view.layer.insertSublayer(purpleEmitter, above: tintOverlay.layer)
        emitterLayers.append(purpleEmitter)
    }

    func dotImage() -> UIImage? {
        let sz = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(sz, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: sz)).fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

    // MARK: - Card Styling

    func styleCard(_ card: UIView, borderColor: UIColor, glowColor: UIColor) {
        card.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.16, alpha: 0.92)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1.5
        card.layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
        card.layer.shadowColor = glowColor.cgColor
        card.layer.shadowOffset = .zero
        card.layer.shadowRadius = 12
        card.layer.shadowOpacity = 0.2
        card.isUserInteractionEnabled = true
    }

    func pulseCardBorder(_ card: UIView, color: UIColor) {
        let anim = CABasicAnimation(keyPath: "borderColor")
        anim.fromValue = color.withAlphaComponent(0.3).cgColor
        anim.toValue = color.withAlphaComponent(0.8).cgColor
        anim.duration = 1.8
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        card.layer.add(anim, forKey: "borderPulse")
    }

    // MARK: - Entrance Animation

    func animateEntrance() {
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: -30, y: 0)
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: -20, y: 0)
        glowBar.alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0.05, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        UIView.animate(withDuration: 0.4, delay: 0.15, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut) {
            self.glowBar.alpha = 1
        }

        let gold = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
        let cyan = UIColor(red: 0, green: 0.83, blue: 1, alpha: 1)
        let purple = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)
        let orange = UIColor(red: 0.90, green: 0.32, blue: 0, alpha: 1)
        let green = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        let cardColors = [gold, cyan, purple, orange, green]

        for (i, card) in allCards.enumerated() {
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 30).scaledBy(x: 0.95, y: 0.95)
            UIView.animate(withDuration: 0.4, delay: 0.2 + Double(i) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                card.alpha = 1
                card.transform = .identity
            } completion: { _ in
                if i < cardColors.count {
                    self.pulseCardBorder(card, color: cardColors[i])
                }
            }
        }

        statsRibbon.alpha = 0
        statsRibbon.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut) {
            self.statsRibbon.alpha = 1
            self.statsRibbon.transform = .identity
        }
    }
}
