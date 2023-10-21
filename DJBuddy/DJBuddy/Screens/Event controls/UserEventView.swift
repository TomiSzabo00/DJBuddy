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
                InfoView(from: viewModel.event.state)

                if let theme = viewModel.event.theme {
                    InfoView("The current theme for this event is \(theme.displayName.uppercased())", type: .info)
                }
            }
            .padding()

            SongList(songs: viewModel.event.requestedSongs)
                .environmentObject(navigator)

            Button("Request a new song") {
                // TODO: request song view
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
