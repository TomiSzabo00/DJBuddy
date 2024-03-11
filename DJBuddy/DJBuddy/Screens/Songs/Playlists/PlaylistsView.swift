//
//  PlaylistsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 07/03/2024.
//

import SwiftUI

struct PlaylistsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = PlaylistViewModel()
    @State private var isNewPlaylistShowing = false
    @State private var newPlaylistName = ""

    @State private var id = UUID()

    var body: some View {
        VStack(spacing: 20) {
            List {
                Section {
                    ForEach(viewModel.playlists) { playlist in
                        PlaylistRow(playlist: playlist)
                            .onTapGesture {
                                navigator.navigate(to: .playlistDetails(playlist))
                            }
                            .discardable {
                                viewModel.delete(playlist: playlist)
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
            viewModel.getPlaylists(of: user)
        }
        .errorAlert(error: $viewModel.error)
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .alert("Create new playlist", isPresented: $isNewPlaylistShowing) {
            TextField("Name", text: $newPlaylistName)
            Button("OK") {
                viewModel.createPlaylist(name: newPlaylistName, by: user)
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
