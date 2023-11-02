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

    @StateObject var viewModel: MainMenuViewModel
    @State var selectedTab = 0

    let signOutAction: () -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            if user.type == .dj {
                DJHomeView(viewModel: viewModel).tag(0)
            } else {
                UserHomeView(viewModel: viewModel).tag(0)
            }

            MapView().tag(1)
        }
        .onAppear {
            if viewModel.yourEvents.isEmpty {
                viewModel.fetchEvents(for: user)
            }
        }
        .overlay(alignment: .bottom) {
            TabViewSelector(selected: $selectedTab) {
                if user.type == .dj {
                    navigator.navigate(to: .createEvent)
                } else if user.type == .user {
                    navigator.navigate(to: .selectEvent(viewModel.yourEvents[.yourEvents] ?? []))
                }
            }
        }
        .ignoresSafeArea()
        .navBarWithTitle(title: "", navigator: navigator, leadingButton: .menu(signOutAction), trailingButton: .profile(user.firstName))
        .loadingOverlay(isLoading: $viewModel.isLoading)
    }
}

#Preview {
    NavigationView {
        MainMenu(viewModel: MainMenuViewModel()) {}
            .environmentObject(Navigator())
            .environmentObject(UserData.EmptyUser)
    }
}
