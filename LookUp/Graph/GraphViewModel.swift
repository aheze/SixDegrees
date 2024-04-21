//
//  GraphViewModel.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Combine
import SwiftUI

class GraphViewModel: ObservableObject {
//    @Published var graph = Graph(depth: 0, rootNode: Node(contactMetadata: ContactMetadata(phoneNumber: "Phone Number"), connections: []), links: [])
    
    @Published var graph: Graph?
    
    @Published var selectedPhoneNumber: String?
    @Published var tappedPhoneNumber: String?
    
    @Published var gravityStrength = CGFloat(0)
    
    var recenter = PassthroughSubject<Void, Never>()
}
