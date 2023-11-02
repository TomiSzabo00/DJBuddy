//
//  MainMenuViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation
import CoreLocation

enum EventDataType: String {
    case yourEvents = "your events"
    case nearYou = "near you"

    func title(for type: UserTypeEnum) -> String {
        switch self {
        case .yourEvents:
            return type == .dj ? "Your events" : "Joined events"
        case .nearYou:
            return "Events near you"
        }
    }
}

final class MainMenuViewModel: ObservableObject {
    @Published private(set) var yourEvents: [EventDataType : [EventData]] = [:]
    @Published var error: Error? = nil
    @Published var isLoading = false
    private var isLoadingQuietly = false

    func fetchEvents(for user: UserData) {
        isLoading = true

        API.getEvents(from: user) { [weak self] result in
            guard let self else { return }
            isLoading = false
            switch result {
            case .success(let events):
                yourEvents[.yourEvents] = events
                sortEventsByDate(&yourEvents[.yourEvents]!)
            case .failure(let error):
                self.error = error
            }
        }
    }

    func fetchNearEvents(to location: CLLocationCoordinate2D, for user: UserData) {
        isLoading = true

        API.getAllEvents(nearTo: location) { [weak self] result in
            guard let self else { return }
            isLoading = false
            switch result {
            case .success(let events):
                var nearYou = events
                if let joined = yourEvents[.yourEvents] {
                    nearYou = events.filter { !joined.contains($0) }
                }
                yourEvents[.nearYou] = nearYou
                sortEventsByDate(&yourEvents[.nearYou]!)
            case .failure(let failure):
                self.error = failure
            }
        }
    }

    func fetchEventsQuietly(for user: UserData) {
        guard !isLoading, !isLoadingQuietly else { return }

        isLoadingQuietly = true

        API.getEvents(from: user) { [weak self] result in
            guard let self else { return }
            isLoadingQuietly = false
            switch result {
            case .success(let events):
                yourEvents[.yourEvents] = events
                sortEventsByDate(&yourEvents[.yourEvents]!)
                objectWillChange.send()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

        // TODO: near you events logic
        // yourEvents[.nearYou] = [EventData.PreviewData]
    }

    func refreshEvents(for user: UserData) async {
        let newEvents = await API.getEventsAsync(from: user)
        print("Events refreshed")
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            yourEvents[.yourEvents] = newEvents
            sortEventsByDate(&yourEvents[.yourEvents]!)
            self.objectWillChange.send()
        }
    }

    func sortEventsByDate(_ events: inout [EventData]) {
        events.sort(by: { $0.date < $1.date })
    }

    func join(event: EventData, user: UserData) {
        guard !(yourEvents[.yourEvents] ?? []).contains(event) else { return }

        isLoading = true

        API.joinEvent(event, user: user) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success():
                self?.fetchEvents(for: user)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func leave(event: EventData, user: UserData) {
        isLoading = true

        API.leaveEvent(event, user: user) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success():
                self?.fetchEvents(for: user)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }
}
