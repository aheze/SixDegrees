//
//  Utilities+Toolbar.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct ToolbarCloseButtonModifier: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    var placement: ToolbarItemPlacement

    func body(content: Self.Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    ToolbarCloseButton {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
    }
}

struct ToolbarCloseButton: View {
    var action: (() -> Void)?
    var body: some View {
        Button {
            action?()
        } label: {
            Circle()
#if os(iOS)
                .fill(Color(uiColor: .quaternarySystemFill))
#endif
                .frame(width: 32)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary.opacity(0.5))
                )
        }
    }
}

extension View {
    func toolbarCloseButton(placement: ToolbarItemPlacement = .navigationBarTrailing) -> some View {
        self.modifier(ToolbarCloseButtonModifier(placement: placement))
    }
}
