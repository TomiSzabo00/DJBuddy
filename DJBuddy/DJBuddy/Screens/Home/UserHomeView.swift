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
                            .onTapGesture {
                                navigator.navigate(with: event)
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
}

#Preview {
    UserHomeView(events: [:])
        .environmentObject(Navigator())
}
