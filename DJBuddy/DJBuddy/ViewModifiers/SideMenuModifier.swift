//
//  SideMenuModifier.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct SideMenuModifier: ViewModifier {
    @Binding var isShowing: Bool
    let navigator: Navigator

    let signOutAction: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            SideMenu(isShowing: $isShowing, navigator: navigator, signOutAction: signOutAction)
        }
    }
}

extension View {
    func sideMenu(isShowing: Binding<Bool>, navigator: Navigator, signOutAction: @escaping () -> Void) -> some View {
        modifier(SideMenuModifier(isShowing: isShowing, navigator: navigator, signOutAction: signOutAction))
    }
}
