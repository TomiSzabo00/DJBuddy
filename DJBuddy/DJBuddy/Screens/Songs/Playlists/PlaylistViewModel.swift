//
//  PlaylistViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 07/03/2024.
//

import Foundation

struct Playlist: Identifiable, Decodable {
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
}

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
}
