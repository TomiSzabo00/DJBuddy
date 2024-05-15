//
//  StateManager.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 28/10/2023.
//

import SwiftUI

struct StateManager: View {
    @StateObject private var viewModel: AuthViewModel
    @StateObject private var navigator: Navigator
    @StateObject private var mainMenuViewModel: MainMenuViewModel

    @Environment(\.modelContext) private var context

    @StateObject private var stateHelper: StateHelper
    @State private var isErrorAlertShowing = false

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
                        stateHelper.performWithProgress {
                            try await viewModel.tryLoginFromStoredData(context: context)
                        }
                    }
            }
        }
        .loadingOverlay(isLoading: $stateHelper.isLoading)
        .alert(stateHelper.alertContent?.title ?? "", isPresented: $isErrorAlertShowing) {
            Button("OK") {
                stateHelper.alertContent?.dismissAction()
            }
        } message: {
            Text(stateHelper.alertContent?.message ?? "")
        }
        .onReceive(stateHelper.$alertContent, perform: { content in
            if content != nil {
                UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = .dark
                isErrorAlertShowing = true
            }
        })
        .animation(.default, value: viewModel.authState)
        .environmentObject(navigator)
        .environmentObject(stateHelper)
        .environmentObject(viewModel.currentUser ?? UserData.EmptyUser)
        .tint(.accent)
    }

    init(viewModel: AuthViewModel = AuthViewModel(), navigator: Navigator = Navigator(), mainMenuViewModel: MainMenuViewModel = MainMenuViewModel()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigator = StateObject(wrappedValue: navigator)
        self._mainMenuViewModel = StateObject(wrappedValue: mainMenuViewModel)
        self._stateHelper = StateObject(wrappedValue: StateHelper(signoutAction: viewModel.signOut))
    }
}

#Preview {
    StateManager()
}
