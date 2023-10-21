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
    
    var body: some View {
        EventList {
            ForEach(Array(events.keys).sorted(by: { $0.rawValue > $1.rawValue }), id: \.rawValue) { eventType in
                Section {
                    ForEach(events[eventType] ?? []) { event in
                        EventListTile(eventData: event)
                            .contextMenu {
                                menuButtons(for: eventType)
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

    @ViewBuilder private func menuButtons(for eventType: EventDataType) -> some View {
        VStack {
            if eventType == .yourEvents {
                Button {
                    // TODO: un-join event
                } label: {
                    Label("Leave event", systemImage: "rectangle.portrait.and.arrow.forward")
                }
            } else if eventType == .nearYou {
                Button {
                    // TODO: join event
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
    UserHomeView(events: [.yourEvents : [EventData.PreviewData, EventData.PreviewData], .nearYou : [EventData.PreviewData]])
        .environmentObject(Navigator())
}
