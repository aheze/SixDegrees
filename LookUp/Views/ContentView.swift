//
//  ContentView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = ViewModel()
    @StateObject var graphViewModel = GraphViewModel()
    
    @State var showingPermissions = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Hello, world!")
            
            Button("Start") {
                showingPermissions = true
            }
            
            GraphDebugView(
                graph: DummyData.generateGraph(
                    phoneNumber: model.ownPhoneNumber,
                    targetDepth: 3
                )
            )
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(
                    LinearGradient(colors: [.blue, .green], startPoint: .top, endPoint: .bottom)
                )
                .overlay {
                    GraphViewControllerRepresentable(graphViewModel: graphViewModel)
                }
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPermissions) {
            PermissionsView()
                .presentationDetents([.medium, .large])
                .presentationBackground {
                    Rectangle()
                        .fill(.regularMaterial)
                }
        }
        .environmentObject(model)
    }
}

#Preview {
    ContentView()
}
