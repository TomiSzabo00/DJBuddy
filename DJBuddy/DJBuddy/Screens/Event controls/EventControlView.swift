//
//  EventControlView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct EventControlView: View {
    @EnvironmentObject var navigator: Navigator
    @ObservedObject var viewModel: EventControlViewModel

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                if [.paused, .upcoming].contains(viewModel.event.state) {
                    InfoView(from: viewModel.event.state)
                }
                if let theme = viewModel.event.theme {
                    InfoView("The current theme for this event is \(theme.displayName.uppercased())", type: .info)
                }
            }
            .padding()

            SongList(songs: viewModel.event.requestedSongs)
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: viewModel.event.name, navigator: navigator, leadingButton: .back, trailingButton: .options) {
            VStack {
                Button("Set theme") {
                    viewModel.setTheme(to: .slow)
                }
                Button("Remove theme") {}
                Button("Pause requests") {}
                Button("Resume requests") {}
                Button(role: .destructive) {

                } label: {
                    Text("End event")
                }

            }
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
    }
}
