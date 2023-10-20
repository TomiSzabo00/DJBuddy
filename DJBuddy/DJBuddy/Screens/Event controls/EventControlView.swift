//
//  EventControlView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI

struct EventControlView: View {
    @EnvironmentObject var navigator: Navigator
    let event: EventData

    var body: some View {
        VStack {
            Text(event.location.title)
        }
        .navBarWithTitle(title: event.name, navigator: navigator, leadingButton: .back, trailingButton: .options)
    }

    init(event: EventData) {
        self.event = event

        UINavigationBar.appearance().tintColor = .red
    }
}

#Preview {
    NavigationView {
        EventControlView(event: EventData.PreviewData)
            .environmentObject(Navigator())
    }
}
