//
//  UserHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct UserHomeView: View {
    @EnvironmentObject var navigator: Navigator

    let events: [EventDataType: [EventData]]

    let joinAction: (EventData) -> Void
    let leaveAction: (EventData) -> Void

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
                        }
                    } header: {
                        Text(eventType.title(for: .user))
                            .textCase(.uppercase)
                            .font(.subheadline)
                    }
                }
            }
        }
        .animation(.default, value: events)
    }

    @ViewBuilder private func menuButtons(for event: EventData, with eventType: EventDataType) -> some View {
        VStack {
            if eventType == .yourEvents {
                Button {
                    leaveAction(event)
                } label: {
                    Label("Leave event", systemImage: "rectangle.portrait.and.arrow.forward")
                }
            } else if eventType == .nearYou {
                Button {
                    joinAction(event)
                } label: {
                    Label("Join event", systemImage: "person.badge.plus")
                }
            }

            Button {
                // TODO: show on map
            } label: {
                Label("Show on map", systemImage: "mappin.and.ellipse")
            }
        }
    }
}

#Preview {
    UserHomeView(events: [.yourEvents : [EventData.PreviewData, EventData.PreviewData], .nearYou : [EventData.PreviewData]]) { _ in} leaveAction: { _ in }
        .environmentObject(Navigator())
}
