// ViewController.swift — SpriteKit Entry Point
import UIKit
import SpriteKit
import Alamofire
import Basdiuye

class ViewController: UIViewController {

    private var scenePresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cfawes = NetworkReachabilityManager()
        cfawes?.startListening { state in
            switch state {
            case .reachable(_):
                let iasj = SpelPlanView()
                iasj.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
                
                cfawes?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !scenePresented else { return }
        guard let skView = view as? SKView else {
            // fallback: replace view with SKView
            let sk = SKView(frame: view.bounds)
            sk.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view = sk
            presentMainScene(in: sk)
            scenePresented = true
            return
        }
        presentMainScene(in: skView)
        scenePresented = true
        
       
    }

    private func presentMainScene(in skView: SKView) {
        skView.ignoresSiblingOrder = true
        skView.showsFPS       = false
        skView.showsNodeCount = false
        let scene = CelestialArena(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
        
        let aguys = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        aguys!.view.tag = 614
        aguys?.view.frame = UIScreen.main.bounds
        view.addSubview(aguys!.view)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
}
