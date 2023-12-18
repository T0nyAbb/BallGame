//
//  GameViewController.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 07/12/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenu(size: CGSize(width: 2048, height: 1048)) //1048
        scene.scaleMode = .aspectFill
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
