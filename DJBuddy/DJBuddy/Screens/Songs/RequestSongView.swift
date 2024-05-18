//
//  RequestSongView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct RequestSongView: View {
    @EnvironmentObject private var stateHelper: StateHelper
    @EnvironmentObject var user: UserData
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var viewModel: EventControlViewModel

    @State var isSongSelectionShowing = false
    @State var error: Error? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let theme = viewModel.event.theme {
                InfoView("The DJ has set the theme to \(theme.displayName.uppercased()) for this event. You can only request songs from this category at the moment.", type: .info)
            } else if viewModel.event.playlistId != nil {
                InfoView("The DJ has set a custom playlist for this event. You can only request songs that are listed there.", type: .info)
            }

            Text("Choose a song:")
            songSelectionButton()

            Text("Set a price")
            PriceSelectionView(amounts: [1, 3, 5], selectedAmount: $viewModel.selectedPrice)

            Spacer()

            Button("I agree to the [Terms and Conditions](https://en.wikipedia.org/wiki/Terms_of_service) and understand that by pressing this button i will be charged.") {

            }
            .buttonStyle(.checkmark(isOn: $viewModel.didAgree))

            Button("Request") {
                viewModel.requestSong(by: user) { result in
                    switch result {
                    case .success(_):
                        navigator.back()
                    case .failure(let error):
                        self.error = error
                    }
                }
            }
            .buttonStyle(.largeProminent)
        }
        .foregroundStyle(.white)
        .padding()
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: "Request a song", navigator: navigator, leadingButton: .back)
        .sheet(isPresented: $isSongSelectionShowing) {
            if let playlist = viewModel.currentPlaylist {
                SongSelectionFromPlaylistView(isShowing: $isSongSelectionShowing, playlist: playlist) { selectedSong in
                    viewModel.selectedSong = selectedSong
                }
            } else {
                SongSelectionView(isShowing: $isSongSelectionShowing, theme: viewModel.event.theme) { selectedSong in
                    viewModel.selectedSong = selectedSong
                }
            }
        }
        .onAppear {
            stateHelper.performWithProgress {
                if viewModel.event.playlistId == nil {
                    try await viewModel.getCurrentTheme()
                } else {
                    try await viewModel.getCurrentPlaylist()
                }
            }
            viewModel.initWebSocketForEventThemeChanges()
        }
        .onDisappear {
            viewModel.closeWebSockets()
        }
    }

    @ViewBuilder private func agreePrivacyPolicy(_ checkbox: Binding<Bool>) -> some View {
        HStack {
            Toggle("Title", isOn: checkbox)
        }
    }

    @ViewBuilder private func songSelectionButton() -> some View {
        ZStack(alignment: .leading) {
            if let song = viewModel.selectedSong {
                SimpleSongRow(song: song)
            } else {
                HStack {
                    Image(systemName: "magnifyingglass")
                    if viewModel.currentPlaylist != nil {
                        Text("Choose song from the playlist...")
                    } else {
                        Text("Search by artist or title...")
                    }
                }
                .padding(.horizontal)
            }
        }
        .fontWeight(.semibold)
        .foregroundStyle(.gray)
        .frame(maxWidth: .infinity, maxHeight: 66, alignment: .leading)
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture {
            isSongSelectionShowing.toggle()
        }
    }
}

#Preview {
    NavigationView {
        RequestSongView(viewModel: EventControlViewModel(event: EventData.PreviewData))
            .environmentObject(Navigator())
            .environmentObject(UserData.EmptyUser)
    }
}
