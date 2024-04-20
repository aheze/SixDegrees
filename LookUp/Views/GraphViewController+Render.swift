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
//    func render() {
//        let shape = SKShapeNode(circleOfRadius: 30)
//        shape.fillColor = .red
//        shape.strokeColor = .clear
//        shape.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
//        scene.addChild(shape)
//    }
    
    func render() {
        render(node: graphViewModel.graph.rootNode, level: 0, angle: 0)
    }

    func render(node: Node, level: Int, angle: Double) {
        
        let s = Double(level) * self.spacing
        renderCircle(distanceFromCenter: s, angle: angle, circleRadius: 20)
        
        let angles = Positioning.getAngles(count: node.connections.count)
        for index in node.connections.indices {
            let child = node.connections[index]
            render(node: child, level: level + 1, angle: angles[index])
        }
    }

    func renderCircle(distanceFromCenter: Double, angle: Double, circleRadius: Double) {
        let shape = SKShapeNode(circleOfRadius: circleRadius)
        shape.fillColor = .red
        shape.strokeColor = .clear
        shape.position = CGPoint(
            x: view.bounds.midX + cos(angle) * distanceFromCenter,
            y: view.bounds.midY + sin(angle) * distanceFromCenter
        )
        scene.addChild(shape)
    }
}
