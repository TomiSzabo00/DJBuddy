//
//  StateManager.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 28/10/2023.
//

import SwiftUI

struct StateManager: View {
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var navigator = Navigator()
    @StateObject private var mainMenuViewModel = MainMenuViewModel()

    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack(path: $navigator.path) {
            if viewModel.currentUser != nil {
                MainMenu(viewModel: mainMenuViewModel)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case let .requestSong(eventData):
                            RequestSongView(viewModel: EventControlViewModel(event: eventData))
                        case .profile:
                            ProfileView()
                        case .createEvent:
                            CreateEventView() { newEvent in
                                mainMenuViewModel.join(event: newEvent)
                            }
                        case let .selectEvent(eventList):
                            SelectEventView(yourEvents: eventList)
                        case let .eventControl(event):
                            EventControlView(event: event)
                        case let .userEventView(event):
                            UserEventView(event: event)
                        case let .songDetails(song, vm):
                            SongDetalsView(song: song, viewModel: vm)
                        }
                    }
            } else {
                LandingView()
                    .environmentObject(viewModel)
                    .onAppear {
                        viewModel.fetchStoredUser(context: context)
                    }
            }
        }
        .animation(.default, value: viewModel.currentUser)
        .environmentObject(navigator)
        .environmentObject(viewModel.currentUser ?? UserData.EmptyUser)
        .tint(.accent)
    }
}

#Preview {
    StateManager()
}
