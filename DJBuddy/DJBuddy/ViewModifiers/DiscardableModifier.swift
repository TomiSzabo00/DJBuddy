//
//  DiscardableModifier.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/03/2024.
//

import SwiftUI

struct DiscardableModifier: ViewModifier {
    let alignment: Alignment
    let discardAction: () -> Void

    func body(content: Content) -> some View {
        ZStack(alignment: alignment) {
            content
            Button {
                discardAction()
            } label: {
                Image(systemName: "multiply.circle.fill")
                    .foregroundStyle(.ultraThinMaterial)
                    .font(.title2)
            }
            .padding(20)
        }
    }
}

extension View {
    func discardable(alignment: Alignment = .trailing, discardAction: @escaping () -> Void) -> some View {
        modifier(DiscardableModifier(alignment: alignment, discardAction: discardAction))
    }
}
