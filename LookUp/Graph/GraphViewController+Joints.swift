//
//  GraphViewController+Joints.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

extension GraphViewController {
    func drawLines() {
        let bridgeSize = CGSize(width: 10, height: 3)
        
        for link in graphViewModel.graph.links {
            let arr = Array(link).sorted()
            let a = arr[0]
            let b = arr[1]
            
            let aNode = phoneNumberToNode[a]!
            let bNode = phoneNumberToNode[b]!
            
            let distance = CGPointDistance(from: aNode.position, to: bNode.position)
            let numberOfComponents = Int(distance / 20)
            
            let angle = atan2(bNode.position.y - aNode.position.y, bNode.position.x - aNode.position.x)
            
            let circleRadius = CGFloat(20)
            
            let physicsCircleRadius = circleRadius * GraphConstants.physicsCircleBorderMultiplier
            let aPosition = CGPoint(x: aNode.position.x + cos(angle) * physicsCircleRadius, y: aNode.position.y + sin(angle) * physicsCircleRadius)
            let bPosition = CGPoint(x: bNode.position.x - cos(angle) * physicsCircleRadius, y: bNode.position.y - sin(angle) * physicsCircleRadius)
            
            let xDistance = bPosition.x - aPosition.x
            let yDistance = bPosition.y - aPosition.y
            
            let dx = xDistance / Double(numberOfComponents)
            let dy = yDistance / Double(numberOfComponents)
            
            var shapes = [SKShapeNode]()
            for i in 0 ..< numberOfComponents {
                let shape = SKShapeNode(rectOf: bridgeSize, cornerRadius: 1.5)
                shape.fillColor = .label.withAlphaComponent(0.15)
                shape.strokeColor = .clear
                
                let position = CGPoint(
                    x: aPosition.x + dx * Double(i),
                    y: aPosition.y + dy * Double(i)
                )
                
                shape.position = position
                shape.zRotation = angle
                
                let physicsBody = SKPhysicsBody(rectangleOf: bridgeSize)
                physicsBody.categoryBitMask = CollisionTypes.bridge.rawValue
                physicsBody.collisionBitMask = CollisionTypes.node.rawValue
                shape.physicsBody = physicsBody
                shapes.append(shape)
                scene.addChild(shape)
                
                if i >= 1 {
                    let point = CGPoint(
                        x: aPosition.x + dx * Double(i - 1),
                        y: aPosition.y + dy * Double(i - 1)
                    )
                    
                    let spring = SKPhysicsJointSpring.joint(
                        withBodyA: shapes[i - 1].physicsBody!,
                        bodyB: physicsBody,
                        anchorA: point,
                        anchorB: point
                    )

                    scene.physicsWorld.add(spring)
                }
            }
        }
    }
}
