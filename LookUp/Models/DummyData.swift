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
        "99999": ["3100000000"],
        "696969": ["9252149133", "99999"]
    ]
    
    static let storage: [String: ContactMetadata] = [
        "9252149133": andy,
        "3100000000": brandon,
        "123456789": brayden,
        "4123123123": neel,
        "99999": rachel,
        "696969": lynn,
    ]
    
    static let andy = ContactMetadata(phoneNumber: "9252149133", name: "andy")
    static let brandon = ContactMetadata(phoneNumber: "3100000000", name: "brandon")
    static let brayden = ContactMetadata(phoneNumber: "123456789", name: "brayden")
    static let neel = ContactMetadata(phoneNumber: "4123123123", name: "neel")
    static let rachel = ContactMetadata(phoneNumber: "99999", name: "rachel")
    static let lynn = ContactMetadata(phoneNumber: "696969", name: "lynn")
    
    static func generateGraph(ownContactMetadata: ContactMetadata, targetDepth: Int) -> Graph {
        var visitedPhoneNumbers = Set<String>()
        let rootNode = ownContactMetadata.getNode(targetDepth: targetDepth, currentDepth: 0, visitedPhoneNumbers: &visitedPhoneNumbers)
        
        let graph = Graph(depth: targetDepth, rootNode: rootNode)
        return graph
    }
    
    static func getContactMetadatas(phoneNumber: String) -> [ContactMetadata] {
        let connections = userToConnections[phoneNumber]!
        let metadatas = connections.map { storage[$0]! }
        return metadatas
    }
}

extension ContactMetadata {
    func getNode(targetDepth: Int, currentDepth: Int, visitedPhoneNumbers: inout Set<String>) -> Node {
        var node = Node(contactMetadata: self, connections: [])
        visitedPhoneNumbers.insert(phoneNumber)
        
        if currentDepth >= targetDepth {
            return node
        }
        
        for metadata in DummyData.getContactMetadatas(phoneNumber: phoneNumber) {
            
            // prevent overlaps when graph loops back to itself
            if visitedPhoneNumbers.contains(metadata.phoneNumber) {
                continue
            }
            
            let child = metadata.getNode(targetDepth: targetDepth, currentDepth: currentDepth + 1, visitedPhoneNumbers: &visitedPhoneNumbers)
            node.connections.append(child)
        }
        
        return node
    }
}

// extension ContactMetadata {
//    func generateNodes(targetDepth: Int, currentDepth: Int) -> [Node] {
//        if currentDepth == targetDepth {
//            return [Node(ownContactMetadata: self, connections: [])]
//        }
//
//        let connections = DummyData.userToConnections[phoneNumber]!
//        var nodes = [Node]()
//        for connection in connections {
//            let metadata = DummyData.storage[connection]!
//            nodes += Node(ownContactMetadata: metadata, connections: <#T##[Node]#>)
//
//            for c in DummyData.userToConnections[connection]! {
//                let m = DummyData.storage[c]!
//                nodes += m.generateNodes(targetDepth: targetDepth, currentDepth: currentDepth + 1)
//            }
//        }
//
//        return nodes
//    }
// }

// extension Node {
//    func generateGraph(phoneNumber: String, depth: Int, currentDepth: Int) -> Graph {
//
//    }
// }

//    static func generateGraph(ownPhoneNumber: String, ownName: String, depth: Int) -> Graph {
//        let ownContactMetadata = ContactMetadata(phoneNumber: ownPhoneNumber, name: ownName)
//
//
////        let rootNode = Node(ownContactMetadata: ownContactMetadata, connections: <#T##[Node]#>)
//    }
//
//    static func generateGraph(phoneNumber: String, targetDepth: Int, currentDepth: Int) -> Graph {
//        let connections = userToConnections[phoneNumber]!
//        for connection in connections {
//            let metadata = storage[connection]
//
//        }
//    }
