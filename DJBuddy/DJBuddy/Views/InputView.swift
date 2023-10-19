//
//  InputView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct PlaceholderTextField: View {
    let placeholder: String
    @Binding var text: String
    @State var showPlaceholder: Bool = true
    @State var isSecure: Bool = false
    let isPasswordField: Bool

    @FocusState private var inFocus: Bool

    var body: some View {
        Group {
            if !isPasswordField {
                TextField("", text: $text)
            } else {
                ZStack {
                    TextField("", text: $text)
                        .focused($inFocus)
                        .opacity(isSecure ? 0 : 1)
                    SecureField("", text: $text)
                        .focused($inFocus)
                        .opacity(isSecure ? 1 : 0)
                }
            }
        }
        .onAppear {
            showPlaceholder = text.isEmpty
        }
        .onChange(of: text) { (_, newValue) in
            showPlaceholder = newValue.isEmpty
        }
        .modifier(FloatingTextModifier(isShowing: $showPlaceholder, placeholder: placeholder, isSecure: $isSecure, isPassword: isPasswordField))
    }

    init(placeholder: String, text: Binding<String>, isPassword: Bool = false) {
        self.placeholder = placeholder
        _text = text
        isPasswordField = isPassword
    }
}

struct FloatingTextModifier: ViewModifier {
    @Binding var isShowing: Bool
    let placeholder: String
    @Binding var isSecure: Bool
    let isPassword: Bool

    @ViewBuilder
    private var backgroundView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        }
    }

    @ViewBuilder
    private var secureView: some View {
        if isPassword {
            Image(systemName: isSecure ? "eye.fill" : "eye.slash.fill")
                .padding(.trailing)
                .onTapGesture {
                    isSecure.toggle()
                }
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        if isShowing {
            ZStack(alignment: .leading) {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.gray)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            .background(placeholderView, alignment: .leading)
            .overlay(secureView, alignment: .trailing)
            .padding(.leading)
            .frame(height: 66)
            .background(backgroundView)
    }
}

struct InputView: View {
    @State var text: String = ""

    var body: some View {
        VStack {
            PlaceholderTextField(placeholder: "placeholder", text: $text)
            PlaceholderTextField(placeholder: "Passsword", text: $text, isPassword: true)
        }
    }
}

#Preview {
    ZStack {
        WavyBackgroundView(height: 800, userType: .user)
        InputView()
    }
}
