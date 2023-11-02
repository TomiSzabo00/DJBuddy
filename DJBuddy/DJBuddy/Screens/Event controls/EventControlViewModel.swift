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
    @Published var formError: Error? = nil
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

    func getCurrentTheme() {
        isLoading = true

        API.getEventTheme(for: event) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let newTheme):
                DispatchQueue.main.async {
                    self?.event.theme = newTheme
                    self?.objectWillChange.send()
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.formError = failure
                }
            }
        }
    }

    func getCurrentEvent() {
        isLoading = true

        API.getEvent(id: event.id) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success(let newEvent):
                DispatchQueue.main.async {
                    self?.event = newEvent
                    self?.objectWillChange.send()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.formError = error
                }
            }
        }
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

    func setTheme(to theme: SongTheme?, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard event.theme != theme else { completion(.success(())); return }
        isLoading = true

        API.setEventTheme(to: theme, in: event) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }

    func setState(to state: EventState, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard event.state != state else { completion(.success(())); return }

        isLoading = true

        API.setEventState(to: state, in: event) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }

    func requestSong(completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let selectedSong else {
            formError = FormError.songMissing
            return
        }

        guard didAgree else {
            formError = FormError.acceptMissing
            return
        }

        guard selectedPrice >= 1 else {
            formError = FormError.priceMissing
            return
        }

        isLoading = true

        selectedSong.amount = selectedPrice
        API.requestSong(selectedSong, for: event) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let id):
                selectedSong.id = id
                completion(.success(()))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
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

    func accept(song: SongData, completion: @escaping (Result<Void, APIError>) -> Void) {
        // TODO: give money to DJ
        
        removeSong(song) { result in
            completion(result)
        }
    }

    func increasePrice(completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let currentSong,
        let idx = event.requestedSongs.firstIndex(of: currentSong)
        else { return }

        isLoading = true

        API.increasePrice(of: currentSong, by: selectedPrice) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let newAmount):
                DispatchQueue.main.async {
                    self?.event.requestedSongs[idx].amount = newAmount
                    self?.objectWillChange.send()
                    completion(.success(()))
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
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
