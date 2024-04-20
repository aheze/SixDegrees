//
//  GraphViewController+Listen.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SpriteKit

extension GraphViewController {
    func listen() {
        gestureScrollViewController.scrolled = { [weak self] offset, scale in
            guard let self else { return }
            self.adjustCamera(offset: offset, scale: scale)
        }

        gestureScrollViewController.scrollView.checkShouldForwardTouch = { [weak self] point in
            guard let self else { return false }

            let nodes = self.hitTest(location: point)

            if nodes.isEmpty {
                return false
            } else {
                if let first = nodes.first(where: { $0 is CircleNode }) {
                    let first = first as! CircleNode
                    self.graphViewModel.selectedPhoneNumber = first.phoneNumber
                }
                return true
            }
        }

        gestureScrollViewController.scrollView.moved = { [weak self] _ in
            guard let self else { return }
        }

        gestureScrollViewController.scrollView.ended = { [weak self] in
            guard let self else { return }

            self.graphViewModel.selectedPhoneNumber = nil
        }
    }
}
