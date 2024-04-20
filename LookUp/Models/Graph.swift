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

    // the root node
    var rootNode: Node

    // links between nodes
    // (9252149133, 3102513864), (9252149133, 911), (911, 3102513864)
    var links: Set<Set<String>>
}

struct Node: Codable {
    var contactMetadata: ContactMetadata
    var connections: [Node]
}
