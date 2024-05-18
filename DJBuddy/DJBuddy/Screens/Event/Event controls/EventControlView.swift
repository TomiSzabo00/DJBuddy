//
//  EventControlView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct EventControlView: View {
    @EnvironmentObject private var stateHelper: StateHelper
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
                        stateHelper.performWithProgress {
                            try await viewModel.setTheme(to: nil)
                            try await viewModel.setPlaylist(to: nil)
                        }
                    }
                }
                if viewModel.event.state == .inProgress {
                    Button("Pause requests") {
                        stateHelper.performWithProgress {
                            try await viewModel.setState(to: .paused)
                        }
                    }
                }
                if viewModel.event.pausedButNotEnded {
                    Button("Resume requests") {
                        stateHelper.performWithProgress {
                            try await viewModel.setState(to: .inProgress)
                        }
                    }
                }
                Button(role: .destructive) {
                    stateHelper.performWithProgress {
                        try await viewModel.setState(to: .ended)
                    }
                } label: {
                    Text("End event")
                }

            }
        }
        .sheet(isPresented: $isSongFiltersShowing) {
            NavigationView {
                SetThemeView(playlists: viewModel.availablePlaylists) { newTheme in
                    isSongFiltersShowing = false
                    
                    stateHelper.performWithProgress {
                        try await viewModel.setTheme(to: newTheme)
                        try await viewModel.setPlaylist(to: nil)
                    }
                } playlistSelection: { newPlaylist in
                    isSongFiltersShowing = false

                    stateHelper.performWithProgress {
                        try await viewModel.setTheme(to: nil)
                        try await viewModel.setPlaylist(to: newPlaylist)
                    }
                } cancel: {
                    isSongFiltersShowing = false
                }
            }
        }
        .onAppear {
            viewModel.initWebSocketForGeneralEventChanges()
            viewModel.initWebSocketForEventThemeChanges()
            stateHelper.performWithProgress {
                try await viewModel.getCurrentEvent()
            }
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
