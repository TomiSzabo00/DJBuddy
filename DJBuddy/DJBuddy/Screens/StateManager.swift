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
    @StateObject private var exampleUser = UserData(username: "exampleUser",
                                                    email: "example@email.com",
                                                    firstName: "Example",
                                                    lastName: "User",
                                                    type: .user)
    @StateObject private var mainMenuViewModel = MainMenuViewModel()

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
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                            self.viewModel.currentUser = exampleUser
                        }
                    }
            }
        }
        .environmentObject(navigator)
        .environmentObject(viewModel.currentUser ?? UserData.EmptyUser)
        .tint(.accent)
    }
}

#Preview {
    StateManager()
}
