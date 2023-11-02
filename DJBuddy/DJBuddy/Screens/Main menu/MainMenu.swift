//
//  DJMainMenu.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 08/10/2023.
//

import SwiftUI
import Combine
import CoreLocation

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
                UserHomeView(viewModel: viewModel).tag(0)
                    .onAppear {
                        // Create a custom publisher that starts with an initial value (0)
                        let initialPublisher = Just(CLLocationCoordinate2D())

                        // Create a custom publisher that uses the throttle operator
                        let throttledPublisher = mapViewModel.$currentLocation
                            .compactMap { $0 }
                            .merge(with: initialPublisher)
                            .throttle(for: .seconds(600), scheduler: RunLoop.main, latest: true)

                        // Subscribe to the custom publisher
                        self.cancellable = throttledPublisher
                            .sink { newValue in
                                viewModel.fetchNearEvents(to: newValue, for: user)
                            }
                    }
            }

            MapView(viewModel: mapViewModel).tag(1)
        }
        .onAppear {
            mapViewModel.checkLocationServices()
            mapViewModel.getLocation()

            if viewModel.yourEvents.isEmpty {
                viewModel.fetchEvents(for: user)
            } else {
                viewModel.fetchEventsQuietly(for: user)
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
