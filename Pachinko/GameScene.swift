//
//  GameScene.swift
//  Pachinko
//
//  Created by Yohannes Wijaya on 8/22/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Stored Properties

    let behindEveryNode: CGFloat = -1.0
    var goodOrBad = true
    
    // MARK: - Method Overrides
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        //*****************
        // Mark: Background
        //*****************
        
        let backgroundSpriteNode = SKSpriteNode(imageNamed: "background.jpg")
        backgroundSpriteNode.position = CGPointMake(512, 384)
        backgroundSpriteNode.blendMode = SKBlendMode.Replace
        backgroundSpriteNode.zPosition = self.behindEveryNode
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.addChild(backgroundSpriteNode)
        
        for var i: CGFloat = 128; i <= 896; i += 256 {
            self.makeSlotAt(CGPointMake(i, 0), isGood: self.goodOrBad)
            self.goodOrBad = !self.goodOrBad
        }
        for var i: CGFloat = 0.0; i <= 1024.0; i += 256.0 {
            self.makeBouncerSpriteNodeAt(CGPointMake(i, 0))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //***********
        // Mark: Ball
        //***********
        
        if let touch = touches.first  {
            let locationOfTouch = touch.locationInNode(self)
            let ballSpriteNode = SKSpriteNode(imageNamed: "ballRed")
            ballSpriteNode.name = "ball"
            ballSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: ballSpriteNode.size.width / 2.0)
            ballSpriteNode.physicsBody!.contactTestBitMask = ballSpriteNode.physicsBody!.collisionBitMask
            ballSpriteNode.physicsBody!.restitution = 0.4
            ballSpriteNode.position = locationOfTouch
            self.addChild(ballSpriteNode)
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node!.name == "ball" { self.collideWithBall(contact.bodyA.node!, object: contact.bodyB.node!) }
        else if contact.bodyB.node!.name == "ball" { self.collideWithBall(contact.bodyB.node!, object: contact.bodyA.node!) }
    }
    
    
    // Mark: - Custom Methods
    
    //**************
    // Mark: Bouncer
    //**************
    
    func makeBouncerSpriteNodeAt(position: CGPoint) {
        let bouncerSpriteNode = SKSpriteNode(imageNamed: "bouncer")
        bouncerSpriteNode.position = position
        bouncerSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: bouncerSpriteNode.size.width / 2)
        bouncerSpriteNode.physicsBody!.contactTestBitMask = bouncerSpriteNode.physicsBody!.collisionBitMask
        bouncerSpriteNode.physicsBody!.dynamic = false
        self.addChild(bouncerSpriteNode)
    }
    
    //***********
    // Mark: Slot
    //***********
    
    func makeSlotAt(position: CGPoint, isGood: Bool) {
        let slotBase = isGood ? SKSpriteNode(imageNamed: "slotBaseGood") : SKSpriteNode(imageNamed: "slotBaseBad")
        slotBase.name = isGood ? "good" : "bad"
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
        slotBase.physicsBody!.dynamic = false
        self.addChild(slotBase)
        
        let slotGlow = isGood ? SKSpriteNode(imageNamed: "slotGlowGood") : SKSpriteNode(imageNamed: "slotGlowBad")
        slotGlow.position = position
        self.addChild(slotGlow)
        
        let slotSpinAction = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10.0)
        let slotSpinRepeatForeverAction = SKAction.repeatActionForever(slotSpinAction)
        slotGlow.runAction(slotSpinRepeatForeverAction)
    }
    
    func collideWithBall(ball: SKNode, object: SKNode) {
        if object.name == "good" || object.name == "bad" { destroyBall(ball) }
    }
    
    func destroyBall(ball: SKNode) { ball.removeFromParent() }
}
