import UIKit

final class IncunableCell: UICollectionViewCell {

    static let reuseTag = "IncunableCell"

    private let emblemView = UIImageView()
    private let echelonLabel = UILabel()
    private let borderLayer = CAShapeLayer()
    private let shimmerLayer = CAShapeLayer()
    private(set) var currentRank: MorphRank?

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleHierarchy()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func assembleHierarchy() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.95)
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1.5
        contentView.layer.addSublayer(borderLayer)

        shimmerLayer.fillColor = UIColor.clear.cgColor
        shimmerLayer.lineWidth = 3
        layer.insertSublayer(shimmerLayer, at: 0)

        emblemView.contentMode = .scaleAspectFit
        emblemView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emblemView)

        echelonLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        echelonLabel.textAlignment = .center
        echelonLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(echelonLabel)

        NSLayoutConstraint.activate([
            emblemView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emblemView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            emblemView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            emblemView.heightAnchor.constraint(equalTo: emblemView.widthAnchor),
            echelonLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            echelonLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: 10).cgPath
        let outer = bounds.insetBy(dx: -1, dy: -1)
        shimmerLayer.path = UIBezierPath(roundedRect: outer, cornerRadius: 12).cgPath
    }

    func configureWith(rank: MorphRank) {
        currentRank = rank
        emblemView.image = UIImage(named: rank.iconAsset)
        emblemView.alpha = 1
        echelonLabel.text = "Lv\(rank.rawValue)"
        echelonLabel.textColor = rank.pigment
        echelonLabel.alpha = 1
        borderLayer.strokeColor = rank.pigment.withAlphaComponent(0.7).cgColor
        shimmerLayer.strokeColor = rank.pigment.withAlphaComponent(0.18).cgColor
    }

    func configureAsVacant() {
        currentRank = nil
        emblemView.image = nil
        emblemView.alpha = 0
        echelonLabel.text = "?"
        echelonLabel.textColor = UIColor(white: 0.3, alpha: 1)
        echelonLabel.alpha = 0.3
        borderLayer.strokeColor = UIColor(white: 0.2, alpha: 0.5).cgColor
        shimmerLayer.strokeColor = UIColor.clear.cgColor
        contentView.transform = .identity
    }

    // MARK: - Reveal Animation

    func performReveal(finalRank: MorphRank, delay: TimeInterval) {
        let flickCount = 8
        let flickInterval: TimeInterval = 0.06

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            var step = 0
            Timer.scheduledTimer(withTimeInterval: flickInterval, repeats: true) { [weak self] timer in
                guard let self = self else { timer.invalidate(); return }
                if step < flickCount {
                    let rnd = MorphRank.allCases.randomElement() ?? .germinal
                    self.emblemView.image = UIImage(named: rnd.iconAsset)
                    self.emblemView.alpha = 1
                    self.echelonLabel.text = "Lv\(rnd.rawValue)"
                    self.echelonLabel.textColor = rnd.pigment
                    self.echelonLabel.alpha = 1
                    self.borderLayer.strokeColor = rnd.pigment.withAlphaComponent(0.7).cgColor
                    step += 1
                } else {
                    timer.invalidate()
                    self.configureWith(rank: finalRank)
                    self.bounceIn()
                }
            }
        }
    }

    private func bounceIn() {
        UIView.animate(withDuration: 0.08, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.10) {
                self.contentView.transform = .identity
            }
        }
    }

    // MARK: - Amalgam Pop

    func performAmalgamPop(tint: UIColor) {
        let originalBg = UIColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.95)
        contentView.backgroundColor = tint.withAlphaComponent(0.4)
        UIView.animate(withDuration: 0.12, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.14, animations: {
                self.contentView.transform = .identity
            }) { _ in
                self.contentView.backgroundColor = originalBg
            }
        }
    }

    // MARK: - Highlight

    func highlightBorder(tint: UIColor) {
        borderLayer.strokeColor = tint.cgColor
        borderLayer.lineWidth = 2.5
        UIView.animate(withDuration: 0.1, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.contentView.transform = .identity
            } completion: { _ in
                self.borderLayer.lineWidth = 1.5
            }
        }
    }

    // MARK: - Zenith Flash

    func performZenithFlash(tint: UIColor) {
        let originalBg = UIColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.95)
        contentView.backgroundColor = tint.withAlphaComponent(0.5)
        shimmerLayer.strokeColor = tint.withAlphaComponent(0.7).cgColor
        shimmerLayer.lineWidth = 5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.contentView.backgroundColor = originalBg
            }
            self?.shimmerLayer.lineWidth = 3
        }
    }
}
