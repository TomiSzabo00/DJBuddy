//
//  DJMainMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI

struct MainMenu: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData
    @State var menu = false

    var body: some View {
        HomeTabView(userType: user.type, navigator: navigator)
            .navBarWithTitle(title: "", navigator: navigator, leadingButton: .menu, trailingButton: .profile(user.name.firstName))
    }
}

#Preview {
    NavigationView {
        MainMenu()
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
