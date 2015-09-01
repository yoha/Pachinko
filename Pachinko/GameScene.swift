//
//  GameScene.swift
//  Pachinko
//
//  Created by Yohannes Wijaya on 8/22/15.
//  Copyright (c) 2015 Yohannes Wijaya. All rights reserved.
//
//  Todo: 1) Create rounder corners on generated obstacle boxes.


import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Stored Properties

    let behindEveryNode: CGFloat = -1.0
    
    var goodOrBad = true
    
    var score = 0 {
        didSet {
            scoreLabelNode.text = "Score: \(score)"
        }
    }
    var scoreLabelNode: SKLabelNode!
    var editLabelNode: SKLabelNode!
    
    var boxSpriteNode: SKSpriteNode!
    
    var editingMode = false {
        didSet {
            editLabelNode.text = editingMode ? "Done" : "Edit"
        }
    }
    
    let balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballYellow", "ballRed"]
    
    // MARK: - Method Overrides
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        //*****************
        // MARK: Background
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
        
        //************
        // MARK: Score
        //************
        
        self.scoreLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        self.scoreLabelNode.text = "Score: 0"
        self.scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        self.scoreLabelNode.position = CGPointMake(980, 700)
        self.addChild(self.scoreLabelNode)
        
        //****************
        // MARK: Edit Mode
        //****************
        
        self.editLabelNode = SKLabelNode(fontNamed: "Chalkduster")
        self.editLabelNode.text = "Edit"
        self.editLabelNode.position = CGPointMake(80, 700)
        self.addChild(self.editLabelNode)
        
        //****************
        // MARK: Obstacle
        //****************
        
        self.boxSpriteNode = SKSpriteNode()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first  {
            let locationOfTouch = touch.locationInNode(self)
            let arrayOfNodesAtTouchLocation = self.nodesAtPoint(locationOfTouch)
            if arrayOfNodesAtTouchLocation.contains(self.editLabelNode) {
                self.editingMode = !self.editingMode
            }
            else if self.editingMode {
                
                //****************
                // MARK: Obstacle
                //****************
                
                // remove existing obstacle
                let possibleTargetSpriteNode = self.nodeAtPoint(locationOfTouch)
                if arrayOfNodesAtTouchLocation.contains(possibleTargetSpriteNode) {
                    if possibleTargetSpriteNode.name == "obstacle" { self.removeChildrenInArray([possibleTargetSpriteNode]) }
                    else {
                        // create obstacle
                        let boxSize = CGSize(width: RandomInt(16, max: 128), height: 16)
                        self.boxSpriteNode = SKSpriteNode(color: RandomColor(), size: boxSize)
                        self.boxSpriteNode.zRotation = RandomCGFloat(0.0, max: 3.0)
                        self.boxSpriteNode.position = locationOfTouch
                        self.boxSpriteNode.physicsBody = SKPhysicsBody(rectangleOfSize: boxSpriteNode.size)
                        self.boxSpriteNode.physicsBody!.dynamic = false
                        self.boxSpriteNode.name = "obstacle"
                        self.addChild(self.boxSpriteNode)
                    }
                }
                    // create rounded border
//                    let cropNode = SKCropNode()
//                    let maskShapeNode = SKShapeNode()
//                    maskShapeNode.path = CGPathCreateWithRoundedRect(CGRectMake(locationOfTouch.x, locationOfTouch.y, boxSize.width, boxSize.height), 1.0, 1.0, nil)
//                    maskShapeNode.fillColor = UIColor.greenColor()
//                    cropNode.maskNode = maskShapeNode
//                    cropNode.addChild(self.boxSpriteNode)
//                    self.addChild(cropNode)
//                    http://stackoverflow.com/questions/21695305/skspritenode-create-a-round-corner-node?lq=1
//                }
            }
            else {
                
                //***********
                // MARK: Ball
                //***********
                
                let randomBallColor = self.balls[RandomInt(0, max: 6)]
                let ballSpriteNode = SKSpriteNode(imageNamed: randomBallColor)
                ballSpriteNode.name = "ball"
                ballSpriteNode.physicsBody = SKPhysicsBody(circleOfRadius: ballSpriteNode.size.width / 2.0)
                ballSpriteNode.physicsBody!.contactTestBitMask = ballSpriteNode.physicsBody!.collisionBitMask
                ballSpriteNode.physicsBody!.restitution = 0.4
                ballSpriteNode.position = CGPointMake(locationOfTouch.x, self.frame.size.height)
                self.addChild(ballSpriteNode)
            }
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
    // MARK: Bouncer
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
    // MARK: Slot
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
        
        let slotSpinAction = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 3.0)
        let slotSpinRepeatForeverAction = SKAction.repeatActionForever(slotSpinAction)
        slotGlow.runAction(slotSpinRepeatForeverAction)
    }
    
    func collideWithBall(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            self.destroyBall(ball)
            ++self.score
        }
        else if object.name == "bad" {
            self.destroyBall(ball)
            --self.score
        }
    }
    
    func destroyBall(ball: SKNode) {
        if let myParticlePath = NSBundle.mainBundle().pathForResource("FireParticles", ofType: "sks") {
            let fireParticles = NSKeyedUnarchiver.unarchiveObjectWithFile(myParticlePath) as! SKEmitterNode
            fireParticles.position = ball.position
            self.addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
}
