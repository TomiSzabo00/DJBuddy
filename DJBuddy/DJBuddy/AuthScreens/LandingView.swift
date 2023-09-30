//
//  LandingView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct LandingView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                WavyBackgroundView(height: viewModel.pageState == .landingPage ? geo.size.height / 1.5 : geo.size.height)
                    .foregroundStyle(Color.red.secondary)

                switch viewModel.pageState {
                case .landingPage:
                    landingContent
                case .signIn:
                    signInContent
                case .signUp:
                    EmptyView()
                }
            }
            .background(Color.black)
            .animation(.interpolatingSpring(stiffness: 110, damping: 10), value: viewModel.pageState)
        }
    }

    @ViewBuilder private var landingContent: some View {
        VStack(alignment: .leading) {
            Text("Welcome\nto")
                .font(.system(size: 36, weight: .bold))
                .textCase(.uppercase)
            Text("DJ Buddy")
                .font(.system(size: 64, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(Color.red)

            Spacer()

            VStack(spacing: 20) {
                Button("Sign In") {
                    viewModel.navigate(to: .signIn)
                }
                .buttonStyle(.largeProminent)

                Button("Sign Up") {
                    viewModel.navigate(to: .signUp)
                }
                .buttonStyle(.largeSecondary)
            }
        }
        .padding(.top, 20)
        .padding()
        .foregroundStyle(Color.white)
    }

    @ViewBuilder private var signInContent: some View {
        VStack(alignment: .leading) {
            Button {
                viewModel.navigate(to: .landingPage)
            } label: {
                Label("Back", systemImage: "arrow.left")
            }
            .padding(.vertical)

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Group {
                    PlaceholderTextField(placeholder: "Username", text: $viewModel.usernameText)
                    PlaceholderTextField(placeholder: "Password", text: $viewModel.passwordText, isPassword: true)
                }
                .foregroundStyle(Color.black)

                Button("Sign In") {
                    // TODO: Sign in
                }
                .buttonStyle(.largeProminent)

                Button("Forgot password?") {
                    // TODO: Forgot pw
                }
                .buttonStyle(.underlined)
            }
            .padding(.bottom, 50)
        }
        .padding()
        .foregroundStyle(Color.white)
    }
}

#Preview {
    LandingView()
}
