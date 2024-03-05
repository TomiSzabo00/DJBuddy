//
//  PastEventsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/03/2024.
//

import Foundation

final class PastEventsViewModel: ObservableObject {
    @Published private(set) var pastEvents: [EventData] = []
    @Published var isLoading = false
    @Published var error: Error? = nil

    func getPastEvents(for user: UserData) {
        isLoading = true

        API.getEvents(from: user) { [weak self] result in
            self?.isLoading = false

            switch result {
            case .success(let allEvents):
                let pastEvents = allEvents.filter { $0.isInThePast }
                DispatchQueue.main.async {
                    self?.pastEvents = pastEvents
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self?.error = failure
                }
            }
        }
    }
}
