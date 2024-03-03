//
//  EventDetailsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import SwiftUI

struct EventDetailsView: View {
    @EnvironmentObject private var navigator: Navigator

    let event: EventData

    @State private var isShareShowing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(event.dj.username)

            Text("Joined users: \(3)")

            Spacer()

            Button("Manage songs") {}
                .buttonStyle(.largeProminent)

            Button("Delete event") {}
                .buttonStyle(.largeSecondary)
        }
        .foregroundStyle(.white)
        .padding(20)
        .backgroundColor(.background)
        .navBarWithTitle(title: "Event details", navigator: navigator, trailingButton: .share($isShareShowing))
        .sheet(isPresented: $isShareShowing) {
            NavigationView {
                ShareEventView(code: event.code, isShowing: $isShareShowing)
            }
        }
    }
}

#Preview {
    NavigationView {
        EventDetailsView(event: EventData.PreviewData)
            .environmentObject(Navigator())
    }
}
