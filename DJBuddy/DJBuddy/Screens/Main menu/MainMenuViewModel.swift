//
//  MainMenuViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation

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
                print(error.localizedDescription)
            }
        }

        // TODO: near you events logic
        // yourEvents[.nearYou] = [EventData.PreviewData]
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

    func join(event: EventData) {
        guard !(yourEvents[.yourEvents] ?? []).contains(event) else { return }

        if (yourEvents[.nearYou] ?? []).contains(event) {
            yourEvents[.nearYou]?.removeAll(where: { $0 == event})
        }

        if yourEvents[.yourEvents] != nil {
            yourEvents[.yourEvents]!.append(event)
        } else {
            yourEvents[.yourEvents] = [event]
        }

        sortEventsByDate(&yourEvents[.yourEvents]!)
    }

    func leave(event: EventData) {
        yourEvents[.yourEvents]?.removeAll(where: { $0 == event})
    }
}
