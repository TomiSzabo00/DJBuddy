//
//  EventDetailsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import Foundation

final class EventDetailsViewModel: ObservableObject {
    @Published var isJoined = false
    @Published var numberOfJoined: Int = 0
    @Published var isDJLiked: Bool? = false

    @MainActor
    func join(event: EventData, user: UserData) async throws {
        do {
            try await API.joinEvent(event, user: user)
            isJoined = true
            numberOfJoined += 1
        } catch {
            throw error
        }
    }

    @MainActor
    func leave(event: EventData, user: UserData) async throws {
        do {
            try await API.leaveEvent(event, user: user)
            isJoined = false
            numberOfJoined -= 1
        } catch {
            throw error
        }
    }

    @MainActor
    func getNumberOfJoined(to event: EventData) async throws {
        numberOfJoined = try await API.getnumberOfJoined(to: event)
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
