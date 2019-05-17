//
//  MainMenu.swift
//  PeevedPenguins
//
//  Created by Basanta Chaudhuri on 7/7/17.
//  Copyright © 2017 Abhishek Chaudhuri. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    var secretButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Set UI connections */
        buttonPlay = self.childNode(withName: "buttonPlay") as? MSButtonNode
        secretButton = self.childNode(withName: "secretButton") as? MSButtonNode
        
        buttonPlay.selectedHandler = {
            self.loadGame(level: 1)
        }
        
        secretButton.selectedHandler = {
            self.loadGame(level: 2)
        }
    }
    
    func loadGame(level: Int) {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Cound not get SKview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene.level(level) else {
            print("Could not load GameScene with level \(level)")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
