//
//  EventControlView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct EventControlView: View {
    @EnvironmentObject var navigator: Navigator
    let event: EventData

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Group {
                    if [.paused, .upcoming].contains(event.state) {
                        InfoView(from: event.state)
                    }
                    if let theme = event.theme {
                        InfoView("The current theme for this event is \(theme.displayName.uppercased())", type: .info)
                    }
                }
                .padding()
            }

            SongList(songs: event.requestedSongs)
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: event.name, navigator: navigator, leadingButton: .back, trailingButton: .options)
    }

    init(event: EventData) {
        self.event = event

        UINavigationBar.appearance().tintColor = .red
    }
}

#Preview {
    NavigationView {
        EventControlView(event: EventData.PreviewData)
            .environmentObject(Navigator())
    }
}
