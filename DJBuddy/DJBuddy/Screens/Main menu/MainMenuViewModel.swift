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

    @MainActor
    func fetchNearEvents(for user: UserData) async throws {
        guard let location = currentLocation else { return }

        do {
            let events = try await API.getAllEvents(nearTo: location)
            let currentEvents = events.filter { !$0.isInThePast }
            var nearYou = currentEvents
            if let joined = yourEvents[.yourEvents] {
                nearYou = currentEvents.filter { !joined.contains($0) }
            }
            yourEvents[.nearYou] = nearYou
            sortEventsByDate(&yourEvents[.nearYou]!)
        } catch {
            throw error
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

    @MainActor
    func join(event: EventData, user: UserData) async throws {
        guard !(yourEvents[.yourEvents] ?? []).contains(event) else { return }

        do {
            try await API.joinEvent(event, user: user)
            if yourEvents[.nearYou]?.contains(event) == true {
                yourEvents[.nearYou]?.remove(event)
            }
            yourEvents[.yourEvents]?.append(event)
            sortEventsByDate(&yourEvents[.yourEvents]!)
        } catch {
            throw error
        }
    }

    @MainActor
    func leave(event: EventData, user: UserData) async throws {
        do {
            try await API.leaveEvent(event, user: user)
            if yourEvents[.yourEvents]?.contains(event) == true {
                yourEvents[.yourEvents]?.remove(event)
            }
            try await fetchNearEvents(for: user)
        } catch {
            throw error
        }
    }
}
