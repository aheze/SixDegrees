//
//  DummyData.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import Foundation

enum DummyData {
    static let userToConnections: [String: [String]] = [
        "9252149133": ["3100000000", "4123123123", "696969"],
        "3100000000": ["9252149133", "99999"],
        "123456789": ["9252149133", "3100000000"],
        "4123123123": ["9252149133"],
        "99999": ["3100000000", "9252149133"],
        "696969": ["9252149133", "99999"],
    ]

    static let storage: [String: ContactMetadata] = [
        "9252149133": ContactMetadata(phoneNumber: "9252149133", name: "andy"),
        "3100000000": ContactMetadata(phoneNumber: "3100000000", name: "brandon"),
        "123456789": ContactMetadata(phoneNumber: "123456789", name: "brayden"),
        "4123123123": ContactMetadata(phoneNumber: "4123123123", name: "neel"),
        "99999": ContactMetadata(phoneNumber: "99999", name: "rachel"),
        "696969": ContactMetadata(phoneNumber: "696969", name: "lynn"),
    ]

    static func generateGraph(phoneNumber: String, targetDepth: Int) -> Graph {
        var visitedPhoneNumbers = Set<String>()
        var links = Set<Set<String>>()

        let ownContactMetadata = ContactMetadata(phoneNumber: phoneNumber)
        let rootNode = getNode(
            contactMetadata: ownContactMetadata,
            targetDepth: targetDepth,
            currentDepth: 1,
            visitedPhoneNumbers: &visitedPhoneNumbers,
            links: &links
        )

        let graph = Graph(depth: targetDepth, rootNode: rootNode, links: links)
        return graph
    }

    // generates a node
    static func getNode(contactMetadata: ContactMetadata, targetDepth: Int, currentDepth: Int, visitedPhoneNumbers: inout Set<String>, links: inout Set<Set<String>>) -> Node {
        var node = Node(contactMetadata: contactMetadata, connections: [])
        visitedPhoneNumbers.insert(contactMetadata.phoneNumber)

        if currentDepth >= targetDepth {
            return node
        }

        let connections = DummyData.userToConnections[contactMetadata.phoneNumber]!
        let metadatas = connections.map { DummyData.storage[$0]! }

        for metadata in metadatas {
            // insert a link
            let link = Set([contactMetadata.phoneNumber, metadata.phoneNumber])
            links.insert(link)

            // prevent overlaps when graph loops back to itself
            if visitedPhoneNumbers.contains(metadata.phoneNumber) {
                continue
            }

            let child = getNode(
                contactMetadata: metadata,
                targetDepth: targetDepth,
                currentDepth: currentDepth + 1,
                visitedPhoneNumbers: &visitedPhoneNumbers,
                links: &links
            )
            node.connections.append(child)
        }

        return node
    }
}
