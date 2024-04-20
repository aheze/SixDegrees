//
//  GraphViewController+Hit.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

extension GraphViewController {
    func hitTest(location: CGPoint) -> [SKNode] {
        let sceneLocation = spriteView.convert(location, to: scene)
        
        return scene.nodes(at: sceneLocation)
    }
}
