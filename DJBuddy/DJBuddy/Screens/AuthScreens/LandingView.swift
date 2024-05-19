//
//  LandingView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @EnvironmentObject private var stateHelper: StateHelper

    @State private var isFirstPublish = true

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
        .sheet(isPresented: $viewModel.isWebViewShowing) {
            NavigationStack {
                WebView(url: URL(string: "\(API.apiAddress)/login/\(viewModel.selectedSocialProvider.lowercased())")!) { authData in
                    stateHelper.performWithProgress {
                        try await viewModel.handleSocialAuthToken(token: authData.token, email: authData.email)
                    }
                }
                .navBarWithTitle(title: "Continue with \(viewModel.selectedSocialProvider)", leadingButton: .close($viewModel.isWebViewShowing))
            }
        }
        .onReceive(viewModel.$isWebViewShowing) { isShowing in
            guard !isShowing else { return }

            if !isFirstPublish && !viewModel.didSocialAuthSucceed {
                stateHelper.showError(from: APIError(message: "Authentication interrupted"))
            }
            isFirstPublish = false
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
                    PlaceholderTextField(placeholder: "Email", text: $viewModel.emailText)
                    PlaceholderTextField(placeholder: "Password", text: $viewModel.passwordText, isPassword: true)
                }
                .foregroundStyle(Color.black)

                Button("Sign In") {
                    stateHelper.performWithProgress {
                        try await viewModel.login()
                    }
                }
                .buttonStyle(.largeProminent)

                Button("Forgot password?") {
                    // TODO: Forgot pw
                }
                .buttonStyle(.underlined)

                HStack(spacing: 20) {
                    VStack {
                        Divider()
                            .background(.white)
                    }
                    Text("or")
                    VStack {
                        Divider()
                            .background(.white)
                    }
                }
                .foregroundStyle(.white)

                HStack {
                    Button("") {
                        viewModel.startSocialAuth(for: .google)
                    }
                    .buttonStyle(.social(for: .google, size: .compact))

                    Button("") {
                        viewModel.startSocialAuth(for: .facebook)
                    }
                    .buttonStyle(.social(for: .facebook, size: .compact))
                }
            }
            .padding(.bottom, 20)
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

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        if viewModel.userType == .dj {
                            PlaceholderTextField(placeholder: "Artist name", text: $viewModel.artistNameText)
                        }
                        PlaceholderTextField(placeholder: "First name", text: $viewModel.firstNameText)
                        PlaceholderTextField(placeholder: "Last name", text: $viewModel.lastNameText)
                        PlaceholderTextField(placeholder: "Email", text: $viewModel.emailText)
                        PlaceholderTextField(placeholder: "Password", text: $viewModel.passwordText, isPassword: true)
                        PlaceholderTextField(placeholder: "Confirm Password", text: $viewModel.passwordAgainText, isPassword: true)
                    }
                    .foregroundStyle(Color.black)

                    Button("Sign Up") {
                        stateHelper.performWithProgress {
                            try await viewModel.signUp()
                        }
                    }
                    .buttonStyle(.largeProminent)

                    HStack(spacing: 20) {
                        VStack {
                            Divider()
                                .background(.white)
                        }
                        Text("or")
                        VStack {
                            Divider()
                                .background(.white)
                        }
                    }
                    .foregroundStyle(.white)

                    Button("") {
                        viewModel.startSocialAuth(for: .google)
                    }
                    .buttonStyle(.social(for: .google))

                    Button("") {
                        viewModel.startSocialAuth(for: .facebook)
                    }
                    .buttonStyle(.social(for: .facebook))
                }
                .padding(.bottom, 20)
            }
            .frame(maxHeight: 400)
            .scrollIndicators(.hidden)
        }
        .alert("Verification needed", isPresented: $viewModel.isVerifyAlertShowing) {
            Button("OK", role: .cancel) {
                viewModel.authState = .verifyEmail
            }
        } message: {
            Text("You need to verify your email address to complete your registration.\nWe've sent an email with your code to \(viewModel.emailText)")
        }
        .padding()
        .foregroundStyle(Color.white)
        .edgesIgnoringSafeArea(.bottom)
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
        .environmentObject(AuthViewModel())
        .environmentObject(StateHelper() {})
}
