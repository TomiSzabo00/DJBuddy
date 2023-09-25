//
//  LandingView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            WavyBackgroundView(height: 550)
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

                Text("Button 1")
            }
            .padding()
            .foregroundStyle(Color.white)
        }
        .background(Color.black)
    }
}

#Preview {
    LandingView()
}
