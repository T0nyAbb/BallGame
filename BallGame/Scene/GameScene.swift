//
//  GameScene.swift
//  BallGame
//
//  Created by Antonio Abbatiello on 07/12/23.
//

import SpriteKit
import GameplayKit
import UIKit


class GameScene: SKScene {
    
    //MARK: - Attributes
    var backGround: SKSpriteNode!
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var obstacles: [SKSpriteNode] = []
    var coin: SKSpriteNode!
    var particles: SKEmitterNode!
    var trail: SKEmitterNode!
    
    var cameraMovePointPerSecond: CGFloat = 450.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var isTime: CGFloat = 3.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var numScore: Int = 0
    var gameOver = false
    var life: Int = 3
    
    var lifeNodes: [SKSpriteNode] = []
    var scoreLabel = SKLabelNode(fontNamed: "Krungthep")
    var coinIcon: SKSpriteNode!
    
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    var soundCoin = SKAction.playSoundFileNamed("coin.mp3")
    var soundJump = SKAction.playSoundFileNamed("jump.wav")
    var soundCollision = SKAction.playSoundFileNamed("collision.wav")
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        let playableHeight = size.width / ratio
        let playableMargin = (size.height - playableHeight) / 2.0
        
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2.0
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2.0
        return CGRect(x: x, y: y, width: width, height: height)
    }
    //MARK: - Systems
    override func didMove(to view: SKView) {
        setupNodes()
        SKTAudio.sharedInstance().playBGMusic("backgroundMusic.mp3")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        if node.name == "Pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
        } else if node.name == "Resume" {
            containerNode.removeFromParent()
            isPaused = false
        } else if node.name == "Quit" {
            let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .crossFade(withDuration: 0.8))
        } else {
            if !isPaused {
                if onGround {
                    onGround = false
                    velocityY = -25.0
                    run(soundJump)
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
            
        } else {
            dt = 0
            
        }
        lastUpdateTime = currentTime
        moveCamera()
        movePlayer()
        velocityY += gravity
        player.position.y -= velocityY
        
        
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
        if cameraNode.position.x - player.position.x > 300  {
            player.physicsBody?.velocity.dx += 0.3
        }
        if (player.physicsBody?.velocity.dx)! > 0 || cameraNode.position.x - player.position.x < -300 {
            player.physicsBody?.velocity.dx -= 0.1
        }
        
        
        
        if gameOver {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .crossFade(withDuration: 0.8))
        }
        print(trail.position.y)
        moveTrail()
        if !onGround {
            trail.particleLifetime = 0
        } else {
            trail.particleLifetime = 1
        }
        boundCheckPlayer()
    }
}

//MARK: - Configurations

extension GameScene {
    
