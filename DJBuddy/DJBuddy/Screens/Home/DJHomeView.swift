//
//  DJHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct DJHomeView: View {
    @EnvironmentObject private var stateHelper: StateHelper
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
                            navigator.navigate(to: .eventDetails(event, true))
                        }
                }
            } header: {
                Text(EventDataType.yourEvents.title(for: user.type))
                    .textCase(.uppercase)
                    .font(.subheadline)
            }
        }
        .refreshable {
            stateHelper.performWithProgress {
                try await viewModel.refreshEvents(for: user)
            }
        }
    }
}

#Preview {
    DJHomeView(viewModel: MainMenuViewModel())
}
