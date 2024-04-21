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
            Text("6 Degrees")
                .fontWeight(.thin)
                .font(.title2)
                .padding(.top, 10)
            
            Spacer()

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

                    if model.finishedOnboarding {
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
                .animation(.spring(), value: model.finishedOnboarding)
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
            guard !model.isConnecting, multipeerViewModel.canAccept else {
                return
            }
            if let newValue {
                if newValue < 0.2 {
                    print("CONNECT!")
                    model.isConnecting = true

                    let h = UIImpactFeedbackGenerator(style: .soft)
                    h.impactOccurred()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        graphViewModel.recenter.send()
                    }

                    Task.detached {
                        do {
//                            let dest = "4244096978"
                            let source = await model.phoneNumber
                            let dest = await multipeerViewModel.connectedPeerPhoneNumber ?? ""

                            let timer = TimeElapsed()
                            let path = try await Networking.getPath(source: source, destination: dest)
                            print("dykstras: \(timer)")

                            try await Task.sleep(seconds: 2)

                            await { @MainActor in
                                model.connectedPath = path
                            }()

                            let analysis = try await Networking.getAnalysis(phoneNumber: dest)
                            print("analysis: \(timer)")

                            await { @MainActor in
                                let h = UIImpactFeedbackGenerator(style: .rigid)
                                h.impactOccurred()

                                if let analysis {
                                    model.stagingAnalysis = analysis
                                } else {
                                    model.stagingAnalysis = Analysis(phoneNumber: dest, name: "Analysis Loading", bio: "", hobbies: [])
                                }
                            }()

                            print("path? \(path)")
                        } catch {
                            print("Error path or analysis: \(error)")
                        }
                    }
                }
            }
        }
        .onReceive(model.pullAway) { analysis in
            print("Pulling away.")
            graphViewModel.addAdditionalAnalysis.send(analysis)

            multipeerViewModel.canAccept = false
            multipeerViewModel.stop()
            multipeerViewModel.distanceToPeer = nil
            multipeerViewModel.connectedPeerPhoneNumber = nil

            model.isConnecting = false
            model.connectedPath = nil
            withAnimation {
                model.showingConnections = false
            }
//            model.isConnecting = false
        }
        .onChange(of: multipeerViewModel.distanceToPeer) { distanceToPeer in
            if distanceToPeer != nil {
                graphViewModel.gravityStrength = -20
            } else {
                graphViewModel.gravityStrength = 0
            }
        }
//        .onAppear {
//            model.phoneNumber = "9252149133"
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                model.finishedOnboarding = true
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                    multipeerViewModel.distanceToPeer = 0.5
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                        multipeerViewModel.distanceToPeer = 0.3
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
//                            multipeerViewModel.distanceToPeer = 0.1
//                        }
//                    }
//                }
//            }
//        }
    }
}

#Preview {
    ContentView()
}

class TimeElapsed: CustomStringConvertible {
    private let startTime: CFAbsoluteTime
    private var endTime: CFAbsoluteTime?

    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    var description: String {
        time
    }

    var time: String {
        let format = String(format: "%.5f", duration)
        let string = "[\(format)s]"
        return string
    }

    var duration: Double {
        let endTime = CFAbsoluteTimeGetCurrent()
        return endTime - startTime
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
