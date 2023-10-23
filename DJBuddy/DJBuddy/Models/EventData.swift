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
    var requestedSongs: [SongData] {
        didSet {
            requestedSongs.sort(by: { $0.amount > $1.amount })
        }
    }
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
    case alternative
    case classical
    case dance
    case electronic
    case hipHop
    case jazz
    case metal
    case pop
    case reggae
    case rock

    var displayName: String {
        switch self {
        case .alternative:
            "Alternative"
        case .classical:
            "Classical"
        case .dance:
            "Dance"
        case .electronic:
            "Electronic"
        case .hipHop:
            "Hip-Hop/Rap"
        case .jazz:
            "Jazz"
        case .metal:
            "Metal"
        case .pop:
            "Pop"
        case .reggae:
            "Reggae"
        case .rock:
            "Rock"
        }
    }
}
