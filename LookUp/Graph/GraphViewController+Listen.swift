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

                    let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)
                    first.run(scaleUp)
                    self.graphViewModel.selectedPhoneNumber = first.phoneNumber
                    self.graphViewModel.tappedPhoneNumber = nil
                }
                return true
            }
        }

        gestureScrollViewController.scrollView.began = { [weak self] point in
            guard let self else { return }

            let nodes = self.hitTest(location: point)
            if let first = nodes.first(where: { $0 is CircleNode }) {
                let first = first as! CircleNode

                self.graphViewModel.tappedPhoneNumber = first.phoneNumber
            }
        }

        gestureScrollViewController.scrollView.moved = { [weak self] _ in
            guard let self else { return }
        }

        gestureScrollViewController.scrollView.ended = { [weak self] in
            guard let self else { return }

            if let tappedPhoneNumber = self.graphViewModel.tappedPhoneNumber {
                print("Tapped: \(tappedPhoneNumber)")
            }

            if let selectedPhoneNumber = self.graphViewModel.selectedPhoneNumber {
                print("Ended: \(selectedPhoneNumber)")

                let scaleDown = SKAction.scale(to: 1, duration: 0.5)
                self.phoneNumberToNode[selectedPhoneNumber]?.run(scaleDown)
            }

            self.graphViewModel.tappedPhoneNumber = nil
            self.graphViewModel.selectedPhoneNumber = nil
        }
    }
}
