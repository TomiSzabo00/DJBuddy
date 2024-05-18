//
//  PlaylistViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 07/03/2024.
//

import Foundation

final class PlaylistViewModel: ObservableObject {
    @Published private(set) var playlists: [Playlist] = []
    @Published var isLoading = false
    @Published var error: Error? = nil

    func getPlaylists(of user: UserData) {
        isLoading = true

        API.getAllPlaylists(of: user) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self?.playlists = success
                    self?.objectWillChange.send()
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    @MainActor
    func createPlaylist(name: String, by user: UserData) async throws {
        do {
            let newId = try await API.createPlaylist(by: user, name: name)
            playlists.append(Playlist(id: newId, title: name))
        } catch {
            throw error
        }
    }

    @MainActor
    func delete(playlist: Playlist) async throws {
        do {
            try await API.deletePlaylist(id: playlist.id)
            playlists.removeAll(where: { $0.id == playlist.id })
        } catch {
            throw error
        }
    }

    func add(song: SongData, to playlist: Playlist) {
        API.addSong(to: playlist, song: song) { [weak self] result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    playlist.songs.append(song)
                    self?.objectWillChange.send()
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func remove(song: SongData, from playlist: Playlist) {
        API.removeSong(from: playlist, song: song) { [weak self] result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    playlist.songs.remove(song)
                    self?.objectWillChange.send()
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }
}
