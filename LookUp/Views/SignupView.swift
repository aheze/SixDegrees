//
//  SignupView.swift
//  LookUp
//
//  Created by Andrew Zheng (github.com/aheze) on 4/20/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var model: ViewModel

    @State var phoneNumber = ""
    @State var name = ""
    @State var bio = ""
    @State var email = ""
    @State var instagram = ""

    @State var shown = false
    @State var animating = false
    @FocusState var focusedFirst
    
    @State var showingAlert = false

    var phone: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var n: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
                Text("Let's set up\nyour profile.")
                    .font(.title2)
                    .fontWeight(.medium)
                    .opacity(0.9)
                    .blendMode(.plusLighter)
                    .multilineTextAlignment(.center)
                    .opacity(shown ? 1 : 0)
                    .offset(y: shown ? 0 : 50)

                VStack(spacing: 20) {
                    SignupTextField(title: "Phone Number", image: "phone.fill", isRequired: true, text: $phoneNumber)
                        .focused($focusedFirst)

                    SignupTextField(title: "Your Name", image: "person.fill", isRequired: true, text: $name)
                    SignupTextField(
                        title: "Short Bio",
                        image: "info.bubble.fill",
                        isRequired: false,
                        multiline: true,
                        text: $bio
                    )
                    SignupTextField(title: "Email", image: "at", isRequired: false, text: $email)
                        .textInputAutocapitalization(.never)
                    
                    SignupTextField(title: "Insta", customImage: "InstaLogo", isRequired: false, text: $instagram)
                        .textInputAutocapitalization(.never)
                }

                Button {
                    guard !phone.isEmpty && !n.isEmpty else {
                        showingAlert = true
                        return
                    }
                    
                    let insta: String = {
                        var i = instagram.trimmingCharacters(in: .whitespaces)
                        if i.hasPrefix("https://") {
                            
                        } else if i.contains("instagram.com") {
                            i = "https://\(i)"
                        } else if i.hasPrefix("@") {
                            i = "https://instagram.com/\(String(i.dropFirst()))"
                        } else {
                            i = "https://instagram.com/\(i)"
                        }
                        
                        return i
                    }()
                    
                    Task {
                        try await Networking.uploadContactsDictionary(
                            ownPhoneNumber: phone,
                            ownName: n,
                            email: email,
                            bio: bio,
                            insta: insta,
                            contactsDictionary: model.contactsDictionary
                        )
                    }
                } label: {
                    Text("Continue")
                        .fontWeight(.medium)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background {
                            Capsule()
                                .fill(Color.white)
                                .opacity(0.2)
                        }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .animation(.spring(), value: shown)
        }
        .scrollDismissesKeyboard(.immediately)
        .alert("Name / phone number can't be empty!", isPresented: $showingAlert) {
            Button("Ok") {
                
            }
        }
        .background {
            Color.blue
                .overlay {
                    Circle()
                        .fill(.clear)
                        .frame(width: 500, height: 500)
                        .overlay(align: .topTrailing, to: .center) {
                            Circle()
                                .fill(Color.teal)
                                .frame(width: 250, height: 250)
                                .blur(radius: 100)
                        }
                        .overlay(align: .bottomLeading, to: .center) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 350, height: 350)
                                .blur(radius: 200)
                        }
                        .rotationEffect(.degrees(animating ? 360 : 0))
                }
                .ignoresSafeArea()
                .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: animating)
        }
        .onAppear {
            animating = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                shown = true

                focusedFirst = true
            }
        }
    }
}

struct SignupTextField: View {
    var title: String
    var image: String = ""
    var customImage: String? = nil
    var isRequired: Bool
    var multiline = false
    @Binding var text: String

    @FocusState var focused

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            .white,
                            .black,
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .opacity(0.1)
                .frame(width: 52, height: 52)
                .overlay {
                    if let customImage {
                        Image(customImage)
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: image)
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
                .background {
                    Circle()
                        .shadow(color: .white.opacity(0.25), radius: 12, x: 0, y: 16)
                        .reverseMask(padding: 40) {
                            Circle()
                        }
                }

            TextField("", text: $text,
                      prompt:
                      Text(title).foregroundColor(.white.opacity(1))
                          + Text(isRequired ? "" : " (Optional)").foregroundColor(.white.opacity(0.5)),
                      axis: multiline ? .vertical : .horizontal)
                .lineLimit(multiline ? 5 : 1)
                .padding(.vertical, 14)
                .focused($focused)
        }
        .padding(10)
        .background {
            Button {
                focused = true
            } label: {
                Capsule(style: .circular)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.15),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .buttonStyle(UnstyledButtonStyle())
        }
        .overlay {
            Capsule(style: .circular)
                .stroke(Color.white, lineWidth: 0.5)
        }
    }
}
