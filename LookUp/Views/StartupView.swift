//
//  StartupView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/19/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

enum PageType {
    case signup
}

struct StartupView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var model: ViewModel
    @State var finishedPermissions = false

    @State var path = NavigationPath()
    @State var selectedDetent = PresentationDetent.medium

    var body: some View {
        NavigationStack(path: $path) {
            PermissionsView(finishedPermissions: $finishedPermissions) {
                withAnimation {
                    selectedDetent = .large
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    path.append(PageType.signup)
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbarCloseButton()
            .onChange(of: finishedPermissions) { newValue in
                if newValue {
                    model.getContacts()
                }
            }
            .navigationDestination(for: PageType.self) { pageType in
                switch pageType {
                case .signup:
                    SignupView {
                        dismiss()
                    }
                }
            }
        }
        .tint(.white)
        .presentationDetents([.medium, .large], selection: $selectedDetent)
    }
}



struct UnstyledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
