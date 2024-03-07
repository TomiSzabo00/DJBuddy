//
//  DJMainMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI
import Combine

struct MainMenu: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject var viewModel: MainMenuViewModel
    @StateObject var mapViewModel = MapViewModel()
    @State var selectedTab = 0

    let signOutAction: () -> Void

    @State private var cancellable: AnyCancellable?

    var body: some View {
        TabView(selection: $selectedTab) {
            if user.type == .dj {
                DJHomeView(viewModel: viewModel).tag(0)
            } else {
                UserHomeView(viewModel: viewModel) { address in
                    // navigate to map
                    selectedTab = 1
                    // set map region to selected event
                    mapViewModel.region = mapViewModel.regionFrom(coordinates: address.coordinate)
                }
                .tag(0)
                .onAppear {
                    // Create a custom publisher that uses the throttle operator
                    let throttledPublisher = mapViewModel.$currentLocation
                        .compactMap { $0 }
                        .throttle(for: .seconds(600), scheduler: RunLoop.main, latest: true)

                    // Subscribe to the custom publisher
                    self.cancellable = throttledPublisher
                        .sink { newValue in
                            viewModel.currentLocation = newValue
                            viewModel.fetchNearEvents(for: user)
                        }
                }
            }

            MapView(viewModel: mapViewModel,
                    isLoading: $viewModel.isLoading,
                    annotationItems: (viewModel.yourEvents[.yourEvents] ?? []) + (viewModel.yourEvents[.nearYou] ?? [])
            ) {
                viewModel.fetchEvents(for: user)
                if let currentLocation = mapViewModel.currentLocation {
                    viewModel.currentLocation = currentLocation
                    viewModel.fetchNearEvents(for: user)
                }
            }
            .tag(1)
        }
        .onAppear {
            mapViewModel.checkLocationServices()
            mapViewModel.getLocation()

            if viewModel.yourEvents.isEmpty {
                viewModel.fetchEvents(for: user)
            } else {
                viewModel.fetchEvents(for: user, isQuiet: true)
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
        .navBarWithTitle(title: "", navigator: navigator, leadingButton: .menu(user.type, signOutAction), trailingButton: .profile(user.firstName))
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
