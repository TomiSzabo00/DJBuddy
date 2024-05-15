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
            switch viewModel.authState {
            case .loggedIn:
                MainMenu(viewModel: mainMenuViewModel, signOutAction: viewModel.signOut)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        switch destination {
                        case let .requestSong(eventData):
                            RequestSongView(viewModel: EventControlViewModel(event: eventData))
                        case .profile:
                            ProfileView(user: viewModel.currentUser ?? UserData.EmptyUser)
                                .environmentObject(viewModel)
                        case .createEvent:
                            CreateEventView()
                        case let .selectEvent(eventList):
                            SelectEventView(yourEvents: eventList)
                        case let .eventControl(event):
                            EventControlView(event: event)
                        case let .userEventView(event):
                            UserEventView(event: event)
                        case let .songDetails(song, vm):
                            SongDetalsView(song: song, viewModel: vm)
                        case .balanceTopUp:
                            BalanceTopUpView()
                        case .joinEvent:
                            JoinEventView()
                        case let .eventDetails(event, isJoined):
                            EventDetailsView(event: event, isJoined: isJoined)
                        case .likedDjs:
                            LikedDJsView()
                        case .pastEvents:
                            PastEventsView()
                        case .savedSongs:
                            SavedSongsView()
                        case .playlists:
                            PlaylistsView()
                        case let .playlistDetails(playlist):
                            PlaylistDetailsView(playList: playlist)
                        }
                    }
            case .verifyEmail:
                VerifyEmailView()
                    .environmentObject(viewModel)
            case .loggedOut:
                LandingView()
                    .environmentObject(viewModel)
                    .onAppear {
                        viewModel.tryLoginFromStoredData(context: context)
                    }
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $viewModel.error)
        .animation(.default, value: viewModel.authState)
        .environmentObject(navigator)
        .environmentObject(viewModel.currentUser ?? UserData.EmptyUser)
        .tint(.accent)
    }
}

#Preview {
    StateManager()
}
