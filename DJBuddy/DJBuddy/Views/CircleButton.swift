//
//  CircleButton.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct CircleButton<Content: View>: View {
    var radius: CGFloat = 50
    var background: Color = .white
    let action: () -> Void
    let label: () -> Content

    var body: some View {
        Button {
            action()
        } label: {
            Circle()
                .fill(background)
                .frame(width: radius)
                .overlay {
                    label()
                }
        }
    }
}

#Preview {
    CircleButton {

    } label: {
        Image(systemName: "music.note")
    }
}
