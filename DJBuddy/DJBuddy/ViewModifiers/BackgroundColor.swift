//
//  BackgroundColor.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI

struct BackgroundColor: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        ZStack {
            color.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func backgroundColor(_ color: Color) -> some View {
        modifier(BackgroundColor(color: color))
    }
}
