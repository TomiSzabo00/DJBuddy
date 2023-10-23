//
//  EventControlViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation

final class EventControlViewModel: ObservableObject, Hashable {
    @Published var event: EventData
    @Published var selectedSong: SongData? = nil
    @Published var didAgree = false
    @Published var selectedPrice: Double = 1
    @Published var isLoading = false
    var currentSong: SongData? = nil

    var shouldSHowPriceWarining: Bool {
        guard let song = currentSong,
              let idx = event.requestedSongs.firstIndex(of: song),
              idx > 0
        else { return false }
//        guard let song = currentSong else { print("guard 1"); return false }
//        guard let idx = event.requestedSongs.firstIndex(of: song) else { print("guard 2"); return false }
//        guard idx > 0 else { print("guard 3"); return false }
        let nextAmount = event.requestedSongs[idx - 1].amount
//        print("\(song.amount) + \(selectedPrice) >? \(nextAmount)")
        return song.amount + selectedPrice < nextAmount
    }

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

    static func == (lhs: EventControlViewModel, rhs: EventControlViewModel) -> Bool {
        lhs.event == rhs.event
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }
}
