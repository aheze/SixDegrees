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
        let position = CGPoint(
            x: offset.x + canvasLength / 2,
            y: -offset.y + canvasLength / 2
        )

        cameraNode.position = position
        
        let newScale = 1 / scale
        cameraNode.setScale(newScale)
    }
}
