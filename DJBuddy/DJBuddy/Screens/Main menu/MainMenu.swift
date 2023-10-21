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
                DJHomeView(yourEvents: viewModel.yourEvents[.yourEvents] ?? []).tag(0)
            } else {
                UserHomeView(events: viewModel.yourEvents, joinAction: viewModel.join(event:), leaveAction: viewModel.leave(event:)).tag(0)
            }
            Text("Map").tag(1)
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
        .navBarWithTitle(title: "", navigator: navigator, leadingButton: .menu, trailingButton: .profile(user.name.firstName))
        .loadingOverlay(isLoading: $viewModel.isLoading)
    }
}

#Preview {
    NavigationView {
        MainMenu()
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
