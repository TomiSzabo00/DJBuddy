//
//  EventControlViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation

final class EventControlViewModel: ObservableObject {
    @Published var event: EventData

    init(event: EventData) {
        self.event = event
    }

    func setTheme(to theme: SongTheme?) {
        event.theme = theme
        objectWillChange.send()
    }

    func setState(to state: EventState) {
        event.state = state
        objectWillChange.send()
    }
}
