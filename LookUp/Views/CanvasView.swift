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

    @State var started = false
    @State var started2 = false
    @State var started3 = false
    @State var started4 = false

    var body: some View {
        GraphViewControllerRepresentable(model: model, graphViewModel: graphViewModel)
            .overlay {
                VStack(spacing: 20) {
                    if started4 {
                        Button {
                            model.showingStartup = true
                        } label: {
                            Text("Add Connections")
                                .font(.title)
                                .foregroundColor(Color.purple)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 2)
                                .contentShape(Rectangle())
                        }
                        .transition(.scale(scale: 0.1).combined(with: .opacity))
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

                    VStack(spacing: 16) {
                        Circle()
                            .fill(.purple)
                            .frame(width: 120, height: 120)
                            .overlay {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 60, weight: .medium))
                            }

                        Text("You")
                            .foregroundColor(.purple)
                    }
                    .scaleEffect(started ? 1 : 0.1)
                    .opacity(started ? 1 : 0)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 1), value: started)
                .animation(.spring(response: 0.8, dampingFraction: 0.9, blendDuration: 1), value: started2)
                .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1), value: started4)
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
    }
}
