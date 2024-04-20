//
//  GraphViewController+Delegate.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

extension GraphViewController: SKSceneDelegate {
    func didSimulatePhysics(for scene: SKScene) {
        
        
        drawLines()
    }
}
