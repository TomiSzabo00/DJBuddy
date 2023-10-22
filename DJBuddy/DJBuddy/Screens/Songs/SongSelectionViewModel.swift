//
//  SongSelectionViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 22/10/2023.
//

import Foundation
import MusicKit

struct MyGenresResponse: Decodable {
    let data: [Genre]
}

final class SongSelectionViewModel: ObservableObject {
    @Published var searchableText = ""
    @Published var searchResults: [SongData] = []
    @Published var isSearching = false
    private var searchTask: Task<Void, Never>? = nil

    func searchSong(_ text: String, theme: SongTheme?) {
        searchTask?.cancel()
        isSearching = true
        searchTask = Task { [weak self] in
            do {
                let request = MusicKit.MusicCatalogSearchRequest(term: text, types: [Song.self])
                let response = try await request.response()
                DispatchQueue.main.async { [weak self] in
                    self?.searchResults = response.songs
                        .filter { song in
                            if let theme {
                                guard let songTheme = song.genreNames.first,
                                      songTheme == theme.displayName else { return false }
                            }
                            return true
                        }
                        .map { song in
                            SongData(song: song)
                        }
                    self?.isSearching = false
                }
            } catch {
                print("Error searching for music: \(error.localizedDescription)")
            }
        }
    }

    // This is for testing purposes only
    func getAllGenres() {
        Task {
            do {
                let auth = await MusicAuthorization.request()
                if auth == .authorized {
                    let countryCode = try await MusicDataRequest.currentCountryCode
                    let url = URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/genres")!

                    let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
                    let dataResponse = try await dataRequest.response()
                    let decoder = JSONDecoder()

                    let genresResponse = try decoder.decode (MyGenresResponse.self, from: dataResponse.data)
                    for genre in genresResponse.data {
                        print(genre.name)
                    }
                }
            } catch {
                print("Error searching for genres: \(error.localizedDescription)")
            }
        }
    }
}
