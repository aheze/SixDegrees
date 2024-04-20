//
//  GraphViewController.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

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

    var spacing = Double(80)

    var containerView = UIView()

    var gestureView = UIView()
    var gestureScrollViewController = GestureScrollViewController()
    var cameraNode = SKCameraNode()

    var spriteView = SKView()
    var scene = SKScene(size: .zero)

    let canvasLength = CGFloat(2000)

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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        render()
        
        gestureScrollViewController.scrolled = { [weak self] offset, scale in
            guard let self else { return }
            self.adjustCamera(offset: offset, scale: scale)
        }
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
