//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by Basanta Chaudhuri on 7/7/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    /* Define a var to hold the camera */
    var cameraNode: SKCameraNode!
    
    /* Add an optional camera target */
    var cameraTarget: SKSpriteNode?
    
    /* Game object connections */
    var catapultArm: SKSpriteNode!
    
    /* UI connections */
    var buttonRestart: MSButtonNode!
    
    override func didMove(to view: SKView) {
        /* Create a new Camera */
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        
        /* Set reference to catapultArm node */
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        
        /* Set UI connections */
        buttonRestart = childNode(withName: "//buttonRestart") as! MSButtonNode
        
        /* Reset the game when the reset button is tapped */
        buttonRestart.selectedHandler = {
            guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Make a Penguin
        let penguin = Penguin()
        
        // Add the penguin to this scene
        addChild(penguin)
        
        /* Move penguin to the catapult bucket area */
        penguin.position.x = catapultArm.position.x + 32
        penguin.position.y = catapultArm.position.y + 50
        
        /* Impulse vector */
        let launchImpulse = CGVector(dx: 200, dy: 0)
        
        /* Apply impulse to penguin */
        penguin.physicsBody?.applyImpulse(launchImpulse)
        
        cameraTarget = penguin
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        moveCamera()
    }
    
    /* Make a class method to load levels */
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFill
        return scene
    }
    
    func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
}
