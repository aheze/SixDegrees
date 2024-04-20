//
//  GestureScrollView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

class GestureScrollViewController: UIViewController {
    var scrollView = GestureScrollView()
    var contentView = UIView()

    var scrolled: ((CGPoint, CGFloat) -> Void)?

    let scrollableLength = CGFloat(2000)

    init() {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(scrollView)
        scrollView.pinEdgesToSuperview()

        scrollView.addSubview(contentView)
        contentView.pinEdgesToSuperview()
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: scrollableLength),
            contentView.heightAnchor.constraint(equalToConstant: scrollableLength)
        ])

        scrollView.scrollsToTop = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self

        scrollView.delaysContentTouches = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let offset = CGPoint(
            x: (scrollView.contentSize.width - scrollView.bounds.width) / 2,
            y: (scrollView.contentSize.height - scrollView.bounds.height) / 2
        )

        scrollView.contentOffset = offset
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.minimumZoomScale = min(scrollView.bounds.width, scrollView.bounds.height) / scrollableLength
        scrollView.maximumZoomScale = 4
        centerContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GestureScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        centerContent()

        let offset = CGPoint(
            x: scrollView.contentOffset.x + (scrollView.bounds.width - scrollView.contentSize.width) / 2,
            y: scrollView.contentOffset.y + (scrollView.bounds.height - scrollView.contentSize.height) / 2
        )

        scrolled?(offset, scrollView.zoomScale)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}

extension GestureScrollViewController {
    func centerContent() {
        var leftMargin = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
        var topMargin = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5

        leftMargin = max(leftMargin, 0)
        topMargin = max(topMargin, 0)

        scrollView.contentInset = UIEdgeInsets(top: topMargin, left: leftMargin, bottom: topMargin, right: leftMargin)
    }
}

class GestureScrollView: UIScrollView {
    var checkShouldForwardTouch: ((CGPoint) -> Bool)?
    var moved: ((CGPoint) -> Void)?
    var ended: (() -> Void)?

    override func touchesShouldCancel(in view: UIView) -> Bool {
        let location = panGestureRecognizer.location(in: nil)

        if let checkShouldForwardTouch {
            return !checkShouldForwardTouch(location)
        }

        return false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let first = touches.first {
            moved?(first.location(in: nil))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        ended?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        ended?()
    }
}
