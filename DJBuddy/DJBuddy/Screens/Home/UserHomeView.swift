//
//  UserHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct UserHomeView: View {
    var body: some View {
        EventList {
            Section {
                EventListTile()
                EventListTile()
            } header: {
                Text("Joined events")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }

            Section {
                EventListTile()
            } header: {
                Text("Events near you")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    UserHomeView()
}
