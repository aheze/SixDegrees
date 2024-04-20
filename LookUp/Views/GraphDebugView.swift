//
//  GraphDebugView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct GraphDebugView: View {
    var graph: Graph
    
    var body: some View {
        VStack {
            NodeDebugView(node: graph.rootNode)
         
            Text("Links:")
            
            ForEach(Array(graph.links), id: \.self) { link in
                let array = Array(link)
                Text("\(array[0]) <> \(array[1])")
            }
        }
    }
}

struct NodeDebugView: View {
    var node: Node
    
    var body: some View {
        VStack {
            VStack {
                Text(node.contactMetadata.phoneNumber)
                
                if let name = node.contactMetadata.name {
                    Text(name)
                }
            }
            .border(.yellow)
            
            HStack(alignment: .top, spacing: 5) {
                ForEach(node.connections, id: \.contactMetadata.phoneNumber) { node in
                    NodeDebugView(node: node)
                }
            }
        }
        .background {
            Color.black
                .opacity(0.1)
        }
    }
}
