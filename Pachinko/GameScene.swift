//
//  GameScene.swift
//  Pachinko
//
//  Created by Yohannes Wijaya on 8/22/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Stored Properties

    let behindEveryNode: CGFloat = -1.0
    var goodOrBad = true
    
    // MARK: - Method Overrides
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let backgroundSpriteNode = SKSpriteNode(imageNamed: "background.jpg")
        backgroundSpriteNode.position = CGPointMake(512, 384)
        backgroundSpriteNode.blendMode = SKBlendMode.Replace
        backgroundSpriteNode.zPosition = self.behindEveryNode
        self.addChild(backgroundSpriteNode)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        for var i: CGFloat = 128; i <= 896; i += 256 {
            self.makeSlotAt(CGPointMake(i, 0), isGood: self.goodOrBad)
            self.goodOrBad = !self.goodOrBad
        }
        for var i: CGFloat = 0.0; i <= 1024.0; i += 256.0 {
            self.makeBouncerSpriteNodeAt(CGPointMake(i, 0))
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if let touch = touches.first  {
            let locationOfTouch = touch.locationInNode(self)
            let ballSpriteNode = SKSpriteNode(imageNamed: "ballRed")
            ballSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: ballSpriteNode.size.width / 2.0)
            ballSpriteNode.physicsBody!.restitution = 0.4
            ballSpriteNode.position = locationOfTouch
            self.addChild(ballSpriteNode)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // Mark: - Custom Methods
    
    func makeBouncerSpriteNodeAt(position: CGPoint) {
        let bouncerSpriteNode = SKSpriteNode(imageNamed: "bouncer")
        bouncerSpriteNode.position = position
        bouncerSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: bouncerSpriteNode.size.width / 2)
        bouncerSpriteNode.physicsBody!.dynamic = false
        self.addChild(bouncerSpriteNode)
    }
    
    func makeSlotAt(position: CGPoint, isGood: Bool) {
        let slotBase = isGood ? SKSpriteNode(imageNamed: "slotBaseGood") : SKSpriteNode(imageNamed: "slotBaseBad")
        slotBase.position = position
        self.addChild(slotBase)
        
        let slotGlow = isGood ? SKSpriteNode(imageNamed: "slotGlowGood") : SKSpriteNode(imageNamed: "slotGlowBad")
        slotGlow.position = position
        self.addChild(slotGlow)
        
        let slotSpinAction = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10.0)
        let slotSpinRepeatForeverAction = SKAction.repeatActionForever(slotSpinAction)
        slotGlow.runAction(slotSpinRepeatForeverAction)
    }
}
