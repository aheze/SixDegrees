//
//  GestureScrollView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

class GestureScrollViewController: UIViewController {
    var scrollView = UIScrollView()
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
        
        contentView.addDebugBorders(.red)
    }

    override func viewWillLayoutSubviews() {
        scrollView.minimumZoomScale = min(view.bounds.width, view.bounds.height) / scrollableLength
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
        let leftMargin = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
        let topMargin = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5

        scrollView.contentInset = UIEdgeInsets(top: topMargin, left: leftMargin, bottom: topMargin, right: leftMargin)
    }
}
