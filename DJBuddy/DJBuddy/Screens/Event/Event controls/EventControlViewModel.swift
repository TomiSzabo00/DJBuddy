//
//  EventControlViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation
import StripePaymentSheet

final class EventControlViewModel: ObservableObject, Hashable {
    @Published var event: EventData
    @Published var selectedSong: SongData? = nil
    @Published var didAgree = false
    @Published var selectedPrice: Double = 1
    @Published var isLoading = false
    @Published var formError: Error? = nil
    @Published var error: Error? = nil
    @Published var availablePlaylists: [Playlist] = []
    @Published var currentPlaylist: Playlist? = nil
    var currentSong: SongData? = nil

    private var webSocketTasks = Set<URLSessionWebSocketTask?>()


    func initWebSocketForGeneralEventChanges() {
        print("Opening websocket for general event changes...")
        let task = API.connectToEventWebSocket(id: event.id)
        task?.resume()
        listenForEventChanges(in: task)

        webSocketTasks.insert(task)
    }

    func initWebSocketForEventThemeChanges() {
        print("Opening websocket for event theme changes...")
        let task = API.connectToEventWebSocket(id: event.id, pathSuffix: "themes")
        task?.resume()
        listenForThemeChanges(in: task)

        webSocketTasks.insert(task)
    }

    private func listenForThemeChanges(in task: URLSessionWebSocketTask?) {
        task?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let success):
                print("Got new theme data from websocket. Decoding...")
                switch success {
                case .data(let data):
                    DispatchQueue.main.async {
                        let str = String(decoding: data, as: UTF8.self)
                        self.event.theme = SongTheme(rawValue: str)
                        print("Theme changed to \(self.event.theme?.displayName ?? "nil")")
                        self.objectWillChange.send()
                    }
                case .string(let string):
                    DispatchQueue.main.async {
                        self.event.theme = SongTheme(rawValue: string)
                        print("Theme changed to \(self.event.theme?.displayName ?? "nil")")
                        self.objectWillChange.send()
                    }
                default:
                    print("Unhandled websocket result.")
                }
                self.listenForThemeChanges(in: task)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.formError = failure
                }
            }
        }
    }

    private func listenForEventChanges(in task: URLSessionWebSocketTask?) {
        task?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let success):
                print("Got new data from websocket. Decoding...")
                switch success {
                case .data(let data):
                    DispatchQueue.main.async {
                        if let newEvent = self.decodeEventData(data) {
                            self.event = newEvent
                            self.objectWillChange.send()
                        }
                    }
                case .string(let string):
                    DispatchQueue.main.async {
                        if let data = string.data(using: .utf8, allowLossyConversion: false),
                           let newEvent = self.decodeEventData(data) {
                            self.event = newEvent
                            self.objectWillChange.send()
                        }
                    }
                default:
                    print("Unhandled websocket result.")
                }
                self.listenForEventChanges(in: task)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.formError = failure
                }
            }
        }
    }

    func closeWebSockets() {
        print("Closing all websockets:")
        for task in webSocketTasks {
            task?.cancel(with: .goingAway, reason: nil)
            print("\t- WebSocket closed")
        }
        webSocketTasks.removeAll()
    }

    private func decodeEventData(_ data: Data) -> EventData? {
        do {
            let responseObject = try JSONDecoder().decode(EventData_Database.self, from: data)
            print("EventData decoded.")
            return EventData(decodable: responseObject)
        } catch {
            print("EventData couldn't be decoded...")
            return nil
        }
    }

    @MainActor
    func getCurrentTheme() async throws {
        event.theme = try await API.getEventTheme(for: event)
        objectWillChange.send()
    }

    @MainActor
    func getCurrentEvent() async throws {
        event = try await API.getEvent(id: event.id)
        objectWillChange.send()
    }

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
        return event.requestedSongs[idx - 1].amount - song.amount + 1.0
    }

    init(event: EventData) {
        self.event = event
    }

    func setTheme(to theme: SongTheme?) async throws {
        guard event.theme != theme else { return }

        try await API.setEventTheme(to: theme, in: event)
    }

    func setState(to state: EventState) async throws {
        guard event.state != state else { return }

        try await API.setEventState(to: state, in: event)
    }

    @MainActor
    func setPlaylist(to playlist: Playlist?) async throws {
        guard playlist?.id != event.playlistId else { return }

        do {
            if let playlist {
                try await API.setEventPlaylist(to: playlist, in: event)
            } else {
                try await API.removeEventPlaylist(from: event)
            }
            currentPlaylist = playlist
        } catch {
            throw error
        }
    }

    func getAvailablePlaylists(for user: UserData) {
        API.getAllPlaylists(of: user) { [weak self] result in
            switch result {
            case .success(let allPlaylists):
                DispatchQueue.main.async {
                    self?.availablePlaylists = allPlaylists.filter({ $0.hasEnoughSongs })
                }
            case .failure(let error):
                self?.error = error
            }
        }
    }

    @MainActor
    func getCurrentPlaylist() async throws {
        currentPlaylist = try await API.getEventPlaylist(for: event)
    }

    @MainActor
    func requestSong(by user: UserData) async throws {
        guard let selectedSong else {
            throw FormError.songMissing
        }

        guard didAgree else {
            throw FormError.acceptMissing
        }

        guard selectedPrice >= 1 else {
            throw FormError.priceMissing
        }

        selectedSong.amount = selectedPrice
        selectedSong.id = try await API.requestSong(selectedSong, for: event, by: user)
    }

    func removeSong(_ song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
        isLoading = true
        API.removeSong(song) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }

    func decline(song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
        removeSong(song) { result in
            completion(result)
        }
    }

    func accept(song: SongData, dj: UserData) async throws {
        do {
            try await API.addToUserBalance(amount: song.amount, user: dj)
            removeSong(song) { _ in }
        } catch let error {
            throw error
        }
    }

    func increasePrice(by user: UserData) async throws {
        guard let currentSong,
        let idx = event.requestedSongs.firstIndex(of: currentSong)
        else { return }

        do {
            try await API.removeFromUserBalance(amount: selectedPrice, user: user)
            event.requestedSongs[idx].amount = try await API.increasePrice(of: currentSong, by: selectedPrice)
            objectWillChange.send()
        } catch {
            throw error
        }
    }

    func sortSongs(_ songs: inout [SongData]) {
        songs.sort(by: { $0.amount > $1.amount })
    }
}

/// Hashable extension
extension EventControlViewModel {
    static func == (lhs: EventControlViewModel, rhs: EventControlViewModel) -> Bool {
        lhs.event == rhs.event
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }
}