    func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setupObstacles()
            self.spawnObstacles()
            self.setupCoin()
            self.spawnCoin()
        }
        setupPhysics()
        setupLife()
        setupScore()
        setupPause()
        setupCamera()
        view!.showsPhysics = true
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func createBG() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "fbgr")
            bg.name = "BG"
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: bg.size.width*CGFloat(i) * CGFloat(1*i), y: 0.0)
            bg.zPosition = -1.0
            particles = SKEmitterNode(fileNamed: "Snow")
            particles.position.x = cameraNode.position.x
            particles.position.y = 1500.0
            particles.zPosition = 50.0
            particles.targetNode = bg
            addChild(bg)
            bg.addChild(particles)
            let moveLeft = SKAction.moveBy(x: -bg.size.width , y: 0, duration: 90)
            let moveReset = SKAction.moveBy(x: bg.size.width - 2048.0 , y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            backGround = bg
            bg.run(moveForever)
       }
        
    }
    
    func createGround() {
        for i in 0...2 {
            let ground = SKSpriteNode(imageNamed: "Snow")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 0.0)
            let gsize: CGSize = CGSize(width: 8192, height: 334)
            ground.physicsBody = SKPhysicsBody(rectangleOf: gsize,
                                               center: CGPoint(x: ground.position.x, y: ground.position.y+162))
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
            ground.physicsBody!.density = 10000.0
            ground.physicsBody!.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Block | PhysicsCategory.Obstacle
            self.ground = ground
            addChild(ground)
        }
       
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "Ball")
        player.name = "Player"
        player.zPosition = 1.0
        player.position = CGPoint(x: frame.width/2.0 - 100.0, y: ground.frame.height + player.frame.height/2.0)
        player.physicsBody = SKPhysicsBody(circleOfRadius: (player.size.width/2.0))
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.density = 25.0
        player.physicsBody!.friction = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Obstacle | PhysicsCategory.Coin
        playerPosY = player.position.y
        addChild(player)
        trail = SKEmitterNode(fileNamed: "Trail")
        trail.position.x = player.position.x
        trail.position.y = ground.position.y + 327.0
        trail.zPosition = player.zPosition - 1.0
        //trail.targetNode = player
        addChild(trail)
    }
    
    func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func moveCamera() {
        let amountToMove = CGPoint(x: cameraMovePointPerSecond *  CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        
        //Background
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
            
        }
        
        //Ground
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2.0, y: node.position.y)
            }
            
        }
        
    }
    
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond*CGFloat(dt)
        let rotate = CGFloat(2).degreeToRadians() * amountToMove/2.5
        player.zRotation -= rotate
        player.position.x += amountToMove
    }
    
    func setupObstacles() {
        for i in 1...4 {
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "Block"
            obstacles.append(sprite)
        }
        for i in 1...2 {
            let sprite = SKSpriteNode(imageNamed: "obstacle-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
        let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 1.0
        sprite.setScale(0.85)
        sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0, y: ground.frame.height + sprite.frame.height/2.0)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody!.affectedByGravity = true
        sprite.physicsBody!.isDynamic = true
        sprite.physicsBody!.angularDamping = 0.1
        sprite.physicsBody!.friction = 0.3
        sprite.physicsBody!.density = 5.0
        
        if(sprite.name == "Block") {
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Block
            sprite.physicsBody!.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Ground | PhysicsCategory.Block
        } else {
            sprite.physicsBody!.isDynamic = false
            sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
        }
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(sprite)
        sprite.run(.sequence([
            .wait(forDuration: 10.0),
            .removeFromParent()
        ]))
    }
    
    func spawnObstacles() {
        let random = Double(CGFloat.random(min: 1.5, max: isTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupObstacles()
            }
        ])))
        let rng = Double.random(in: 1.5...6.0)
        run(.repeatForever((.sequence([
            .wait(forDuration: rng),
            .run {
                self.isTime -= 0.01
                
                if(self.isTime<=1.5) {
                    self.isTime = 1.5
                }
            }
        ]))))
    }
    
    func setupCoin() {
        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.name = "Coin"
        coin.zPosition = 20.0
        coin.setScale(0.85)
        let coinHeight = coin.frame.height
        let random = CGFloat.random(min: -coinHeight, max: coinHeight*2.0)
        coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width, y: size.height/2.0 + random)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2.0)
        coin.physicsBody!.affectedByGravity = false
        coin.physicsBody!.isDynamic = false
        coin.physicsBody!.categoryBitMask = PhysicsCategory.Coin
        coin.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        coin.physicsBody!.collisionBitMask = PhysicsCategory.Player
        addChild(coin)
        coin.run(.sequence([
            .wait(forDuration: 15.0),
            .removeFromParent()
        ]))
        
        var textures: [SKTexture] = []
        for i in 1...6 {
            textures.append(SKTexture(imageNamed: "coin-\(i)"))
        }
        
        coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.083)))
        
    }
    
    func spawnCoin() {
        let random = CGFloat.random(min: 1.5, max: 4.0)
        run(.repeatForever(.sequence([
            .wait(forDuration: TimeInterval(random)),
            .run { [weak self] in
                self?.setupCoin()
            }
        ])))
    }
    
    func setupLife() {
        let node1 = SKSpriteNode(imageNamed: "life-on")
        let node2 = SKSpriteNode(imageNamed: "life-on")
        let node3 = SKSpriteNode(imageNamed: "life-on")
        setupLifePos(node1, i: 1.0, j: 0.0)
        setupLifePos(node2, i: 2.0, j: 8.0)
        setupLifePos(node3, i: 3.0, j: 16.0)
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }
    
    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        
        node.setScale(0.5)
        node.zPosition = 50.0
        node.position = CGPoint(x: -width/2.0 + node.frame.width*i + j + 10 , y: height/2.5 - node.frame.height/2.0)
        cameraNode.addChild(node)
    }
    
    func setupScore() {
        //Icon
        coinIcon = SKSpriteNode(imageNamed: "coin-1")
        coinIcon.setScale(0.5)
        coinIcon.zPosition = 50.0
        coinIcon.position = CGPoint(x: -playableRect.width/2.0 + coinIcon.frame.width + 30,
                                    y: playableRect.height/2.5 - lifeNodes[0].frame.height - coinIcon.frame.height/2.0)
        cameraNode.addChild(coinIcon)
        
        //Label
        scoreLabel.text = "\(numScore)"
        scoreLabel.fontSize = 60.0
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = 50.0
        scoreLabel.position = CGPoint(x: -playableRect.width/2.0 + coinIcon.frame.width*2.0 + 20,
                                      y: coinIcon.position.y + coinIcon.frame.height/2.0 - 10.0)
        cameraNode.addChild(scoreLabel)
    }
    
    func setupPause() {
        pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.5)
        pauseNode.zPosition = 50.0
        pauseNode.name = "Pause"
        pauseNode.position = CGPoint(x: playableRect.width/2.0 - pauseNode.frame.width/2.0 - 60.0,
                                     y: playableRect.height/2.5 - pauseNode.frame.height/2.0 - 10.0)
        cameraNode.addChild(pauseNode)
    }
    
    func createPanel() {
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "Resume"
        resume.setScale(0.7)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + resume.frame.width*1.5,
                                  y: 0.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "Quit"
        quit.setScale(0.7)
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width*1.5,
                                  y: 0.0)
        panel.addChild(quit)
    }
    
    func boundCheckPlayer() {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            lifeNodes.forEach({$0.texture = SKTexture(imageNamed: "life-off")})
            numScore = 0
            scoreLabel.text = "\(numScore)"
            gameOver = true
        }
    }
    
    func moveTrail() {
        trail.position.x = player.position.x
    }
    
    func setupGameOver() {
        life -= 1
        if(life<=0) { life = 0 }
        lifeNodes[life].texture = SKTexture(imageNamed: "life-off")
        
        if(life<=0 && !gameOver) {
            gameOver = true
        }
    }
}

//MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        let pl = other == contact.bodyA ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Block:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            other.applyAngularImpulse(pl.angularVelocity+10)
            other.affectedByGravity = true
            
            if (other.node?.position.y)! < 0 {
                other.node?.position.y = 0.0
            }
            cameraMovePointPerSecond += 100.0
            numScore-=1
            if numScore <= 0 { numScore = 0 }
            scoreLabel.text = "\(numScore)"
            run(soundCollision)
        case PhysicsCategory.Obstacle:
            if (other.node?.position.y)! < 0 {
                other.node?.position.y = 0.0
            }
            setupGameOver()
        case PhysicsCategory.Coin:
            if let node = other.node {
                node.removeFromParent()
                numScore+=1
                cameraMovePointPerSecond += 100.0
                scoreLabel.text = "\(numScore)"
                if numScore % 5 == 0 {
//                    cameraMovePointPerSecond += 200.0
                }
                let highscore = ScoreGenerator.sharedInstance.getHighScore()
                
                if numScore > highscore {
                    ScoreGenerator.sharedInstance.setHighScore(numScore)
                    ScoreGenerator.sharedInstance.setScore(numScore)
                }
                run(soundCoin)
            }
            
        default:
            break
        }
    }
}
