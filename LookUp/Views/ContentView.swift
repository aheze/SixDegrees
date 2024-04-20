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

    @State var started = false
    var body: some View {
        VStack {
            Text("LookUp")
                .bold()
            
            Text("Find connections between people.")
            
            Button("Initiate Graph") {
//                showingPermissions = true
                started = true
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)

            if started {
                Spacer()
                
                VStack {
                    Text("Debug!")
                    
                    GraphDebugView(
                        graph: DummyData.generateGraph(
                            phoneNumber: model.ownPhoneNumber,
                            targetDepth: 3
                        )
                    )
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 36)
                        .fill(.regularMaterial)
                        .environment(\.colorScheme, .dark)
                }
            }
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
                    if started {
                        GraphViewControllerRepresentable(graphViewModel: graphViewModel)
                    }
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
        .animation(.spring(response: 0.9, dampingFraction: 1, blendDuration: 1), value: started)
    }
}

#Preview {
    ContentView()
}
