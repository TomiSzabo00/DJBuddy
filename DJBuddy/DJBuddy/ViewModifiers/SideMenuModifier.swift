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
    let userType: UserTypeEnum

    let signOutAction: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            SideMenu(isShowing: $isShowing, navigator: navigator, userType: userType, signOutAction: signOutAction)
        }
    }
}

extension View {
    func sideMenu(isShowing: Binding<Bool>, navigator: Navigator, userType: UserTypeEnum, signOutAction: @escaping () -> Void) -> some View {
        modifier(SideMenuModifier(isShowing: isShowing, navigator: navigator, userType: userType, signOutAction: signOutAction))
    }
}
