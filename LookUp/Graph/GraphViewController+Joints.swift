//
//  GraphViewController+Joints.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit
import UIKit

extension GraphViewController {
    func drawLines() {
        let bridgeSize = CGSize(width: 6, height: 1.5)
        
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
            
            var shapes = [SKShapeNode]()
            
            let spring = SKPhysicsJointSpring.joint(
                withBodyA: aNode.physicsBody!,
                bodyB: bNode.physicsBody!,
                anchorA: aNode.position,
                anchorB: bNode.position
            )
            
            scene.physicsWorld.add(spring)
            
//            let aPosition = CGPoint(x: aNode.position.x, y: aNode.position.y)
//            let bPosition = CGPoint(
//                x: bNode.position.x,
//                y: bNode.position.y
//            )
//

            let aPosition = CGPoint(x: aNode.position.x + cos(angle) * physicsCircleRadius, y: aNode.position.y + sin(angle) * physicsCircleRadius)
            let bPosition = CGPoint(
                x: bNode.position.x - cos(angle) * physicsCircleRadius,
                y: bNode.position.y - sin(angle) * physicsCircleRadius
            )
            
            let xDistance = bPosition.x - aPosition.x
            let yDistance = bPosition.y - aPosition.y
            
            let dx = xDistance / Double(numberOfComponents)
            let dy = yDistance / Double(numberOfComponents)
            
            for i in 0 ..< numberOfComponents {
                let shape = SKShapeNode(rectOf: bridgeSize, cornerRadius: 1.5)
                shape.fillColor = UIColor(hex: 0xD2D2D2)
                shape.strokeColor = .clear
                
                let position = CGPoint(
                    x: aPosition.x + dx * Double(i),
                    y: aPosition.y + dy * Double(i)
                )
                
                shape.position = position
                shape.zRotation = angle
                
                let physicsBody = SKPhysicsBody(rectangleOf: bridgeSize)
                physicsBody.categoryBitMask = CollisionTypes.bridge.rawValue
//                physicsBody.collisionBitMask = CollisionTypes.node.rawValue
                physicsBody.collisionBitMask = 0
                shape.physicsBody = physicsBody
                shapes.append(shape)
                scene.addChild(shape)
                
                if i >= 1 {
                    let point = CGPoint(
                        x: aPosition.x + dx * Double(i - 1),
                        y: aPosition.y + dy * Double(i - 1)
                    )
                    
//                    let pin
                    
//                    let spring = SKPhysicsJointSpring.joint(
//                        withBodyA: shapes[i - 1].physicsBody!,
//                        bodyB: physicsBody,
//                        anchorA: shapes[i - 1].position,
//                        anchorB: position
//                    )
                    
//                    scene.physicsWorld.add(spring)
                }
            }
            
            linkToLines[link] = shapes
        }
    }
}
