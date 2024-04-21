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
            let start = Double.pi / 2
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
    func startRender() {
//        scene.removeAllChildren()
//        scene.physicsWorld.removeAllJoints()

        graphViewModel.$graph.sink { [weak self] graph in
            guard let self else { return }
            
            self.phoneNumberToNode = [:]
            self.scene.removeAllChildren()
            self.scene.physicsWorld.removeAllJoints()
            self.mainNode = nil
            
            guard let graph else { return }

            self.render(
                node: graph.rootNode,
                level: 0,
                point: CGPoint(x: canvasLength / 2, y: canvasLength / 2),
                circleRadius: 60
            )

            self.drawLines(graph: graph)
        }
        .store(in: &cancellables)
    }

    func render(node: Node, level: Int, point: CGPoint, circleRadius: CGFloat) {
        let levelDouble = Double(level)

        let color: UIColor = {
            switch level {
            case 0:
                return UIColor(hex: 0xA148FF)
            case 1:
                return UIColor(hex: 0xC344FF)
            case 2:
                return UIColor(hex: 0xFF4598)
            case 3:
                return UIColor(hex: 0xFF8F48)
            default:
                return UIColor(hex: 0x5DCF1A)
            }
        }()
        
        let n = renderCircle(
            contactMetadata: node.contactMetadata,
            level: level,
            point: point,
            circleRadius: circleRadius,
            color: color.withAlphaComponent(Double(1) - levelDouble * 0.05)
        )
        if level == 0 {
            mainNode = n
        }

        let newLevel = level + 1
        let angles = Positioning.getAngles(count: node.children.count)

        let circleRadius: Double = {
            switch newLevel {
            case 0:
                return 60
            case 1:
                return 18
            default:
                return 10
            }
        }()

        let distanceFromCenter: Double = {
            switch newLevel {
            case 0:
                return 150
            case 1:
                return 180
            default:
                return 90
            }
        }()

        if !node.children.isEmpty {
            for index in node.children.indices {
                let angle = angles[index]
                let additionalDistance = Double.random(in: -distanceFromCenter / 4 ... distanceFromCenter / 4)

                let newPoint = CGPoint(
                    x: point.x + cos(angle) * distanceFromCenter + additionalDistance,
                    y: point.y + sin(angle) * distanceFromCenter + additionalDistance
                )

                let child = node.children[index]
                render(node: child, level: newLevel, point: newPoint, circleRadius: circleRadius)
            }
        }
    }

    @discardableResult func renderCircle(contactMetadata: ContactMetadata, level: Int, point: CGPoint, circleRadius: Double, color: UIColor) -> CircleNode {
        let shape = CircleNode(contactMetadata: contactMetadata, circleRadius: circleRadius)
        shape.fillColor = color
        shape.strokeColor = .clear
        shape.position = point

        let physicsBody = SKPhysicsBody(circleOfRadius: circleRadius * GraphConstants.physicsCircleBorderMultiplier)
        physicsBody.categoryBitMask = CollisionTypes.node.rawValue
//        physicsBody.collisionBitMask = CollisionTypes.bridge.rawValue
        physicsBody.collisionBitMask = CollisionTypes.node.rawValue

        if level == 0 {
            physicsBody.isDynamic = false
        }

        shape.physicsBody = physicsBody
        scene.addChild(shape)

        phoneNumberToNode[contactMetadata.phoneNumber] = shape
        
        return shape
    }
}
