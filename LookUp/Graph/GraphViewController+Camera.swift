//
//  GraphViewController+Camera.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import UIKit

extension GraphViewController {
    func adjustCamera(offset: CGPoint, scale: CGFloat) {
        let newScale = 1 / scale

        let adjustedOffset = CGPoint(x: offset.x * newScale, y: offset.y * newScale)

        let position = CGPoint(
            x: adjustedOffset.x + canvasLength / 2,
            y: -adjustedOffset.y + canvasLength / 2
        )

        cameraNode.position = position
        cameraNode.setScale(newScale)
    }
}
