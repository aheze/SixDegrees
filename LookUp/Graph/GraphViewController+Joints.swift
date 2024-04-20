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
        let bridgeSize = CGSize(width: 6, height: 2)
        let numberOfComponents = 10
        
        for link in graphViewModel.graph.links {
            let arr = Array(link).sorted()
            let a = arr[0]
            let b = arr[1]
            
            let aNode = phoneNumberToNode[a]!
            let bNode = phoneNumberToNode[b]!
            
            let angle = atan2(bNode.position.y - aNode.position.y, bNode.position.x - aNode.position.x)
            
            let xDistance = bNode.position.x - aNode.position.x
            let yDistance = bNode.position.y - aNode.position.y
            
            let dx = xDistance / Double(numberOfComponents)
            let dy = yDistance / Double(numberOfComponents)
            
            print("a: \(aNode.position), \(bNode.position) -> \(angle)")
            
            var shapes = [SKShapeNode]()
            for i in 0 ..< numberOfComponents {
                let shape = SKShapeNode(rectOf: bridgeSize, cornerRadius: 1)
                shape.fillColor = .green
                shape.strokeColor = .clear
                
                let position = CGPoint(
                    x: aNode.position.x + dx * Double(i),
                    y: aNode.position.y + dy * Double(i)
                )
                
                shape.position = position
                shape.zRotation = angle
                
                let physicsBody = SKPhysicsBody(rectangleOf: bridgeSize)
                shape.physicsBody = physicsBody
                shapes.append(shape)
                scene.addChild(shape)
                
                if i >= 1 {
                    let point = CGPoint(
                        x: aNode.position.x + dx * Double(i - 1),
                        y: aNode.position.y + dy * Double(i - 1)
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
//
//            for index in 1..<10 {
//                let previous = shapes[index - 1]
//                let current = shapes[index]
//
//                let spring = SKPhysicsJointSpring.joint(
//                    withBodyA: previous.physicsBody!,
//                    bodyB: current.physicsBody!,
//                    anchorA: CGPoint(x: previous.position.x + bridgeSize.width, y: previous.position.y),
//                    anchorB: CGPoint(x: current.position.x - bridgeSize.width, y: current.position.y)
//                )
//
//                scene.physicsWorld.add(spring)
//            }
        }
    }
}
