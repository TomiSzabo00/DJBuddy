//
//  DJHomeView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 09/10/2023.
//

import SwiftUI

struct DJHomeView: View {
    @EnvironmentObject var navigator: Navigator

    var body: some View {
        EventList {
            Section {
                ForEach(0...1, id: \.self) { _ in
                    EventListTile(eventData: EventData.PreviewData)
                        .onTapGesture {
                            navigator.navigate(with: EventData.PreviewData)
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
    DJHomeView()
}
