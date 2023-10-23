//
//  EventControlViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation

final class EventControlViewModel: ObservableObject {
    @Published var event: EventData
    @Published var selectedSong: SongData? = nil
    @Published var didAgree = false
    @Published var selectedPrice: Double = 1

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

    func requestSong() {
        guard let selectedSong else {
            // TODO: song error
            return
        }

        guard didAgree else {
            // TODO: agree error
            return
        }

        guard selectedPrice >= 1 else {
            // TODO: price error
            return
        }

        // TODO: request song
    }
}
