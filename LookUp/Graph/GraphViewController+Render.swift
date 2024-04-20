//
//  GraphViewController+Render.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit
import UIKit

enum Positioning {
    static func getAngles(count: Int) -> [Double] {
        switch count {
        case 1:
            return [Double.pi / 2]
        case 2:
            return [3 * Double.pi / 4, Double.pi / 4]
        default:
            let start = -Double.pi / 2
            let angleInterval = (2 * Double.pi) / Double(count)

            var angles = [Double]()
            for index in 0 ..< count {
                angles.append(start + angleInterval * Double(index))
            }

            return angles
        }
    }
}

extension GraphViewController {
    func render() {
        render(node: graphViewModel.graph.rootNode, level: 0, point: CGPoint(x: canvasLength / 2, y: canvasLength / 2))
        
        
        drawLines()
    }

    func render(node: Node, level: Int, point: CGPoint) {
        let levelDouble = Double(level)

        renderCircle(phoneNumber: node.contactMetadata.phoneNumber, point: point, circleRadius: 20, color: .red.withAlphaComponent(Double(1) - levelDouble * 0.3))

        let newLevel = level + 1
        let angles = Positioning.getAngles(count: node.connections.count)
        for index in node.connections.indices {
            let angle = angles[index]

            let distanceFromCenter = Double(newLevel) * spacing
            let newPoint = CGPoint(
                x: point.x + cos(angle) * distanceFromCenter,
                y: point.y + sin(angle) * distanceFromCenter
            )

            let child = node.connections[index]
            render(node: child, level: newLevel, point: newPoint)
        }
    }

    func renderCircle(phoneNumber: String, point: CGPoint, circleRadius: Double, color: UIColor) {
        let shape = SKShapeNode(circleOfRadius: circleRadius)
        shape.fillColor = color
        shape.strokeColor = .clear
        shape.position = point

        let physicsBody = SKPhysicsBody(circleOfRadius: circleRadius)
        shape.physicsBody = physicsBody
        scene.addChild(shape)
        
        phoneNumberToNode[phoneNumber] = shape
    }
}
