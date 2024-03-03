//
//  DJHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct DJHomeView: View {
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject var viewModel: MainMenuViewModel

    var yourEvents: [EventData] {
        viewModel.yourEvents[.yourEvents] ?? []
    }

    var body: some View {
        EventList {
            Section {
                ForEach(yourEvents) { event in
                    EventListTile(eventData: event)
                        .onTapGesture {
                            navigator.navigate(to: .eventDetails(event))
                        }
                }
            } header: {
                Text("Your events")
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
        }
        .refreshable {
            await viewModel.refreshEvents(for: user)
        }
    }
}

#Preview {
    DJHomeView(viewModel: MainMenuViewModel())
}
