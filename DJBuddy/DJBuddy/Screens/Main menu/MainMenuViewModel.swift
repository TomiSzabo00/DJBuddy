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
            return type == .dj ? "Upcoming events" : "Upcoming joined events"
        case .nearYou:
            return "Events near you"
        }
    }
}

final class MainMenuViewModel: ObservableObject {
    @Published private(set) var yourEvents: [EventDataType : [EventData]] = [:]
    @Published var currentLocation: CLLocationCoordinate2D? = nil

    @MainActor
    func fetchEvents(for user: UserData) async throws {

        do {
            let events = try await API.getEvents(for: user)
            yourEvents[.yourEvents] = events.filter { !$0.isInThePast }
            sortEventsByDate(&self.yourEvents[.yourEvents]!)
        } catch {
            throw error
        }
    }

    func fetchNearEvents(for user: UserData) {
        guard let location = currentLocation else { return }
//        isLoading = true

        API.getAllEvents(nearTo: location) { [weak self] result in
            guard let self else { return }
//            isLoading = false
            switch result {
            case .success(let events):
                DispatchQueue.main.async {
                    let currentEvents = events.filter { !$0.isInThePast }
                    var nearYou = currentEvents
                    if let joined = self.yourEvents[.yourEvents] {
                        nearYou = currentEvents.filter { !joined.contains($0) }
                    }
                    self.yourEvents[.nearYou] = nearYou
                    self.sortEventsByDate(&self.yourEvents[.nearYou]!)
                }
            case .failure(let failure):
                break
//                self.error = failure
            }
        }
    }

    @MainActor
    func refreshEvents(for user: UserData) async throws {
        do {
            let newEvents = try await API.getEvents(for: user)
            yourEvents[.yourEvents] = newEvents.filter { !$0.isInThePast }
            sortEventsByDate(&yourEvents[.yourEvents]!)
            self.objectWillChange.send()
        } catch {
            throw error
        }
    }

    func sortEventsByDate(_ events: inout [EventData]) {
        events.sort(by: { $0.date < $1.date })
    }

    func join(event: EventData, user: UserData) {
        guard !(yourEvents[.yourEvents] ?? []).contains(event) else { return }

//        isLoading = true

        API.joinEvent(event, user: user) { [weak self] result in
            guard let self else { return }
//            isLoading = false

            switch result {
            case .success():
                DispatchQueue.main.async {
                    if self.yourEvents[.nearYou]?.contains(event) == true {
                        self.yourEvents[.nearYou]?.remove(event)
                    }
                    self.yourEvents[.yourEvents]?.append(event)
                    self.sortEventsByDate(&self.yourEvents[.yourEvents]!)
                }
            case .failure(let failure):
                DispatchQueue.main.async {
//                    self.error = failure
                }
            }
        }
    }

    func leave(event: EventData, user: UserData) {
//        isLoading = true

        API.leaveEvent(event, user: user) { [weak self] result in
//            self?.isLoading = false
            switch result {
            case .success():
                DispatchQueue.main.async {
                    if self?.yourEvents[.yourEvents]?.contains(event) == true {
                        self?.yourEvents[.yourEvents]?.remove(event)
                    }
                }
                self?.fetchNearEvents(for: user)
            case .failure(let failure):
                DispatchQueue.main.async {
//                    self?.error = failure
                }
            }
        }
    }
}
