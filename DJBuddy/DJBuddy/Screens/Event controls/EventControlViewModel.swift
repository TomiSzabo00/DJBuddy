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
    @Published var isLoading = false

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

    func requestSong(completion: @escaping (Result<Void, Never>) -> Void) {
        guard var selectedSong else {
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

        isLoading = true

        // TODO: request song from API
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [ weak self] in
            self?.isLoading = false
            completion(.success(()))
        }

        if let idx = event.requestedSongs.firstIndex(of: selectedSong) {
            event.requestedSongs[idx].amount += selectedPrice
        } else {
            selectedSong.amount = selectedPrice
            event.requestedSongs.append(selectedSong)
        }
    }
}
