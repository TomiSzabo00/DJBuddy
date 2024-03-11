//
//  PlaylistDetailsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 11/03/2024.
//

import SwiftUI

struct PlaylistDetailsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    let playList: Playlist
    @ObservedObject var viewModel: PlaylistViewModel = .init()

    @State private var isNewSongShowing = false

    var body: some View {
        VStack(spacing: 20) {
            List {
                Section {
                    ForEach(playList.songs) { song in
                        SimpleSongRow(song: song, height: 80)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .discardable {
                                viewModel.remove(song: song, from: playList)
                            }
                    }
                } header: {
                    Text("Songs in this playlist")
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            }
            .preferredColorScheme(.dark)
            .scrollContentBackground(.hidden)

            Button("Add new") {
                isNewSongShowing = true
            }
            .buttonStyle(.largeProminent)
            .padding(20)
        }
        .background(Color.asset.background)
        .navBarWithTitle(title: playList.title, navigator: navigator, leadingButton: .back, trailingButton: .add($isNewSongShowing))
        .onAppear {
            viewModel.getPlaylists(of: user)
        }
        .errorAlert(error: $viewModel.error)
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .sheet(isPresented: $isNewSongShowing) {
            SongSelectionView(isShowing: $isNewSongShowing) { selectedSong in
                viewModel.add(song: selectedSong, to: playList)
            }
        }
    }
}

#Preview {
    NavigationView {
        PlaylistDetailsView(playList: Playlist.PreviewData)
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
