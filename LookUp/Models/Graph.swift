//
//  Graph.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

struct Graph: Codable {
    
    // how many levels of connections there are
    var depth: Int
    
    var rootNode: Node
}

struct Node: Codable {
    var ownContactMetadata: ContactMetadata
    var connections: [Node]
}
