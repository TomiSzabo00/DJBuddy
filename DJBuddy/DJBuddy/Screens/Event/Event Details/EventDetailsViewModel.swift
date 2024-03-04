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

    func join(event: EventData, user: UserData) {
        isLoading = true

        API.joinEvent(event, user: user) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self?.isJoined = true
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
}
