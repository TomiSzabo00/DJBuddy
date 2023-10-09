//
//  SideMenuModifier.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct SideMenuModifier: ViewModifier {
    @Binding var isShowing: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            SideMenu(isShowing: $isShowing)
        }
    }
}

extension View {
    func sideMenu(isShowing: Binding<Bool>) -> some View {
        modifier(SideMenuModifier(isShowing: isShowing))
    }
}
