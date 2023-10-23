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
        guard let amountToNextSong else { return false }
        return selectedPrice < amountToNextSong
    }

    var amountToNextSong: Double? {
        guard let song = currentSong,
              let idx = event.requestedSongs.firstIndex(of: song),
              idx > 0,
              event.requestedSongs[idx - 1].amount > song.amount
        else { return nil }
//        guard let song = currentSong else { print("guard 1"); return false }
//        guard let idx = event.requestedSongs.firstIndex(of: song) else { print("guard 2"); return false }
//        guard idx > 0 else { print("guard 3"); return false }
        return event.requestedSongs[idx - 1].amount - song.amount + 1.0
    }

    init(event: EventData) {
        self.event = event
    }

    func setTheme(to theme: SongTheme?, completion: @escaping (Result<Void, APIError>) -> Void) {
        isLoading = true
        // TODO: BE action
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.event.theme = theme
            self?.objectWillChange.send()
            completion(.success(()))
//            completion(.failure(.unreachable))
            self?.isLoading = false
        }
    }

    func setState(to state: EventState, completion: @escaping (Result<Void, APIError>) -> Void) {
        isLoading = true
        // TODO: BE action
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.event.state = state
            self?.objectWillChange.send()
            completion(.success(()))
            self?.isLoading = false
        }
    }

    func requestSong(completion: @escaping (Result<Void, APIError>) -> Void) {
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

    func removeSongFromList(_ song: SongData) {
        event.requestedSongs.removeAll(where: { $0 == song })
    }

    func decline(song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
        isLoading = true
        // TODO: remove song from BE
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.removeSongFromList(song)
            completion(.success(()))
            self?.isLoading = false
        }
    }

    func accept(song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
        isLoading = true
        // TODO: give money to DJ
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.removeSongFromList(song)
            //completion(.success(()))
            completion(.failure(.unreachable))
            self?.isLoading = false
        }
    }

    func increasePrice(completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let currentSong,
        let idx = event.requestedSongs.firstIndex(of: currentSong)
        else { return }

        isLoading = true

        // TODO: BE action
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            guard let self else { return }
            event.requestedSongs[idx].amount += selectedPrice
            sortSongs(&event.requestedSongs)
            objectWillChange.send()
            completion(.success(()))
            isLoading = false
        }
    }

    func sortSongs(_ songs: inout [SongData]) {
        songs.sort(by: { $0.amount > $1.amount })
    }

    static func == (lhs: EventControlViewModel, rhs: EventControlViewModel) -> Bool {
        lhs.event == rhs.event
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }
}
