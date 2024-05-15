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

    private var remainingSongs: Int {
        Playlist.minimumCount - playList.songs.count
    }

    var body: some View {
        VStack(spacing: 20) {
            List {
                if !playList.hasEnoughSongs {
                    InfoView("This playlist doen't have enough songs to be used as a filter. Add \(remainingSongs) more.", type: .warning)
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }

                Section {
                    ForEach(playList.songs) { song in
                        SimpleSongRow(song: song, height: 80)
                            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .discardable {
                                viewModel.remove(song: song, from: playList)
                            }
                    }
                } header: {
                    HStack(spacing: 0) {
                        Text("Songs in this playlist")
                        Spacer()
                        Text("\(playList.songs.count)")
                        if playList.hasEnoughSongs {
                            Text(" songs")
                        } else {
                            Text("/\(Playlist.minimumCount)")
                        }
                    }
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
