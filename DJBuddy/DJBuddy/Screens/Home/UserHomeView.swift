//
//  UserHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct UserHomeView: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject var viewModel: MainMenuViewModel

    let showOnMapAction: (AddressResult) -> Void

    var events: [EventDataType: [EventData]] {
        viewModel.yourEvents
    }

    var body: some View {
        EventList {
            ForEach(Array(events.keys).sorted(by: { $0.rawValue > $1.rawValue }), id: \.rawValue) { eventType in
                if !(events[eventType] ?? []).isEmpty {
                    Section {
                        ForEach(events[eventType] ?? []) { event in
                            EventListTile(eventData: event)
                                .contextMenu {
                                    menuButtons(for: event, with: eventType)
                                }
                                .onTapGesture {
                                    navigator.navigate(to: .eventDetails(event, eventType == .yourEvents))
                                }
                        }
                    } header: {
                        Text(eventType.title(for: .user))
                            .textCase(.uppercase)
                            .font(.subheadline)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.refreshEvents(for: user)
        }
        .animation(.default, value: events)
        .errorAlert(error: $viewModel.error)
    }

    @ViewBuilder private func menuButtons(for event: EventData, with eventType: EventDataType) -> some View {
        VStack {
            if eventType == .yourEvents {
                Button {
                    viewModel.leave(event: event, user: user)
                } label: {
                    Label("Leave event", systemImage: "rectangle.portrait.and.arrow.forward")
                }
            } else if eventType == .nearYou {
                Button {
                    viewModel.join(event: event, user: user)
                } label: {
                    Label("Join event", systemImage: "person.badge.plus")
                }
            }

            Button {
                showOnMapAction(event.location)
            } label: {
                Label("Show on map", systemImage: "mappin.and.ellipse")
            }
        }
    }
}

#Preview {
    UserHomeView(viewModel: MainMenuViewModel()) { _ in }
        .environmentObject(Navigator())
}
