//
//  SongData.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 20/10/2023.
//

import Foundation

struct SongData: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let amount: Double
    let albumArtUrl: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static var PreviewData: SongData {
        SongData(title: "Gimme Gimme Gimme",
                 artist: "ABBA",
                 amount: 23,
                 albumArtUrl: "https://upload.wikimedia.org/wikipedia/en/thumb/a/a5/ABBA_-_Gimme%21_Gimme%21_Gimme%21_%28A_Man_After_Midnight%29.png/220px-ABBA_-_Gimme%21_Gimme%21_Gimme%21_%28A_Man_After_Midnight%29.png")
    }
}
