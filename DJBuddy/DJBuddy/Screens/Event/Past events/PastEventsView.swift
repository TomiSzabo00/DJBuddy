//
//  PastEventsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/03/2024.
//

import SwiftUI

struct PastEventsView: View {
    @EnvironmentObject private var stateHelper: StateHelper
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = PastEventsViewModel()

    var body: some View {
        List {
            Section {
                ForEach(viewModel.pastEvents) { event in
                    EventListTile(eventData: event)
                        .onTapGesture {
                            navigator.navigate(to: .eventDetails(event, true))
                        }
                }
            } header: {
                Text("Your past events")
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
        }
        .preferredColorScheme(.dark)
        .background(Color.asset.background)
        .scrollContentBackground(.hidden)
        .navBarWithTitle(title: "Past events", navigator: navigator, leadingButton: .back)
        .onAppear {
            stateHelper.performWithProgress {
                try await viewModel.getPastEvents(for: user)
            }
        }
    }
}

#Preview {
    NavigationView {
        PastEventsView()
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
