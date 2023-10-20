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
                InfoView(from: viewModel.event.state)
                
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
                Button("Remove theme") {
                    viewModel.setTheme(to: nil)
                }
                Button("Pause requests") {
                    viewModel.setState(to: .paused)
                }
                Button("Resume requests") {
                    viewModel.setState(to: .inProgress)
                }
                Button(role: .destructive) {
                    viewModel.setState(to: .ended)
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
