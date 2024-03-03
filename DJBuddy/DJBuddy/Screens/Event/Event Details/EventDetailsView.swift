//
//  EventDetailsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import SwiftUI

struct EventDetailsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = EventDetailsViewModel()

    let event: EventData
    let isJoined: Bool
    @State private var isShareShowing = false


    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(event.dj.username)

            Text("Joined users: \(3)")

            Spacer()

            buttonContent()
        }
        .foregroundStyle(.white)
        .padding(20)
        .backgroundColor(.background)
        .navBarWithTitle(title: "Event details", navigator: navigator, leadingButton: .back, trailingButton: .share($isShareShowing))
        .sheet(isPresented: $isShareShowing) {
            NavigationView {
                ShareEventView(code: event.code, isShowing: $isShareShowing)
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $viewModel.error)
        .onAppear {
            viewModel.isJoined = isJoined
        }
        .animation(.default, value: viewModel.isJoined)
    }

    @ViewBuilder private func buttonContent() -> some View {
        VStack(spacing: 20) {
            if user.isDj {
                Button("Manage songs") {
                    navigator.navigate(to: .eventControl(event))
                }
                .buttonStyle(.largeProminent)

                Button("Delete event") {
                    // TODO: delete event
                }
                .buttonStyle(.largeSecondary)
            } else {
                if viewModel.isJoined {
                    Button("Request songs") {
                        navigator.navigate(to: .requestSong(event))
                    }
                    .buttonStyle(.largeProminent)

                    Button("Leave event") {
                        viewModel.leave(event: event, user: user)
                    }
                    .buttonStyle(.largeSecondary)
                } else {
                    Button("Join event") {
                        viewModel.join(event: event, user: user)
                    }
                    .buttonStyle(.largeProminent)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EventDetailsView(event: EventData.PreviewData, isJoined: true)
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
