//
//  EventData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

class EventData: Hashable, Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let dj: UserData
    let location: AddressResult
    let date: Date
    var state: EventState
    var requestedSongs: [SongData]
    var theme: SongTheme? {
        didSet {
            print("Theme changed to: \(String(describing: theme))")
        }
    }

    init(name: String, dj: UserData, location: AddressResult, date: Date, state: EventState = .upcoming, requestedSongs: [SongData] = [], theme: SongTheme? = nil) {
        self.name = name
        self.dj = dj
        self.location = location
        self.date = date
        self.state = state
        self.requestedSongs = requestedSongs
        self.theme = theme
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
                  date: Date.now,
                  requestedSongs: [SongData.PreviewData, SongData.PreviewData]
        )
    }
}

enum EventState {
    case upcoming
    case inProgress
    case paused
    case ended
}

enum SongTheme: CaseIterable {
    case slow
    case pop
    case techno

    var displayName: String {
        switch self {
        case .slow:
            "Slow music"
        case .pop:
            "Pop"
        case .techno:
            "Techno"
        }
    }
}
