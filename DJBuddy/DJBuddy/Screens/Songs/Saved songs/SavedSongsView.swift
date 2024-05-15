//
//  LikedSongsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 06/03/2024.
//

import SwiftUI

struct SavedSongsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = SavedSongsViewModel()
    @State private var isSongSelectionShowing = false

    var body: some View {
        VStack(spacing: 20) {
            List {
                Section {
                    ForEach(viewModel.likedSongs) { song in
                        SimpleSongRow(song: song, height: 80)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                            .discardable {
                                viewModel.dislike(song: song, by: user)
                            }
                    }
                } header: {
                    Text("Your liked songs")
                }
                .listStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            }
            .preferredColorScheme(.dark)
            .scrollContentBackground(.hidden)

            Button("Save a new song") {
                isSongSelectionShowing = true
            }
            .buttonStyle(.largeProminent)
            .padding(20)
        }
        .background(Color.asset.background)
        .navBarWithTitle(title: "Saved Songs", navigator: navigator, leadingButton: .back)
        .onAppear {
            viewModel.getLikedSongs(for: user)
        }
        .sheet(isPresented: $isSongSelectionShowing) {
            SongSelectionView(isShowing: $isSongSelectionShowing) { selectedSong in
                viewModel.like(song: selectedSong, by: user)
            }
        }
    }
}

#Preview {
    NavigationView {
        SavedSongsView()
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
