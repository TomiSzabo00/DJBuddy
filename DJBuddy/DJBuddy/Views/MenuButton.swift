//
//  MenuButton.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct MenuButton: View {
    @Binding var isShowing: Bool
    let action: () -> Void

    var body: some View {
        Button {
            isShowing.toggle()
            action()
        } label: {
            Image(systemName: isShowing ? "multiply" : "line.3.horizontal")
        }
        .tint(.red)
    }
}

#Preview {
    MenuButton(isShowing: .constant(false)) {}
}
