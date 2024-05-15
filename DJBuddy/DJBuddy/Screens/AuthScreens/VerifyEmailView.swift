//
//  VerifyEmailView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 12/05/2024.
//

import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject private var viewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            InfoView("If you can't find the email in your inbox, check your spam folder aswell.")
            Text("Please insert your verification code here:")
            PlaceholderTextField(placeholder: "Verification code", text: $viewModel.verificationCode)

            Spacer()

            Button("Verify") {
                viewModel.verifyEmail()
            }
            .buttonStyle(.largeProminent)
        }
        .padding()
        .foregroundStyle(.white)
        .backgroundColor(.background)
        .navBarWithTitle(title: "Verify email")
    }
}

#Preview {
    NavigationView {
        VerifyEmailView()
            .environmentObject(AuthViewModel())
    }
}
