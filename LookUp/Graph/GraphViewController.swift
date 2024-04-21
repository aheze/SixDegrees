//
//  GraphViewController.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Combine
import SpriteKit
import SwiftUI

struct GraphViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var graphViewModel: GraphViewModel

    func makeUIViewController(context: Context) -> GraphViewController {
        GraphViewController(graphViewModel: graphViewModel)
    }

    func updateUIViewController(_ uiViewController: GraphViewController, context: Context) {}
}

class GraphViewController: UIViewController {
    var graphViewModel: GraphViewModel

    var spacing = Double(160)

    var containerView = UIView()

    var gestureView = UIView()
    var gestureScrollViewController = GestureScrollViewController()
    var cameraNode = SKCameraNode()

    var spriteView = SKView()
    var scene = SKScene(size: .zero)

    let canvasLength = CGFloat(2000)

    var cancellables = Set<AnyCancellable>()

    // MARK: - Maps

    var phoneNumberToNode = [String: CircleNode]()
    var linkToLines = [Set<String>: [SKNode]]()

    init(graphViewModel: GraphViewModel) {
        self.graphViewModel = graphViewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        view.addSubview(containerView)
        containerView.pinEdgesToSuperview()
        containerView.addSubview(spriteView)
        spriteView.pinEdgesToSuperview()

        view.addSubview(gestureView)
        gestureView.pinEdgesToSuperview()
        addChildViewController(gestureScrollViewController, in: gestureView)

        // MARK: - Setup

        spriteView.backgroundColor = .clear
        scene.size = view.bounds.size
        spriteView.presentScene(scene)
        scene.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        listen()
        startRender()

        graphViewModel.recenter
            .sink { [weak self] in
                guard let self else { return }
                let offset = CGPoint(
                    x: (self.gestureScrollViewController.scrollView.contentSize.width - self.gestureScrollViewController.scrollView.bounds.width) / 2,
                    y: (self.gestureScrollViewController.scrollView.contentSize.height - self.gestureScrollViewController.scrollView.bounds.height) / 2
                )

                self.gestureScrollViewController.scrollView.setContentOffset(offset, animated: true)
                self.gestureScrollViewController.scrollView.zoomScale = 1
            }
            .store(in: &cancellables)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scene.size = view.bounds.size
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
