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

    enum CodingKeys: String, CodingKey {
        case depth, rootNode, links
    }
}

extension Graph {
    init(from decoder: Decoder) throws {
        print("Custom decoder!")
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the depth as a string and convert it to an integer
        let depthString = try container.decode(String.self, forKey: .depth)
        guard let depthInt = Int(depthString) else {
            throw DecodingError.dataCorruptedError(forKey: .depth,
                                                   in: container,
                                                   debugDescription: "Depth should be an integer contained in a string.")
        }
        depth = depthInt

        // Decode the other properties using the default decoding
        rootNode = try container.decode(Node.self, forKey: .rootNode)
        links = try container.decode(Set<Set<String>>.self, forKey: .links)
    }
}

struct Node: Codable {
    var contactMetadata: ContactMetadata
    var children: [Node]
}
