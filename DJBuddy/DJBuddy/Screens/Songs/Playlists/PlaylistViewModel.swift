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

    func createPlaylist(name: String, by user: UserData) {
        API.createPlaylist(by: user, name: name) { [weak self] result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self?.playlists.append(Playlist(id: success, title: name))
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func delete(playlist: Playlist) {
        API.deletePlaylist(id: playlist.id) { [weak self] result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self?.playlists.removeAll(where: { $0.id == playlist.id })
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
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
