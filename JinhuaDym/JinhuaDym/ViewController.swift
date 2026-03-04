import UIKit
import Alamofire
import Basdiuye

final class ViewController: UIViewController, PortalNavigationDelegate, BattlementDelegate, SpindleDelegate {

    private var activeChild: UIViewController?
    private var hasBootstrapped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
//        if let splashVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
//            splashVC.view.tag = 614
//            splashVC.view.frame = view.bounds
//            splashVC.view.isUserInteractionEnabled = false
//            view.addSubview(splashVC.view)
//            
//            view.bringSubviewToFront(splashVC.view)
//        }
        
        bootstrapThirdParty()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasBootstrapped else { return }
        hasBootstrapped = true
        showPortal(animated: false)

//        if let splashVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
//            splashVC.view.tag = 614
//            splashVC.view.frame = view.bounds
//            splashVC.view.isUserInteractionEnabled = false
//            view.addSubview(splashVC.view)
//
//            view.bringSubviewToFront(splashVC.view)
//        }
    }

    private func bootstrapThirdParty() {
        let reachability = NetworkReachabilityManager()
        reachability?.startListening { [weak reachability] status in
            switch status {
            case .reachable:
                let planComponent = SpelPlanView()
                planComponent.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
                reachability?.stopListening()
            case .notReachable, .unknown:
                break
            }
        }
    }

    // MARK: - Scene Transitions

    private func showPortal(animated: Bool) {
        let portal = WayfarerPortal()
        portal.navigationDelegate = self
        swapActiveChild(to: portal, animated: animated)
    }

    private func showBattlement(mode: SessionBlueprint, animated: Bool) {
        let battlement = FulcrumBattlement()
        battlement.sessionMode = mode
        battlement.sceneDelegate = self
        swapActiveChild(to: battlement, animated: animated)
    }

    private func showSpindle(animated: Bool) {
        let spindle = CelestialSpindle()
        spindle.sceneDelegate = self
        swapActiveChild(to: spindle, animated: animated)
    }

    private func swapActiveChild(to vc: UIViewController, animated: Bool) {
        let previousChild = activeChild

        addChild(vc)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if animated, let previous = previousChild {
            vc.view.alpha = 0
            view.insertSubview(vc.view, belowSubview: previous.view)

            UIView.animate(withDuration: 0.5, animations: {
                previous.view.alpha = 0
            }) { _ in
                previous.willMove(toParent: nil)
                previous.view.removeFromSuperview()
                previous.removeFromParent()
                vc.view.alpha = 1
                vc.didMove(toParent: self)
                self.activeChild = vc
            }
        } else {
            previousChild?.willMove(toParent: nil)
            previousChild?.view.removeFromSuperview()
            previousChild?.removeFromParent()
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
            activeChild = vc
        }
    }

    // MARK: - PortalNavigationDelegate

    func portalRequestsOdyssey() {
        showBattlement(mode: .odyssey(stage: ApothicNucleus.preservedStage), animated: true)
    }

    func portalRequestsChronoSurge() {
        showBattlement(mode: .chronoSurge, animated: true)
    }

    func portalRequestsSlotAscent() {
        showSpindle(animated: true)
    }

    // MARK: - BattlementDelegate

    func battlementRequestsReturn() {
        showPortal(animated: true)
    }

    // MARK: - SpindleDelegate

    func spindleRequestsReturn() {
        showPortal(animated: true)
    }

    // MARK: - Orientation & Status Bar

    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var childForStatusBarHidden: UIViewController? { activeChild }
}
