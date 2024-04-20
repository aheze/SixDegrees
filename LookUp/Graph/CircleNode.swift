//
//  CircleNode.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

class CircleNode: SKShapeNode {
    var phoneNumber = ""
    var circleRadius = CGFloat(20)

    override init() {
        super.init()
    }

    convenience init(phoneNumber: String, circleRadius: CGFloat) {
        self.init()
        self.phoneNumber = phoneNumber
        self.circleRadius = circleRadius
        self.init(circleOfRadius: circleRadius)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
