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
    func getLikedSongs(for user: UserData) async throws {
        likedSongs = try await API.getAllSavedSongs(by: user)
    }

    @MainActor
    func like(song: SongData, by user: UserData) async throws {
        do {
            song.id = try await API.save(song: song, by: user)
            likedSongs.append(song)
        } catch {
            throw error
        }
    }

    @MainActor
    func dislike(song: SongData, by user: UserData) async throws {
        do {
            try await API.unsave(song: song, by: user)
            likedSongs.remove(song)
        } catch {
            throw error
        }
    }
}
