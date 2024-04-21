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
    @StateObject var multipeerViewModel = MultipeerViewModel()

    @State var showingPermissions = false

    var body: some View {
        VStack {
            Spacer()

//            VStack {
//                Text("LookUp")
//                    .bold()
//
//                Text("Find connections between people.")
//
//                Button("Initiate Graph") {
//                    showingPermissions = true
//                }
//                .buttonBorderShape(.capsule)
//                .buttonStyle(.borderedProminent)
//
//                Button("Get Graph") {
//                    Task {
//                        do {
//                            let graph = try await Networking.getGraph(phoneNumber: "9252149133", targetDepth: 2)
//
//                            print("got graph!")
//
//                            graphViewModel.graph = graph
//
//                        } catch {
//                            print("error: \(error)")
//                        }
//                    }
//                }
//                .buttonBorderShape(.capsule)
//                .buttonStyle(.borderedProminent)
//            }

            if let stagingAnalysis = model.stagingAnalysis {
                let degreeOfSeparation: Int? = {
                    if let connectedPath = model.connectedPath {
                        return connectedPath.count - 1
                    }

                    return nil
                }()

                AnalysisView(degreeOfSeparation: degreeOfSeparation, analysis: stagingAnalysis)
            } else {
                HStack {
                    if
                        let connectedPeerPhoneNumber = multipeerViewModel.connectedPeerPhoneNumber,
                        let distanceToPeer = multipeerViewModel.distanceToPeer
                    {
                        Text("\(connectedPeerPhoneNumber) - \(distanceToPeer)")
                    }

                    Spacer()

                    if graphViewModel.graph != nil {
                        Button {
                            graphViewModel.recenter.send()
                        } label: {
                            Image(systemName: "house.fill")
                                .foregroundColor(.primary)
                                .opacity(0.75)
                                .font(.title3)
                                .frame(width: 50, height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.regularMaterial)
                                }
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 1), value: model.stagingAnalysis != nil)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            CanvasView()
        }
        .sheet(isPresented: $model.showingStartup) {
            StartupView()
                .presentationBackground {
                    Rectangle()
                        .fill(.regularMaterial)
                }
        }
        .environmentObject(model)
        .environmentObject(graphViewModel)
        .environmentObject(multipeerViewModel)
        .onChange(of: multipeerViewModel.distanceToPeer) { newValue in
            if let newValue {
                if newValue < 0.2 {
                    print("CONNECT!")
                    model.isConnecting = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        graphViewModel.recenter.send()
                    }

                    Task {
                        do {
                            let dest = "4244096978"

                            let path = try await Networking.getPath(source: "9252149133", destination: dest)

                            model.connectedPath = path

                            let analysis = try await Networking.getAnalysis(phoneNumber: dest)

                            if let analysis {
                                model.stagingAnalysis = analysis
                            } else {
                                model.stagingAnalysis = Analysis(phoneNumber: dest, name: "Analysis Loading", bio: "", hobbies: [])
                            }

                            print("path? \(path)")
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
            }
        }
        .onReceive(model.pullAway) { analysis in
            model.connectedPath = nil
            graphViewModel.addAdditionalAnalysis.send(analysis)
            multipeerViewModel.stop()
            multipeerViewModel.distanceToPeer = nil
            multipeerViewModel.connectedPeerPhoneNumber = nil
        }
        .onChange(of: multipeerViewModel.distanceToPeer) { distanceToPeer in
            if distanceToPeer != nil {
                graphViewModel.gravityStrength = -20
            } else {
                graphViewModel.gravityStrength = 0
            }
        }
        .onAppear {
            model.phoneNumber = "9252149133"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                model.finishedOnboarding = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    multipeerViewModel.distanceToPeer = 0.5

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        multipeerViewModel.distanceToPeer = 0.3

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                            multipeerViewModel.distanceToPeer = 0.1
                        }
                    }
                }
            }
//            Task {
//                do {
//                    let analysis = try await Networking.getAnalysis(phoneNumber: "3234")
//                } catch {
//                    print("Error: \(error)")
//                }
//            }

//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                graphViewModel.gravityStrength = -20
//
//                multipeerViewModel.distanceToPeer = 0.5
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                    multipeerViewModel.distanceToPeer = 0.3
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
//                        multipeerViewModel.distanceToPeer = 0.1
//                    }
//                }
//            }
        }
    }
}

#Preview {
    ContentView()
}

//            VStack {
//                Text("Debug!")
//
//                ScrollView {
//                    GraphDebugView(
//                        graph: DummyData.generateGraph(
//                            phoneNumber: model.ownPhoneNumber,
//                            targetDepth: 3
//                        )
//                    )
//                }
//                .frame(height: 250)
//
//                if let selectedPhoneNumber = graphViewModel.selectedPhoneNumber {
//                    Text("Selected: \(selectedPhoneNumber)")
//                }
//
//                if let tappedPhoneNumber = graphViewModel.tappedPhoneNumber {
//                    Text("Tapped: \(tappedPhoneNumber)")
//                }
//            }
//            .foregroundColor(.white)
//            .font(.caption2)
//            .padding()
//            .background {
//                RoundedRectangle(cornerRadius: 36)
//                    .fill(.regularMaterial)
//                    .environment(\.colorScheme, .dark)
//            }
