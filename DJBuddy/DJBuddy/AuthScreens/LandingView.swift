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
                WavyBackgroundView(height: viewModel.pageState == .landingPage ? geo.size.height / 1.5 : geo.size.height - 30, userType: viewModel.userType)
                    .foregroundStyle(Color.red.secondary)

                switch viewModel.pageState {
                case .landingPage:
                    landingContent
                case .signIn:
                    signInContent
                case .signUp:
                    signUpContent
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
                    viewModel.login()
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

    @ViewBuilder private var signUpContent: some View {
        VStack(alignment: .leading) {
            Button {
                viewModel.navigate(to: .landingPage)
            } label: {
                Label("Back", systemImage: "arrow.left")
            }
            .padding(.vertical)

            Picker("User type", selection: $viewModel.userType) {
                ForEach(UserTypeEnum.allCases) { type in
                    Text(type.displayString).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Group {
                    PlaceholderTextField(placeholder: "Username", text: $viewModel.usernameText)
                    PlaceholderTextField(placeholder: "Password", text: $viewModel.passwordText, isPassword: true)
                    PlaceholderTextField(placeholder: "Confirm Password", text: $viewModel.passwordAgainText, isPassword: true)
                }
                .foregroundStyle(Color.black)

                Button("Sign Up") {
                    viewModel.signUp()
                }
                .buttonStyle(.largeProminent)
            }
            .padding(.bottom, 50)
        }
        .padding()
        .foregroundStyle(Color.white)
    }

    init() {
    // Sets the background color of the Picker
       UISegmentedControl.appearance().backgroundColor = .red.withAlphaComponent(0.3)
    // Disappears the divider
       UISegmentedControl.appearance().setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    // Changes the color for the selected item
       UISegmentedControl.appearance().selectedSegmentTintColor = .white
    // Changes the text color for the selected item
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.red], for: .normal)
    }
}

#Preview {
    LandingView()
}
