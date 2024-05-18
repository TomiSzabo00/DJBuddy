//
//  PlaylistViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 07/03/2024.
//

import Foundation

final class PlaylistViewModel: ObservableObject {
    @Published private(set) var playlists: [Playlist] = []

    @MainActor
    func getPlaylists(of user: UserData) async throws {
        playlists = try await API.getAllPlaylists(of: user)
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

    @MainActor
    func add(song: SongData, to playlist: Playlist) async throws {
        do {
            try await API.addSong(to: playlist, song: song)
            playlist.songs.append(song)
            objectWillChange.send()
        } catch {
            throw error
        }
    }

    @MainActor
    func remove(song: SongData, from playlist: Playlist) async throws {
        do {
            try await API.removeSong(from: playlist, song: song)
            playlist.songs.remove(song)
            objectWillChange.send()
        } catch {
            throw error
        }
    }
}
