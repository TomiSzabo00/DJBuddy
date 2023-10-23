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
                    viewModel.setTheme(to: nil) { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(_):
                            // TODO: handle error
                            break
                        }
                    }
                }
                Button("Pause requests") {
                    viewModel.setState(to: .paused) { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(_):
                            // TODO: handle error
                            break
                        }
                    }
                }
                Button("Resume requests") {
                    viewModel.setState(to: .inProgress) { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(_):
                            // TODO: handle error
                            break
                        }
                    }
                }
                Button(role: .destructive) {
                    viewModel.setState(to: .ended) { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(_):
                            // TODO: handle error
                            break
                        }
                    }
                } label: {
                    Text("End event")
                }

            }
        }
        .sheet(isPresented: $isSelectThemeShowing) {
            NavigationView {
                SetThemeView(event: viewModel.event) { newTheme in
                    isSelectThemeShowing = false
                    viewModel.setTheme(to: newTheme) { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(_):
                            // TODO: handle error
                            break
                        }
                    }
                } cancel: {
                    isSelectThemeShowing = false
                }
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
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
