//
//  DJHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct DJHomeView: View {
    var body: some View {
        EventList {
            Section {
                EventListTile(eventData: EventData.PreviewData)
                EventListTile(eventData: EventData.PreviewData)
            } header: {
                Text("Your events")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    DJHomeView()
}
