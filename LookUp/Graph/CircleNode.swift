//
//  CircleNode.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

class CircleNode: SKShapeNode {
    var contactMetadata = ContactMetadata(phoneNumber: "")
    var circleRadius = CGFloat(20)

    override init() {
        super.init()
    }

    convenience init(contactMetadata: ContactMetadata, circleRadius: CGFloat) {
        self.init()
        self.init(circleOfRadius: circleRadius)
        self.contactMetadata = contactMetadata
        self.circleRadius = circleRadius
        
        let initials: String = {
            let i = contactMetadata.name ?? ""
            let c = i.components(separatedBy: " ")
            let string = c.compactMap { $0.first?.uppercased() }.joined(separator: "")
            return string
        }()
        
        let fontSize = circleRadius * 0.9
        
        let phoneNumberNode = SKLabelNode(text: initials)
        phoneNumberNode.fontName = "SF Pro"
        phoneNumberNode.fontSize = fontSize
        phoneNumberNode.position = CGPoint(x: -fontSize * 0.03, y: -fontSize * 0.36)
        addChild(phoneNumberNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
