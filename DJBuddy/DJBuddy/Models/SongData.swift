//
//  SongData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation
import MusicKit

struct SongData: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    var amount: Double
    let albumArtUrl: String

    static func == (lhs: SongData, rhs: SongData) -> Bool {
        lhs.title == rhs.title && lhs.artist == rhs.artist
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static var PreviewData: SongData {
        SongData(title: "Gimme Gimme Gimme",
                 artist: "ABBA",
                 amount: 23,
                 albumArtUrl: "https://upload.wikimedia.org/wikipedia/en/thumb/a/a5/ABBA_-_Gimme%21_Gimme%21_Gimme%21_%28A_Man_After_Midnight%29.png/220px-ABBA_-_Gimme%21_Gimme%21_Gimme%21_%28A_Man_After_Midnight%29.png")
    }

    init(title: String, artist: String, amount: Double, albumArtUrl: String) {
        self.title = title
        self.artist = artist
        self.amount = amount
        self.albumArtUrl = albumArtUrl
    }

    init(song: Song) {
        self.title = song.title
        self.artist = song.artistName
        self.amount = 0
        self.albumArtUrl = song.artwork?.url(width: 200, height: 200)?.absoluteString ?? ""
    }
}
