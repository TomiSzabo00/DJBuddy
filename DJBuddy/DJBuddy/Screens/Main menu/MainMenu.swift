//
//  DJMainMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI

struct MainMenu: View {
    @EnvironmentObject private var navigator: Navigator
    @State var menu = false
    let userType: UserTypeEnum = .user

    var body: some View {
        HomeTabView(userType: userType, navigator: navigator)
            .sideMenu(isShowing: $menu, navigator: navigator)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    MenuButton(isShowing: $menu) {

                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Hi, DJ") {
                        navigator.show(ProfileView.self)
                    }
                    .tint(.red)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        MainMenu()
    }
}
