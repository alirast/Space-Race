//
//  GameScene.swift
//  Space Race
//
//  Created by n on 05.10.2022.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
//MARK: - properties
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var gameOver: SKLabelNode?
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var initialTime: TimeInterval = 1
    var createdEnemy = 0 {
        didSet {
            if createdEnemy == 20 {
                    gameTimer?.invalidate()
                    createdEnemy = 0
                    initialTime -= 0.1
                    gameTimer = Timer.scheduledTimer(timeInterval: initialTime, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            }
        }
    }
    
//MARK: - didMove
    override func didMove(to view: SKView) {
        //starfield background
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        addChild(starfield)
       
        //player
        player = SKSpriteNode(imageNamed: "player")
        //initial position of the player
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        //scoreLabel
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: initialTime, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
//MARK: - update
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        if !isGameOver {
            score += 1
        }
    }
    
//MARK: - createEnemy
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        createdEnemy += 1
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
//MARK: - touchesMoved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }

        player.position = location
    }

//MARK: - didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        gameTimer?.invalidate()
        isGameOver = true
        gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver!.text = "GAME OVER"
        gameOver!.horizontalAlignmentMode = .center
        gameOver!.fontSize = 55
        gameOver!.position = CGPoint(x: 512, y: 384)
        gameOver!.zPosition = 1
        addChild(gameOver!)

    }
}
