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

struct ConnectionView: View {
    @EnvironmentObject var model: ViewModel
    @EnvironmentObject var multipeerViewModel: MultipeerViewModel
    
    @State var waves = [Wave]()
    
    var body: some View {
        wavesView
            .onChange(of: multipeerViewModel.distanceToPeer) { newValue in
                
                print("newValue: \(newValue)")
                if let newValue {
                    animateWave()
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
                        .opacity(0.4)
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
