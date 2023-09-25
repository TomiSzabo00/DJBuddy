//
//  LargeSecondaryButtonStyle.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct LargeSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.red)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.white : Color.gray)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension SwiftUI.ButtonStyle where Self == LargeSecondaryButtonStyle {
    static var largeSecondary: Self { Self() }
}

#Preview {
    Button("Some button") {}
        .buttonStyle(.largeSecondary)
        .padding()
}
