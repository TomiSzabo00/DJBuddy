//
//  SelectEventView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 21/10/2023.
//

import SwiftUI

struct SelectEventView: View {
    @EnvironmentObject var navigator: Navigator

    @State var yourEvents: [EventData]

    var showableEvents: [EventData] {
        yourEvents.filter { event in
            [.inProgress, .paused].contains(event.state)
        }
    }

    var body: some View {
        Group {
            if showableEvents.isEmpty {
                VStack {
                    InfoView("There aren't any ongoing events among your joined ones.", type: .info)
                    Spacer()
                }
                .padding()
                .backgroundColor(.asset.background)
            } else {
                EventList {
                    Section {
                        ForEach(showableEvents) { event in
                            EventListTile(eventData: event)
                                .onTapGesture {
                                    navigator.navigate(to: .userEventView(event))
                                }
                        }
                    } header: {
                        Text("Choose an event")
                            .textCase(.uppercase)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navBarWithTitle(title: "Request a song", navigator: navigator, leadingButton: .back)
    }
}

#Preview {
    NavigationView {
        SelectEventView(yourEvents: [EventData.PreviewData])
            .environmentObject(Navigator())
    }
}
