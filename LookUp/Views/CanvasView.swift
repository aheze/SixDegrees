//
//  CanvasView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var model: ViewModel
    @EnvironmentObject var graphViewModel: GraphViewModel

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

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
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            GraphViewControllerRepresentable(graphViewModel: graphViewModel)
                .ignoresSafeArea()
        }
    }
}
