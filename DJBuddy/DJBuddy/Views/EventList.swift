//
//  EventList.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct EventList<Content: View>: View {
    let content: () -> Content

    var body: some View {
        List {
            Section {
                content()
            } header: {
                Text("Your events")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
        }
        .preferredColorScheme(.dark)
        .background(Color.asset.background)
        .scrollContentBackground(.hidden)
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}

#Preview {
    EventList {
        EventListTile()
        EventListTile()
    }
}
