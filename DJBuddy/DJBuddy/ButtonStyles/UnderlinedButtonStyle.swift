//
//  UnderlinedButtonStyle.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 2023. 09. 25..
//

import SwiftUI

struct UnderlinedButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .underline()
            .foregroundColor(isEnabled ? Color.red : Color.gray)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension SwiftUI.ButtonStyle where Self == UnderlinedButtonStyle {
    static var underlined: Self { Self() }
}

#Preview {
    Button("Some button") {}
        .buttonStyle(.underlined)
        .padding()
}
