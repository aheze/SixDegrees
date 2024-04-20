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
    
    // links that violate the top-down tree structure.
    // for example, lynn to rachel, or rachel to andrew.
    
    // all links
    var links: Set<Link>
}

struct Link: Codable, Hashable {
//    var a: String
//    var b: String
    
    var s: Set<String>
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(a)
//        hasher.combine(b)
//    }
    
//    static func == (lhs: Link, rhs: Link) -> Bool {
//        // order doesn't matter
//        (lhs.a == rhs.a && lhs.b == rhs.b) || (lhs.a == rhs.b && lhs.b == rhs.a)
//    }
}

struct Node: Codable {
    var contactMetadata: ContactMetadata
    var connections: [Node]
}
