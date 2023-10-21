//
//  UserEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct UserEventView: View {
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var viewModel: EventControlViewModel

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                InfoView("Choose a song from the list or request a new one.", type: .info)

                InfoView(from: viewModel.event.state)
            }
            .padding()

            SongList(songs: viewModel.event.requestedSongs)
                .environmentObject(navigator)

            Button("Request a new song") {
                navigator.navigate(to: .requestSong(viewModel.event))
            }
            .buttonStyle(.largeProminent)
            .padding(.horizontal)
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: viewModel.event.name, navigator: navigator, leadingButton: .back)
    }
}

#Preview {
    UserEventView(viewModel: EventControlViewModel(event: EventData.PreviewData))
        .environmentObject(Navigator())
}