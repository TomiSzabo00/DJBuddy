//
//  LikedSongsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 06/03/2024.
//

import Foundation

final class SavedSongsViewModel: ObservableObject {
    @Published private(set) var likedSongs: [SongData] = []
    @Published var isLoading = false
    @Published var error: Error? = nil

    func getLikedSongs(for user: UserData) {
        isLoading = true

        API.getAllSavedSongs(by: user) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self?.likedSongs = success
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
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

    func dislike(song: SongData, by user: UserData) {
        isLoading = true

        API.unsave(song: song, by: user) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success():
                DispatchQueue.main.async {
                    self?.likedSongs.remove(song)
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }
}
