//
//  EventData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

class EventData_Database: Decodable {
    let id: String
    let name: String
    let dj: UserData_Database
    let latitude: CGFloat
    let longitude: CGFloat
    let address_title: String
    let address_subtitle: String
    let date: String
    let state: String
    let theme: String
    let songs: [SongData]

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case dj
        case latitude
        case longitude
        case address_title
        case address_subtitle
        case date
        case state
        case theme
        case songs
    }
}

class EventData: Hashable, Identifiable, ObservableObject {
    let id: String
    let name: String
    let dj: UserData
    let location: AddressResult
    let date: Date
    var state: EventState
    var theme: SongTheme?
    var requestedSongs: [SongData] {
        didSet {
            requestedSongs.sort(by: { $0.amount > $1.amount })
        }
    }

    init(name: String, dj: UserData, location: AddressResult, date: Date, state: EventState = .upcoming, requestedSongs: [SongData] = [], theme: SongTheme? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.dj = dj
        self.location = location
        self.date = date
        self.state = state
        self.requestedSongs = requestedSongs
        self.theme = theme
    }

    init(decodable: EventData_Database) {
        self.id = decodable.id
        self.name = decodable.name
        self.dj = UserData(decodable: decodable.dj)
        self.location = AddressResult(title: decodable.address_title, subtitle: decodable.address_subtitle, latitude: decodable.latitude, longitude: decodable.longitude)
        self.date = Date.fromIsoString(decodable.date)
        self.state = EventState(rawValue: decodable.state) ?? .upcoming
        self.theme = SongTheme(rawValue: decodable.theme)
        self.requestedSongs = decodable.songs.sorted(by: { $0.amount > $1.amount })
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EventData, rhs: EventData) -> Bool {
        lhs.id == rhs.id
    }

    static var PreviewData: EventData {
        let date = Calendar.current.date(byAdding: .day, value: Int.random(in: 1...10), to: Date.now)!
        return EventData(name: "Event",
                         dj: UserData.EmptyUser,
                         location: AddressResult.PreviewData,
                         date: date,
                         state: .inProgress,
                         requestedSongs: [SongData.PreviewData, SongData.PreviewData2]
        )
    }

    static var MapPreviewData: EventData {
        let date = Calendar.current.date(byAdding: .day, value: Int.random(in: 1...10), to: Date.now)!
        return EventData(name: "Event",
                         dj: UserData.EmptyUser,
                         location: AddressResult.MapPreviewData,
                         date: date,
                         state: .inProgress,
                         requestedSongs: [SongData.PreviewData, SongData.PreviewData2]
        )
    }

    static var MapPreviewData2: EventData {
        let date = Calendar.current.date(byAdding: .day, value: Int.random(in: 1...10), to: Date.now)!
        return EventData(name: "Event",
                         dj: UserData.EmptyUser,
                         location: AddressResult.MapPreviewData2,
                         date: date,
                         state: .inProgress,
                         requestedSongs: [SongData.PreviewData, SongData.PreviewData2]
        )
    }
}

enum EventState: String {
    case upcoming
    case inProgress
    case paused
    case ended
}

enum SongTheme: String, CaseIterable {
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

extension Date {
    /// Returns a `Date` decoded from the standard `ISO` format.
    /// Example input: "2023-10-29 20:28:56 +0000"
    static func fromIsoString(_ string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return dateFormatter.date(from: string) ?? .now
    }

    func toIsoString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return dateFormatter.string(from: self).appending("Z")
    }
}
