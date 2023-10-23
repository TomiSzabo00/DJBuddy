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

    @State var isSelectThemeShowing = false

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
                .environmentObject(viewModel)
        }
        .backgroundColor(.asset.background)
        .navBarWithTitle(title: viewModel.event.name, navigator: navigator, leadingButton: .back, trailingButton: .options) {
            VStack {
                Button("Set theme") {
                    isSelectThemeShowing.toggle()
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
        .sheet(isPresented: $isSelectThemeShowing) {
            NavigationView {
                SetThemeView(event: viewModel.event) { newTheme in
                    viewModel.setTheme(to: newTheme)
                    isSelectThemeShowing = false
                } cancel: {
                    isSelectThemeShowing = false
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
