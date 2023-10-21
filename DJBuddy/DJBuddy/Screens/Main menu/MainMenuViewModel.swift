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

    func fetchEvents(for user: UserData) {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.yourEvents[.yourEvents] = [EventData.PreviewData, EventData.PreviewData]
            self?.yourEvents[.nearYou] = [EventData.PreviewData]
            self?.isLoading = false
        }
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
    }

    func leave(event: EventData) {
        yourEvents[.yourEvents]?.removeAll(where: { $0 == event})
    }
}
