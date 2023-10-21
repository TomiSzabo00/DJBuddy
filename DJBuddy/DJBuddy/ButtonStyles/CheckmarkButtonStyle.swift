//
//  CheckmarkButtonStyle.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct CheckboxButtonStyle: ButtonStyle {
    @Binding var isOn: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 20) {
            Button {
                isOn.toggle()
            } label: {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
            }
            .foregroundStyle(.accent)

            configuration.label
        }
        .onTapGesture {
            isOn.toggle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension SwiftUI.ButtonStyle where Self == CheckboxButtonStyle {
    static func checkmark(isOn: Binding<Bool>) -> Self { Self(isOn: isOn) }
}
