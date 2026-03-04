import UIKit

extension CelestialSpindle {

    // MARK: - Match Result

    func showMatchResult(rank: MorphRank, xp: Int) {
        resultLabel.text = "✦ MATCH! +\(xp) XP ✦"
        resultLabel.textColor = UIColor(red: 0.22, green: 1, blue: 0.08, alpha: 1)
        resultLabel.alpha = 0
        resultLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.15, animations: {
            self.resultLabel.alpha = 1
            self.resultLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.08) {
                self.resultLabel.transform = .identity
            }
        }

        highlightMatchingReels(rank: rank)
        emitMatchParticles()
    }

    func showNoMatch() {
        resultLabel.text = "No Match"
        resultLabel.textColor = UIColor(white: 0.4, alpha: 1)
        resultLabel.alpha = 0

        UIView.animate(withDuration: 0.2) {
            self.resultLabel.alpha = 0.7
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIView.animate(withDuration: 0.3) {
                self.resultLabel.alpha = 0
            }
        }
    }

    // MARK: - Reel Highlight

    func highlightMatchingReels(rank: MorphRank) {
        for container in reelContainers {
            let originalBg = UIColor(red: 0.08, green: 0.08, blue: 0.22, alpha: 1)
            container.backgroundColor = rank.pigment.withAlphaComponent(0.3)
            container.layer.borderColor = rank.pigment.cgColor
            UIView.animate(withDuration: 0.5, delay: 0.3) {
                container.backgroundColor = originalBg
                container.layer.borderColor = rank.pigment.withAlphaComponent(0.5).cgColor
            }
        }
    }

    // MARK: - Particles

    func emitMatchParticles() {
        let origin = CGPoint(x: slotFrame.frame.midX, y: slotFrame.frame.maxY)
        let purple = UIColor(red: 0.55, green: 0.22, blue: 0.80, alpha: 1)

        for i in 0..<12 {
            let radius = CGFloat.random(in: 3...6)
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
            dot.backgroundColor = i.isMultiple(of: 2) ? purple : UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
            dot.layer.cornerRadius = radius
            dot.center = origin
            view.addSubview(dot)

            let angle = (CGFloat(i) / 12.0) * .pi * 2 + CGFloat.random(in: -0.2...0.2)
            let dist = CGFloat.random(in: 40...100)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                dot.center = CGPoint(x: origin.x + cos(angle) * dist, y: origin.y + sin(angle) * dist)
                dot.alpha = 0
                dot.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                dot.removeFromSuperview()
            }
        }
    }

    // MARK: - Level Up Celebration

    func showLevelUpCelebration(newLevel: MorphRank) {
        let flash = UIView(frame: view.bounds)
        flash.backgroundColor = newLevel.pigment.withAlphaComponent(0.25)
        view.addSubview(flash)

        UIView.animate(withDuration: 0.1, animations: {
            flash.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.45, animations: {
                flash.alpha = 0
            }) { _ in
                flash.removeFromSuperview()
            }
        }

        let banner = UILabel()
        banner.text = "RANK UP: \(newLevel.designation.uppercased())!"
        banner.font = UIFont.systemFont(ofSize: self.sv(26), weight: .heavy)
        banner.textColor = newLevel.pigment
        banner.textAlignment = .center
        banner.sizeToFit()
        banner.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        banner.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        view.addSubview(banner)

        UIView.animate(withDuration: 0.2, animations: {
            banner.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                banner.transform = .identity
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 0.8, animations: {
                    banner.alpha = 0
                }) { _ in
                    banner.removeFromSuperview()
                }
            }
        }

        let center = CGPoint(x: view.bounds.midX, y: slotFrame.frame.midY)
        for i in 0..<20 {
            let radius = CGFloat.random(in: 3...7)
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
            dot.backgroundColor = newLevel.pigment
            dot.layer.cornerRadius = radius
            dot.center = center
            view.addSubview(dot)

            let angle = (CGFloat(i) / 20.0) * .pi * 2 + CGFloat.random(in: -0.2...0.2)
            let dist = CGFloat.random(in: 60...150)
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                dot.center = CGPoint(x: center.x + cos(angle) * dist, y: center.y + sin(angle) * dist)
                dot.alpha = 0
                dot.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
            }) { _ in
                dot.removeFromSuperview()
            }
        }
    }
}
