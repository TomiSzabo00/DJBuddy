//
//  LikedSongsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 06/03/2024.
//

import Foundation

final class SavedSongsViewModel: ObservableObject {
    @Published private(set) var likedSongs: [SongData] = []

    @MainActor
    func getLikedSongs() async throws {
        likedSongs = try await API.getAllSavedSongs()
    }

    @MainActor
    func like(song: SongData) async throws {
        do {
            song.id = try await API.save(song: song)
            likedSongs.append(song)
        } catch {
            throw error
        }
    }

    @MainActor
    func dislike(song: SongData) async throws {
        do {
            try await API.unsave(song: song)
            likedSongs.remove(song)
        } catch {
            throw error
        }
    }
}
