//
//  GraphViewModel.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

class GraphViewModel: ObservableObject {
//    @Published var graph = Graph(depth: 0, rootNode: Node(contactMetadata: ContactMetadata(phoneNumber: "Phone Number"), connections: []), links: [])
    
    @Published var graph = DummyData.generateGraph(phoneNumber: "9252149133", targetDepth: 3)
    
    @Published var selectedPhoneNumber: String?
}
