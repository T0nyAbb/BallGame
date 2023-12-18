//
//  MainMenu.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 10/12/23.
//

import SpriteKit

class MainMenu: SKScene {
    
    //MARK: - Properties
    var containerNode: SKSpriteNode!
    
    //MARK: - Systems
    
    override func didMove(to view: SKView) {
        setupBG()
        setupGround()
        setupNodes()
        SKTAudio.sharedInstance().playBGMusic("backgroundMusic.mp3")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan (touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .fade(withDuration: 0.8))
        } else if node.name == "highscore" {
            setupPanel()
        } else if node.name == "setting" {
            setupSettings()
        } else if node.name == "container" {
            containerNode.removeFromParent()
        } else if node.name == "music" {
            let node = node as! SKSpriteNode
            SKTAudio.musicEnabled = !SKTAudio.musicEnabled
            node.texture = SKTexture(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
            if(SKTAudio.musicEnabled) {
                SKTAudio.sharedInstance().resumeBGMusic()
            } else {
                SKTAudio.sharedInstance().stopBGMusic()
            }
            
        } else if node.name == "effect" {
            let node = node as! SKSpriteNode
            effectEnabled = !effectEnabled
            node.texture = SKTexture(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveGround()
    }
}

//MARK: - Configurations

extension MainMenu {
    
    func setupBG() {
        let bgNode = SKSpriteNode(imageNamed: "fbgr")
        bgNode.zPosition = -1.0
        bgNode.anchorPoint = .zero
        bgNode.position = .zero
        addChild(bgNode)
    }
    
    func setupGround() {
        for i in 0...2 {
            let groundNode = SKSpriteNode(imageNamed: "Snow")
            groundNode.name = "Ground"
            groundNode.anchorPoint = .zero
            groundNode.zPosition = 1.0
            groundNode.position = CGPoint(x: CGFloat(i)*groundNode.frame.width, y: 0.0)
            addChild(groundNode)
        }
    }
    
    func moveGround() {
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
            
            if node.position.x < -self.frame.width {
                node.position.x += node.frame.width*2.0
            }
            
        }
    }
    
    func setupNodes() {
        let play = SKSpriteNode(imageNamed: "Gioca")
        play.name = "play"
        play.setScale(2.5)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - play.size.height/3.0 )
        addChild(play)
        
        let highscore = SKSpriteNode(imageNamed: "Leaderboard")
        highscore.name = "highscore"
        highscore.setScale(1.5)
        highscore.zPosition = 10.0
        highscore.position = CGPoint(x: size.width/2.0 - 2*highscore.size.width - 50.0, y: size.height/2.0 - highscore.size.height/2.0 )
        addChild(highscore)
        
        let setting = SKSpriteNode(imageNamed: "Setting")
        setting.name = "setting"
        setting.setScale(1.5)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2.0 + 2*setting.size.width + 50.0, y: size.height/2.0 - setting.size.height/2.0)
        addChild(setting)
        
        let title = SKSpriteNode(imageNamed: "titolo")
        title.name = "titolo"
        title.setScale(2.0)
        title.zPosition = 10.0
        title.position = CGPoint(x: size.width/2.0, y: size.height/2.0 + title.frame.height/1.2)
        addChild(title)
    }
    
    func setupPanel() {
        setupContainer()
        
        let panel = SKSpriteNode(imageNamed: "sign")
        panel.setScale(0.85)
        panel.zPosition = 20.0
        panel.position = CGPoint(x: 0.0, y: -frame.height/3.2)
        containerNode.addChild(panel)
        
        //Highscore
        let x = -panel.frame.width/2.0 + 100.0
        let highscorelbl = SKLabelNode(fontNamed: "PWJoyeuxNoel")
        highscorelbl.fontName = "PWJoyeuxNoel"
        highscorelbl.text = "Highscore: \(ScoreGenerator.sharedInstance.getHighScore())"
        highscorelbl.horizontalAlignmentMode = .left
        highscorelbl.fontSize = 125.0
        highscorelbl.zPosition = 25.0
        highscorelbl.position = CGPoint(x: x, y: highscorelbl.frame.height*3.0 )
        panel.addChild(highscorelbl)
        
        
        let scorelbl = SKLabelNode(fontNamed: "PWJoyeuxNoel")
        scorelbl.fontName = "PWJoyeuxNoel"
        scorelbl.text = "Score: \(ScoreGenerator.sharedInstance.getScore())"
        scorelbl.horizontalAlignmentMode = .left
        scorelbl.fontSize = 125.0
        scorelbl.zPosition = 25.0
        scorelbl.position = CGPoint(x: x, y: scorelbl.frame.height*1.5)
        panel.addChild(scorelbl)
    }
    
    func setupContainer() {
        containerNode = SKSpriteNode()
        containerNode.name = "container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear    //UIColor(white: 0.5, alpha: 0.5)
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(containerNode)
    }
    
    func setupSettings() {
        setupContainer()
        
        //Panel
        let panel = SKSpriteNode(imageNamed: "sign")
        panel.setScale(0.85)
        panel.zPosition = 20.0
        panel.position = CGPoint(x: 0.0, y: -frame.height/3.2)
        containerNode.addChild(panel)
        
        //Music
        let music = SKSpriteNode(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
        music.name = "music"
        music.setScale(1.5)
        music.zPosition = 25.0
        music.position = CGPoint(x: -panel.frame.width/2.0 + music.frame.width*2.5,
                                 y: music.frame.height)
        panel.addChild(music)
        
        //Sound
        let effect = SKSpriteNode(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        effect.name = "effect"
        effect.setScale(1.5)
        effect.zPosition = 25.0
        effect.position = CGPoint(x: panel.frame.width/2.0 - effect.frame.width*2.5,
                                  y: effect.frame.height)
        panel.addChild(effect)
    }
}
