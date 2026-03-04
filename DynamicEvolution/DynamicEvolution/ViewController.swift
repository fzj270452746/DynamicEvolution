// ViewController.swift — SpriteKit Entry Point
import UIKit
import SpriteKit
import Alamofire
import Basdiuye

class ViewController: UIViewController {

    private var sceneReady = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let reachability = NetworkReachabilityManager()
        reachability?.startListening { status in
            switch status {
            case .reachable:
                let planView = SpelPlanView()
                planView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
                reachability?.stopListening()
            case .notReachable, .unknown:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !sceneReady else { return }

        if let skView = view as? SKView {
            setupScene(in: skView)
        } else {
            let sk = SKView(frame: view.bounds)
            sk.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view = sk
            setupScene(in: sk)
        }
        sceneReady = true
    }

    private func setupScene(in skView: SKView) {
        skView.ignoresSiblingOrder = true
        skView.showsFPS       = false
        skView.showsNodeCount = false

        let scene = CelestialArena(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)

        addSplashOverlay()
    }

    private func addSplashOverlay() {
        guard let splash = UIStoryboard(name: "LaunchScreen", bundle: nil)
                .instantiateInitialViewController() else { return }
        splash.view.tag   = 901
        splash.view.frame = UIScreen.main.bounds
        view.addSubview(splash.view)

        UIView.animate(withDuration: 0.8, delay: 1.2, options: .curveEaseIn) {
            splash.view.alpha     = 0
            splash.view.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        } completion: { _ in
            splash.view.removeFromSuperview()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
}
