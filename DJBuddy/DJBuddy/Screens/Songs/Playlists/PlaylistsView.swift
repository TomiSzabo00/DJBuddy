//
//  PlaylistsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 07/03/2024.
//

import SwiftUI

struct PlaylistsView: View {
    @EnvironmentObject private var stateHelper: StateHelper
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = PlaylistViewModel()
    @State private var isNewPlaylistShowing = false
    @State private var newPlaylistName = ""

    @State private var id = UUID()

    var body: some View {
        VStack(spacing: 20) {
            List {
                InfoView("You can set a playlist as a filter on an event so users can only request songs from there.")
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                Section {
                    ForEach(viewModel.playlists) { playlist in
                        PlaylistRow(playlist: playlist)
                            .onTapGesture {
                                navigator.navigate(to: .playlistDetails(playlist))
                            }
                            .discardable {
                                stateHelper.performWithProgress {
                                    try await viewModel.delete(playlist: playlist)
                                }
                            }
                            .id("\(id)\(playlist.id)\(playlist.songs.count)")
                    }
                } header: {
                    Text("Your saved playlists")
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            }
            .preferredColorScheme(.dark)
            .scrollContentBackground(.hidden)

            Button("Create new") {
                isNewPlaylistShowing = true
            }
            .buttonStyle(.largeProminent)
            .padding(20)
        }
        .background(Color.asset.background)
        .navBarWithTitle(title: "Playlists", navigator: navigator, leadingButton: .back, trailingButton: .add($isNewPlaylistShowing))
        .onAppear {
            stateHelper.performWithProgress {
                try await viewModel.getPlaylists(of: user)
            }
        }
        .alert("Create new playlist", isPresented: $isNewPlaylistShowing) {
            TextField("Name", text: $newPlaylistName)
            Button("OK") {
                stateHelper.performWithProgress {
                    try await viewModel.createPlaylist(name: newPlaylistName, by: user)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Type in the name of your new playlist.")
        }
    }
}

#Preview {
    NavigationView {
        PlaylistsView()
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
