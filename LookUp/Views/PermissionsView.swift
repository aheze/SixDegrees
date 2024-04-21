//
//  PermissionsView.swift
//  LookUp
//  
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct PermissionsView: View {
    @EnvironmentObject var model: ViewModel
    @Binding var finishedPermissions: Bool
    var goNext: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("First, let's get\npermissions set up.")
                .font(.title2)
                .fontWeight(.medium)
                .opacity(0.5)
                .multilineTextAlignment(.center)

            let subtitle: String = {
                switch model.authorizationStatus {
                case .notDetermined:
                    return "Tap to grant permission"
                case .authorized:
                    return "Tap to grant permission"
                default:
                    return "Go to Settings"
                }
            }()

            PermissionView(
                title: "Contacts",
                subtitle: subtitle,
                image: "person.crop.circle",
                finished: finishedPermissions
            ) {
                if model.authorizationStatus == .authorized {
                    finishedPermissions = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        goNext()
                    }
                } else if model.authorizationStatus == .notDetermined {
                    model.requestAccess {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            finishedPermissions = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                goNext()
                            }
                        }
                    }
                } else {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
        }
        .offset(y: -20)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
}

struct PermissionView: View {
    var title: String
    var subtitle: String
    var image: String
    var finished: Bool
    var action: () -> Void

    @State var pressing = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Capsule(style: .circular)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0xBB56EF),
                                Color(hex: 0xA051F0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay {
                        Text("Success!")
                            .foregroundColor(.white)
                            .font(.title3)
                            .fontWeight(.medium)
                            .fixedSize()
                            .offset(x: -14)
                            .opacity(finished ? 1 : 0)
                    }
                    .frame(width: finished ? nil : 52, height: 52)
                    .overlay(alignment: .trailing) {
                        Circle()
                            .fill(finished ? Color.clear : Color.purple)
                            .frame(width: 52, height: 52)
                            .overlay {
                                VStack {
                                    if finished {
                                        Image(systemName: "checkmark")
                                            .transition(.scale(0.5).combined(with: .opacity))
                                    } else {
                                        Image(systemName: image)
                                            .transition(.scale(0.5).combined(with: .opacity))
                                    }
                                }
                                .foregroundColor(.white)
                                .font(.title2)
                                .fontWeight(.medium)
                                .compositingGroup()
                            }
                            .scaleEffect(finished ? 0.84 : 1)
                    }

                if !finished {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .fontWeight(.bold)

                        Text(subtitle)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 20)
                    .padding(.vertical, 4)
                    .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .trailing)))
                }
            }
            .foregroundColor(.primary)
            .padding(8)
            .background {
                Capsule(style: .circular)
                    .fill(
                        LinearGradient(
                            colors: [
                                .primary.opacity(0.05),
                                .primary.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .background {
                        Capsule()
                            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
                            .reverseMask(padding: 40) {
                                Capsule()
                            }
                    }
                    .overlay {
                        Capsule()
                            .stroke(Color.primary, lineWidth: 0.5)
                            .opacity(0.25)
                    }
            }
            .animation(.spring(response: 0.4, dampingFraction: 1, blendDuration: 1), value: finished)
            .opacity(pressing ? 0.75 : 1)
            .scaleEffect(pressing ? 0.92 : 1)
        }
        .buttonStyle(UnstyledButtonStyle())
        ._onButtonGesture { pressing in
            if pressing {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 1)) {
                    self.pressing = pressing
                }
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 1)) {
                    self.pressing = pressing
                }
            }
        } perform: {}
    }
}
