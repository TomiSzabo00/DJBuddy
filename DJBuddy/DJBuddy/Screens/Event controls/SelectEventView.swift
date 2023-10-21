//
//  SelectEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct SelectEventView: View {
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
                Text("Joined events")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }

        }
        .navBarWithTitle(title: "Choose event", navigator: navigator, leadingButton: .back)
    }
}

#Preview {
    NavigationView {
        SelectEventView(yourEvents: [EventData.PreviewData])
            .environmentObject(Navigator())
    }
}
