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

    @State var shown = false
    @State var animating = false
    @FocusState var focusedFirst

    @State var showingAlert = false
    @State var error: Error?
    @State var finished = false

    var dismissSelf: (() -> Void)?

    var phone: String {
        model.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var n: String {
        model.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        let errorPresented: Binding<Bool> = Binding {
            error != nil
        } set: { _ in
            error = nil
        }
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
                    SignupTextField(title: "Phone Number", image: "phone.fill", isRequired: true, text: $model.phoneNumber)
                        .focused($focusedFirst)

                    SignupTextField(title: "Your Name", image: "person.fill", isRequired: true, text: $model.name)
                    SignupTextField(
                        title: "Short Bio",
                        image: "info.bubble.fill",
                        isRequired: false,
                        multiline: true,
                        text: $model.bio
                    )
                    SignupTextField(title: "Email", image: "at", isRequired: false, text: $model.email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SignupTextField(title: "Insta", customImage: "InstaLogo", isRequired: false, text: $model.instagram)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Button {
                    guard !phone.isEmpty && !n.isEmpty else {
                        showingAlert = true
                        return
                    }

                    let insta: String = {
                        var i = model.instagram.trimmingCharacters(in: .whitespaces)
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
                        do {
                            try await Networking.uploadContactsDictionary(
                                ownPhoneNumber: phone,
                                ownName: n,
                                email: model.email.trimmingCharacters(in: .whitespacesAndNewlines),
                                bio: model.bio.trimmingCharacters(in: .whitespacesAndNewlines),
                                insta: insta,
                                contactsDictionary: model.contactsDictionary
                            )

                            finished = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                model.finishedOnboarding = true

                                dismissSelf?()
                            }

                        } catch {
                            print("Error uploading: \(error)")
                            self.error = error
                        }
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
            .opacity(finished ? 0 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1), value: finished)
            .overlay {
                CheckmarkShape()
                    .trim(from: 0, to: finished ? 1 : 0)
                    .stroke(Color.white, style: .init(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .frame(width: 86, height: 110)
                    .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 12)
                    .opacity(finished ? 1 : 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .animation(.spring(), value: shown)
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1), value: finished)
        }
        .scrollDismissesKeyboard(.immediately)
        .alert("Name / phone number can't be empty!", isPresented: $showingAlert) {
            Button("Ok") {}
        }
        .alert("Server Error", isPresented: errorPresented) {
            Button("Ok") {}
        } message: {
            if let error = self.error {
                Text("Error: \(error.localizedDescription)")
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
                .contentShape(Rectangle())
                .onTapGesture(count: 3) {
                    print("Tap!")
                    model.name = model.storedName
                    model.phoneNumber = model.storedPhoneNumber
                }
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

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.2))
            path.addLine(to: CGPoint(x: rect.midX - rect.width * 0.1, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
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
