//
//  EventControlView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct EventControlView: View {
    @EnvironmentObject private var user: UserData
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var viewModel: EventControlViewModel

    @State var isSongFiltersShowing = false

    var body: some View {
        VStack {
            SongList() {
                InfoView(from: viewModel.event.state)

                if let theme = viewModel.event.theme {
                    InfoView("The current theme for this event is \(theme.displayName.uppercased())", type: .info)
                } else if let currentPlaylist = viewModel.currentPlaylist {
                    InfoView("You have set the playlist \"**\(currentPlaylist.title)**\" as a filter.", type: .info)
                }
            }
            .environmentObject(navigator)
            .environmentObject(viewModel)
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: viewModel.event.name, navigator: navigator, leadingButton: .back, trailingButton: .options) {
            VStack {
                Button("Add song filters") {
                    isSongFiltersShowing.toggle()
                }
                if viewModel.event.theme != nil || viewModel.event.playlistId != nil {
                    Button("Remove filter") {
                        viewModel.setTheme(to: nil)
                        viewModel.setPlaylist(to: nil)
                    }
                }
                if viewModel.event.state == .inProgress {
                    Button("Pause requests") {
                        viewModel.setState(to: .paused)
                    }
                }
                if viewModel.event.pausedButNotEnded {
                    Button("Resume requests") {
                        viewModel.setState(to: .inProgress)
                    }
                }
                Button(role: .destructive) {
                    viewModel.setState(to: .ended)
                } label: {
                    Text("End event")
                }

            }
        }
        .errorAlert(error: $viewModel.error)
        .sheet(isPresented: $isSongFiltersShowing) {
            NavigationView {
                SetThemeView(playlists: viewModel.availablePlaylists) { newTheme in
                    isSongFiltersShowing = false
                    
                    viewModel.setPlaylist(to: nil)
                    viewModel.setTheme(to: newTheme)
                } playlistSelection: { newPlaylist in
                    isSongFiltersShowing = false

                    viewModel.setTheme(to: nil)
                    viewModel.setPlaylist(to: newPlaylist)
                } cancel: {
                    isSongFiltersShowing = false
                }
                .errorAlert(error: $viewModel.error)
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .onAppear {
            viewModel.initWebSocketForGeneralEventChanges()
            viewModel.initWebSocketForEventThemeChanges()
            viewModel.getCurrentEvent()
            viewModel.getAvailablePlaylists(for: user)
        }
        .onDisappear {
            viewModel.closeWebSockets()
        }
    }

    init(event: EventData) {
        viewModel = .init(event: event)

        UINavigationBar.appearance().tintColor = .red
    }
}

#Preview {
    NavigationView {
        EventControlView(event: EventData.PreviewData)
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
