//
//  GraphViewController+Setup.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

extension GraphViewController {
    func setup() {
        print("Setting up")
        spriteView.showsPhysics = true

        scene.backgroundColor = .clear

        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        scene.camera = cameraNode
    }
}
