//
//  EventDetailsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import Foundation

final class EventDetailsViewModel: ObservableObject {
    @Published var isJoined = false
    @Published var isLoading = false
    @Published var error: Error? = nil
    @Published var numberOfJoined: Int = 0
    @Published var isDJLiked: Bool? = false

    func join(event: EventData, user: UserData) {
        isLoading = true

        API.joinEvent(event, user: user) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self?.isJoined = true
                    self?.numberOfJoined += 1
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func leave(event: EventData, user: UserData) {
        isLoading = true

        API.leaveEvent(event, user: user) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self?.isJoined = false
                    self?.numberOfJoined -= 1
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    func getNumberOfJoined(to event: EventData) {
        isLoading = true

        API.getnumberOfJoined(to: event) { [weak self] result in
            self?.isLoading = false
            switch result {
            case let .success(num):
                DispatchQueue.main.async {
                    self?.numberOfJoined = num
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }

    @MainActor
    func getLikeStatus(on dj: UserData, by user: UserData) async throws {
        isDJLiked = try await API.isDJLikedByUser(dj: dj, user: user)
    }

    @MainActor
    func toggleLike(on dj: UserData, by user: UserData) async throws {
        guard let isDJLiked else { return }

        do {
            if isDJLiked {
                try await API.unlike(dj: dj, by: user)
            } else {
                try await API.like(dj: dj, by: user)
            }
            self.isDJLiked = !isDJLiked
        } catch {
            throw error
        }
    }
}
