//
//  GameScene.swift
//  Breakout
//
//  Created by LiangXiaosheng on 2017/4/2.
//  Copyright © 2017 LiangXiaosheng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball:SKSpriteNode!
    var paddle:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score:\(score)"
        }
    }
    
//    set up screen
    override func didMove(to view: SKView){
        ball = self.childNode(withName: "Ball") as! SKSpriteNode
        paddle = self.childNode(withName: "Paddle") as! SKSpriteNode
        scoreLabel = self.childNode(withName: "Score") as! SKLabelNode
        
//        do an impulse of a ball and add border tp screen
        ball.physicsBody?.applyImpulse(CGVector(dx: 50,dy: 50))
        
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        
//        get access to contact within physics world
        self.physicsWorld.contactDelegate = self
    }
    
//    functionality to move the paddle
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            paddle.position.x = touchLocation.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            paddle.position.x = touchLocation.x
        }
    }
    
//    remove the brick when it is touched by ball
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyAName = contact.bodyA.node?.name
        let bodyBName = contact.bodyB.node?.name
        
        if bodyAName == "Ball" && bodyBName == "Brick" || bodyAName == "Brick" && bodyBName == "Ball"{
            if bodyAName == "Brick"{
                contact.bodyA.node?.removeFromParent()
                score += 1
            }else if bodyBName == "Brick"{
                contact.bodyB.node?.removeFromParent()
                score += 1

            }
        }
    }
    
//    update the screen
    override func update(_ currentTime: TimeInterval){
        if(score == 20){
            scoreLabel.text = "You Win!"
            self.view?.isPaused = true
        }
        if (ball.position.y<paddle.position.y){
            scoreLabel.text = "You Lost!"
            self.view?.isPaused = true
        }
    }

  }






