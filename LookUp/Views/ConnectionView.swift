//
//  ConnectionView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct Wave: Identifiable {
    var id = UUID()
    var zIndex: Int
}

struct Connection {
    var phoneNumber: String
    var shown: Bool
}

struct ConnectionView: View {
    @EnvironmentObject var model: ViewModel
    @EnvironmentObject var multipeerViewModel: MultipeerViewModel
    
    @State var waves = [Wave]()
    @State var path = [Connection]()
    
    var body: some View {
        Color.clear
            .background {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: 2)
                        .overlay {
                            VStack {
                                ForEach(Array(zip(path.indices, path)), id: \.1.phoneNumber) { index, connection in
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 18, height: 18)
                                        .frame(maxHeight: .infinity)
                                        .scaleEffect(connection.shown ? 1 : 0.1)
                                        .opacity(connection.shown ? 1 : 0)
                                        .animation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1).delay(Double(path.count - index - 1) * 0.4), value: connection.shown)
                                }
                            }
                            .padding(.top, 50)
                            .padding(.bottom, 30)
                        }
                        .onChange(of: model.connectedPath) { newValue in
                            if let newValue {
                                path = newValue.map { Connection(phoneNumber: $0, shown: false) }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    for index in path.indices {
                                        path[index].shown = true
                                    }
                                }
                                
                            } else {
                                path = []
                            }
                        }
                        
                    Rectangle()
                        .frame(width: 8)
                        .opacity(0)
                }
                .ignoresSafeArea()
                .opacity(model.connectedPath != nil ? 1 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1), value: model.connectedPath)
            }
            .background {
                wavesView
                    .ignoresSafeArea()
                    .onChange(of: multipeerViewModel.distanceToPeer) { newValue in
                        
                        if let newValue {
                            animateWave()
                        }
                    }
            }
    }
    
    func animateWave() {
        guard !model.isConnecting else {
            withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1)) {
                waves = []
            }
            return
        }
        guard let distanceToPeer = multipeerViewModel.distanceToPeer else {
            return
        }
        
        let wave = Wave(zIndex: waves.count)
        
        let interval = CGFloat(distanceToPeer) * 2.3
        
        withAnimation(.spring(response: interval, dampingFraction: 1, blendDuration: 1)) {
            waves.append(wave)
        }
        
        print("interval: \(interval)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval * 2) {
            if let firstIndex = waves.firstIndex(where: { $0.id == wave.id }) {
                withAnimation(.spring(response: interval * 2, dampingFraction: 1, blendDuration: 1)) {
                    waves.remove(at: firstIndex)
                }
            }
            
            animateWave()
        }
    }
    
    var wavesView: some View {
        Color.clear.overlay(align: .top, to: .center) {
            ZStack {
                ForEach(waves) { wave in
                    Circle()
                        .fill(Color.yellow)
                        .blur(radius: 100)
                        .opacity(0.75)
                        .zIndex(Double(wave.zIndex))
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.1).combined(with: .opacity).combined(with: .offset(y: -200)),
                                removal: .scale(scale: 2.9).combined(with: .opacity).combined(with: .offset(y: 200))
                            )
                        )
                }
            }
            .frame(width: 400, height: 400)
        }
    }
}
