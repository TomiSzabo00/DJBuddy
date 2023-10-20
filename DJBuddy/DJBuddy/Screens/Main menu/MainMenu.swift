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

    @StateObject private var viewModel = MainMenuViewModel()
    @State var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            if user.type == .dj {
                DJHomeView(events: viewModel.yourEvents).tag(0)
            } else {
                UserHomeView().tag(0)
            }
            Text("Map").tag(1)
        }
        .onAppear {
            viewModel.fetchEvents(for: user)
        }
        .overlay(alignment: .bottom) {
            TabViewSelector(selected: $selectedTab, userType: user.type, navigator: navigator)
        }
        .ignoresSafeArea()
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
