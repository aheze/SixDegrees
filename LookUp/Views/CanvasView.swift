//
//  CanvasView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/21/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var model: ViewModel
    @EnvironmentObject var graphViewModel: GraphViewModel
    @EnvironmentObject var multipeerViewModel: MultipeerViewModel

    @State var started = false
    @State var started2 = false
    @State var started3 = false
    @State var started4 = false

    @State var loadingGraph = false
    @State var showingGraph = false

    @State var showingAll = true

    var body: some View {
        GraphViewControllerRepresentable(model: model, graphViewModel: graphViewModel)
            .opacity(showingGraph ? 1 : 0)
            .scaleEffect(showingGraph ? 1 : 0.5)
            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 1).delay(0.4), value: showingGraph)
            .overlay {
                VStack(spacing: 20) {
                    if showingAll {
                        VStack {
                            if started4 {
                                Button {
                                    model.showingStartup = true
                                } label: {
                                    Text("Add Connections")
                                        .font(.title)
                                        .foregroundColor(Color.purple)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .contentShape(Rectangle())
                                }
                                .transition(.scale(scale: 0.1).combined(with: .opacity))
                                .opacity(loadingGraph ? 0 : 1)
                                .overlay {
                                    ProgressView()
                                        .tint(.purple)
                                        .opacity(loadingGraph ? 1 : 0)
                                }
                                .animation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1), value: loadingGraph)
                            }

                            LineShape()
                                .trim(from: 0, to: started3 ? 1 : 0)
                                .stroke(
                                    Color.primary.opacity(0.5),
                                    style: .init(
                                        lineWidth: 2,
                                        lineCap: .round,
                                        lineJoin: .round,
                                        dash: [6],
                                        dashPhase: 6
                                    )
                                )
                                .frame(width: 2)
                                .animation(.spring(response: 2.3, dampingFraction: 0.5, blendDuration: 1), value: started3)
                                .frame(height: started2 ? 160 : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }

                    VStack(spacing: 16) {
                        Circle()
                            .fill(.purple)
                            .frame(width: 120, height: 120)
                            .overlay {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 60, weight: .medium))
                            }

                        if showingAll {
                            Text("You")
                                .foregroundColor(.purple)
                        }
                    }
                    .scaleEffect(started ? 1 : 0.1)
                    .opacity(started ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .scaleEffect(showingGraph ? 0.1 : 1)
                .opacity(showingGraph ? 0 : 1)
                .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1), value: started)
                .animation(.spring(response: 0.8, dampingFraction: 0.9, blendDuration: 1), value: started2)
                .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1), value: started4)
                .animation(.spring(response: 0.9, dampingFraction: 1, blendDuration: 1), value: showingAll)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 1), value: showingGraph)
            }
            .background {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFFE900),
                        Color(hex: 0xFF8600),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .opacity(0.1)
                .overlay {
                    ConnectionView()
                }
            }
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    started = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    started2 = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    started3 = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                    started4 = true
                }
            }
            .onChange(of: model.finishedOnboarding) { newValue in
                if newValue {
                    loadingGraph = true

                    Task {
                        do {
                            let graph = try await Networking.getGraph(phoneNumber: model.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines), targetDepth: 2)

                            print("got graph!")

                            graphViewModel.graph = graph

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                showingAll = false

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    showingGraph = true
                                }
                            }

                        } catch {
                            print("error: \(error)")
                        }
                    }

                    multipeerViewModel.startup(phoneNumber: model.phoneNumber)
                }
            }
    }
}
