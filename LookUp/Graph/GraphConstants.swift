//
//  GraphConstants.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

enum GraphConstants {
    static var physicsCircleBorderMultiplier = CGFloat(1.5)
}

enum CollisionTypes: UInt32 {
    case node = 1
    case bridge = 2
}
