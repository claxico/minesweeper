//
//  GameViewController.swift
//  Minesweeper
//
//  Created by Huit Blackmon on 2/12/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.parentViewController = self
            gameScene.presentScene(scene)
        }
    }

    @IBOutlet weak var gameScene: SKView!
    @IBOutlet weak var flagsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
