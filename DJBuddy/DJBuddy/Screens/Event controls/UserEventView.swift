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
            SongList() {
                InfoView("Choose a song from the list or request a new one.", type: .info)
                if viewModel.event.state != .inProgress {
                    InfoView(from: viewModel.event.state)
                }
            }
            .environmentObject(navigator)
            .environmentObject(viewModel)

            Button("Request a new song") {
                navigator.navigate(to: .requestSong(viewModel.event))
            }
            .buttonStyle(.largeProminent)
            .padding(.horizontal)
            .disabled([.paused, .ended, .upcoming].contains(viewModel.event.state))
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: viewModel.event.name, navigator: navigator, leadingButton: .back)
        .onAppear {
            viewModel.initWebSocketForGeneralEventChanges()
        }
        .onDisappear {
            viewModel.closeWebSockets()
        }
    }

    init(event: EventData) {
        viewModel = .init(event: event)
    }
}

#Preview {
    UserEventView(event: EventData.PreviewData)
        .environmentObject(Navigator())
}
