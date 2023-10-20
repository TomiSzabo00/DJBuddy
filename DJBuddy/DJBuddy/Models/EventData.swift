//
//  EventData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

struct EventData: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let dj: UserData
    let location: AddressResult
    let date: Date
    let state: EventState

    init(name: String, dj: UserData, location: AddressResult, date: Date, state: EventState = .upcoming) {
        self.name = name
        self.dj = dj
        self.location = location
        self.date = date
        self.state = state
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EventData, rhs: EventData) -> Bool {
        lhs.id == rhs.id
    }

    static var PreviewData: EventData {
        EventData(name: "Event",
                  dj: UserData.PreviewUser,
                  location: AddressResult.PreviewData,
                  date: Date.now)
    }
}

enum EventState {
    case upcoming
    case inProgress
    case ended
}
