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
                    Button("Hi, \(user.name.firstName)") {
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
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
