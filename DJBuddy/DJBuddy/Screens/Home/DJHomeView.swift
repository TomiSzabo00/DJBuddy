//
//  DJHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct DJHomeView: View {
    @EnvironmentObject var navigator: Navigator

    let yourEvents: [EventData]

    var body: some View {
        EventList {
            Section {
                ForEach(yourEvents) { event in
                    EventListTile(eventData: event)
                        .onTapGesture {
                            navigator.navigate(with: event)
                        }
                }
            } header: {
                Text("Your events")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    DJHomeView(yourEvents: [EventData.PreviewData])
}
