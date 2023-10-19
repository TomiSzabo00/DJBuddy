//
//  TabViewSelector.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct TabViewSelector: View {
    @Binding var selected: Int
    let navigator: Navigator

    @Namespace private var animationNamespace

    let buttons: [(image: String, name: String)] = [
        ("house", "Home"),
        ("map", "Map"),
    ]

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(height: 70)

            ZStack {
                HStack {
                    IconButton(from: buttons[0], index: 0)
                    Spacer()
                    IconButton(from: buttons[1], index: 1)
                }

                CircleButton(radius: 90) {
                    navigator.show(CreateEventView.self)
                } label: {
                    Image(systemName: "music.note")
                        .font(.system(size: 48, weight: .medium))
                }
                .offset(y: -30)

            }
            .padding(.horizontal, 50)
        }
        .padding()
        .animation(.easeInOut, value: selected)
    }

    @ViewBuilder private func IconButton(from button: (image: String, name: String), index: Int) -> some View {
        Button {
            selected = index
        } label: {
            VStack(spacing: 4) {
                Spacer()
                Image(systemName: button.image)
                Text(button.name)

                if selected == index {
                    Capsule()
                        .frame(width: 60, height: 10)
                        .offset(y: 6)
                        .clipShape(Rectangle())
                        .foregroundStyle(Color.red)
                        .matchedGeometryEffect(id: "backgroundCircle", in: animationNamespace)
                } else {
                    Capsule()
                        .frame(width: 60, height: 10)
                        .offset(y: 6)
                        .clipShape(Rectangle())
                        .foregroundStyle(Color.clear)
                }
            }
            .frame(height: 70)
            .foregroundStyle(selected == index ? Color.accent : Color.gray)
        }
    }
}

#Preview {
    TabViewSelector(selected: .constant(0), navigator: Navigator())
}
