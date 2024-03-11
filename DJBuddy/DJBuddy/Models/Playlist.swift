//
//  Playlist.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 11/03/2024.
//

import Foundation

class Playlist: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let title: String
    var songs: [SongData]

    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case songs
    }

    init(id: Int, title: String, songs: [SongData] = []) {
        self.id = id
        self.title = title
        self.songs = songs
    }

    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id && lhs.songs == rhs.songs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static var PreviewData: Playlist {
        Playlist(id: 0, title: "Preview playlist", songs: [SongData.PreviewData, SongData.PreviewData2])
    }
}
