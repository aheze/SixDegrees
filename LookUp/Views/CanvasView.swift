//
//  CanvasView.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/21/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var graphViewModel: GraphViewModel
    
    var body: some View {
        GraphViewControllerRepresentable(graphViewModel: graphViewModel)
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
    }
}
