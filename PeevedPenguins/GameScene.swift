//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by Basanta Chaudhuri on 7/7/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* Define a var to hold the camera */
    var cameraNode: SKCameraNode!
    
    /* Add an optional camera target */
    var cameraTarget: SKSpriteNode?
    
    /* Game object connections */
    var catapult: SKSpriteNode!
    var catapultArm: SKSpriteNode!
    
    /* cantileverNode */
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    
    /* UI connections */
    var buttonRestart1: MSButtonNode?
    var buttonRestart2: MSButtonNode?
    
    /* Physics helpers */
    var touchJoint: SKPhysicsJointSpring?
    var penguinJoint: SKPhysicsJointSpring?
    
    override func didMove(to view: SKView) {
        /* Create a new Camera */
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        
        catapult = childNode(withName: "catapult") as! SKSpriteNode
        
        /* Set reference to catapultArm node */
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        
        cantileverNode = childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = childNode(withName: "touchNode") as! SKSpriteNode
        
        /* Set UI connections */
        buttonRestart1 = childNode(withName: "//buttonRestart1") as? MSButtonNode
        buttonRestart2 = childNode(withName: "//buttonRestart2") as? MSButtonNode
        
        /* Reset the game when the reset button is tapped */
        buttonRestart1?.selectedHandler = {
            guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        buttonRestart2?.selectedHandler = {
            guard let scene = GameScene.level(2) else {
                print("Level 2 is missing?")
                return
            }
            
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        setupCatapult()
    }
    
    func setupCatapult() {
        /* Pin joint */
        var pinLocation = catapultArm.position
        pinLocation.x += -10
        pinLocation.y += -70
        let catapultJoint = SKPhysicsJointPin.joint(
            withBodyA: catapult.physicsBody!,
            bodyB: catapultArm.physicsBody!,
            anchor: pinLocation)
        physicsWorld.add(catapultJoint)
        
        /* Spring joint catapult node and cantilever node */
        var anchorAPosition = catapultArm.position
        anchorAPosition.x += 0
        anchorAPosition.y += 50
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: anchorAPosition, anchorB: cantileverNode.position)
        physicsWorld.add(catapultSpringJoint)
        catapultSpringJoint.frequency = 6
        catapultSpringJoint.damping = 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if nodeAtPoint.name == "catapultArm" {  // If the touched node is named "catapultArm" do...
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
            physicsWorld.add(touchJoint!)
            
            let penguin = Penguin()
            addChild(penguin)
            penguin.position.x += catapultArm.position.x + 20
            penguin.position.y += catapultArm.position.y + 50
            penguin.physicsBody?.usesPreciseCollisionDetection = true
            penguinJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: penguin.physicsBody!, anchorA: penguin.position, anchorB: penguin.position)
            physicsWorld.add(penguinJoint!)
            cameraTarget = penguin
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchNode.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check for a touch joint then remove it.
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        
        // Check for a penguin joint then remove it.
        if let penguinJoint = penguinJoint {
            physicsWorld.remove(penguinJoint)
        }
        
        // Check if there is a penguin assigned to the cameraTarget.
        guard let penguin = cameraTarget else {
            return
        }
        
        // Generate a vector and a force based on the angle of the arm.
        let force: CGFloat = 350
        let r = catapultArm.zRotation
        let dx = cos(r) * force
        let dy = sin(r) * force
        // Apply an impulse at the vector.
        let v = CGVector(dx: dx, dy: dy)
        penguin.physicsBody?.applyImpulse(v)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        moveCamera()
        checkPenguin()
    }
    
    /* Make a class method to load levels */
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFit
        return scene
    }
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        /* Get references to the bodies involved in the collision */
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            /* Was the collision more than a gentle nudge? */
            if contact.collisionImpulse > 2.0 {
                /* Kill seal */
                if contactA.categoryBitMask == 2 { removeSeal(node: nodeA) }
                if contactB.categoryBitMask == 2 { removeSeal(node: nodeB) }
            }
        }
    }
    
    func removeSeal(node: SKNode) {
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "Poof")!
        /* Position particles at the Seal node
          If you've moved Seal to an sks, this will need to be
          node.convert(node.position, to: self), not node.position */
        particles.position = node.position
        /* Add particles to the scene */
        addChild(particles)
        let wait = SKAction.wait(forDuration: 5)
        let removeParticles = SKAction.removeFromParent()
        let seq = SKAction.sequence([wait, removeParticles])
        particles.run(seq)
        
        /* Seal death */
        
        /* Create our hero death action */
        let sealDeath = SKAction.run({
            /* Remove seal node from scene */
            node.removeFromParent()
        })
        self.run(sealDeath)
        
        /* Play SFX */
        let sound = SKAction.playSoundFileNamed("sfx_seal", waitForCompletion: false)
        self.run(sound)
    }
    
    func resetCamera() {
        /* Reset camera */
        let cameraReset = SKAction.move(to: CGPoint(x: 0, y: camera!.position.y), duration: 1.5)
        let cameraDelay = SKAction.wait(forDuration: 0.5)
        let cameraSequence = SKAction.sequence([cameraDelay, cameraReset])
        cameraNode.run(cameraSequence)
        cameraTarget = nil
    }
    
    func checkPenguin() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        
        /* Check penguin has come to rest */
        if cameraTarget.physicsBody!.joints.count == 0 && cameraTarget.physicsBody!.velocity.length() < 0.18 {
            resetCamera()
        }
        
        if cameraTarget.position.y < -200 {
            cameraTarget.removeFromParent()
            resetCamera()
        }
    }
}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

extension CGVector {
    public func length() -> CGFloat {
        return CGFloat(sqrt(dx*dx + dy*dy))
    }
}
