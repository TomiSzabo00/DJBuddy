//
//  SongData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation
import MusicKit

class SongData: Identifiable, Hashable, ObservableObject {
    let title: String
    let artist: String
    @Published var amount: Double
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

    static var PreviewData2: SongData {
        SongData(title: "bad guy",
                 artist: "Billie Eilish",
                 amount: 10,
                 albumArtUrl: "https://t2.genius.com/unsafe/340x340/https%3A%2F%2Fimages.genius.com%2F340ad5b2b1163aa2333a8efc0815b84f.1000x1000x1.jpg")
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
