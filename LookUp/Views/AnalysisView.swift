//
//  AnalysisView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/21/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject var model: ViewModel
    
    var degreeOfSeparation: Int?
    var analysis: Analysis
    
    @State var showingSeparation = true
    @State var showingText = false
    @State var showingTextActual = false
    
    var body: some View {
        VStack(alignment: showingSeparation ? .center : .leading, spacing: 16) {
            HStack {
                VStack {
                    if let degreeOfSeparation {
                        HStack(spacing: 0) {
                            Text("\(degreeOfSeparation)")
                            
                            if !showingSeparation {
                                Text(" degrees of separation")
                            }
                        }
                        .font(.system(size: showingSeparation ? 120 : 24, weight: .bold))
                        .foregroundColor(.orange)
                        .compositingGroup()
                        .transformEffect(.identity)
                        .padding(.vertical, showingSeparation ? 40 : 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: showingSeparation ? .center : .leading)
                
                if showingText {
                    Button {
                        if degreeOfSeparation != nil {
                            model.pullAway.send(analysis)
                        }
                        
                        model.stagingAnalysis = nil
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(analysis.name)
                        .bold()
                    Text(analysis.phoneNumber)
                }
                    
                Text(analysis.bio)
                    
                OverflowLayout(spacing: 10) {
                    ForEach(analysis.hobbies, id: \.self) { hobby in
                        Text(hobby)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange)
                                    .opacity(0.2)
                            }
                    }
                }
            }
            .compositingGroup()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: showingText ? nil : 0, alignment: .top)
            .opacity(showingTextActual ? 1 : 0)
        }
        .compositingGroup()
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 16)
        }
        .frame(maxWidth: 600)
        .transition(.opacity.combined(with: .offset(y: 200)))
        .onAppear {
            if let degreeOfSeparation {
                showingSeparation = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                    withAnimation(.spring(response: 0.9, dampingFraction: 1, blendDuration: 1)) {
                        showingSeparation = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1)) {
                            showingText = true
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1)) {
                            showingTextActual = true
                        }
                    }
                }
            } else {
                showingSeparation = false
                showingText = true
                showingTextActual = true
            }
        }
    }
}

struct OverflowLayout: Layout {
    var spacing = CGFloat(10)
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, containerWidth: containerWidth).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }
    
    func layout(sizes: [CGSize], containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            result.append(currentPosition)
            currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
            currentPosition.x += spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return (result, CGSize(width: maxX, height: currentPosition.y + lineHeight))
    }
}
