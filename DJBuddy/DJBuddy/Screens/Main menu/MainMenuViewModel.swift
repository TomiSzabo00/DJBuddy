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
    func fetchEvents() async throws {

        do {
            let events = try await API.getEvents()
            yourEvents[.yourEvents] = events.filter { !$0.isInThePast }
            sortEventsByDate(&self.yourEvents[.yourEvents]!)
        } catch {
            throw error
        }
    }

    @MainActor
    func fetchNearEvents() async throws {
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
    func refreshEvents() async throws {
        do {
            let newEvents = try await API.getEvents()
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
    func join(event: EventData) async throws {
        guard !(yourEvents[.yourEvents] ?? []).contains(event) else { return }

        do {
            try await API.joinEvent(event)
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
    func leave(event: EventData) async throws {
        do {
            try await API.leaveEvent(event)
            if yourEvents[.yourEvents]?.contains(event) == true {
                yourEvents[.yourEvents]?.remove(event)
            }
            try await fetchNearEvents()
        } catch {
            throw error
        }
    }
}
