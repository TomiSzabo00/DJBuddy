//
//  PastEventsViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 05/03/2024.
//

import Foundation

final class PastEventsViewModel: ObservableObject {
    @Published private(set) var pastEvents: [EventData] = []

    @MainActor
    func getPastEvents() async throws {
        do {
            let events = try await API.getEvents()
            pastEvents = events.filter { $0.isInThePast }
        } catch {
            throw error
        }
    }
}
