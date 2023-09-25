//
//  LandingView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                WavyBackgroundView(height: geo.size.height / 1.5)
                    .foregroundStyle(Color.red.secondary)

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
                            // TODO: Sign in
                        }
                        .buttonStyle(.largeProminent)

                        Button("Sign Up") {
                            // TODO: Sign up
                        }
                        .buttonStyle(.largeSecondary)
                    }
                }
                .padding(.top, 20)
                .padding()
                .foregroundStyle(Color.white)
            }
            .background(Color.black)
        }
    }
}

#Preview {
    LandingView()
}
