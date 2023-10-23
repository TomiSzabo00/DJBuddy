//
//  CreateEventViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

final class CreateEventViewModel: ObservableObject {
    @Published var eventName = ""
    @Published var selectedAddress: AddressResult? = nil
    @Published var dateOfEvent: Date = .distantPast
    @Published var isLoading = false

    var currentAddress: String? {
        guard let selectedAddress else { return nil }
        return selectedAddress.title
    }

    var displayDate: String? {
        guard dateOfEvent != .distantPast else { return nil }
        return dateOfEvent.formatted(.dateTime.year().month().day())
    }

    func createEvent(by user: UserData, completion: @escaping (Result<EventData, Never>) -> Void) {
        guard let selectedAddress else {
            // TODO: address error
            return
        }

        guard dateOfEvent != .distantPast else {
            // TODO: date error
            return
        }

        isLoading = true

        let newEvent = EventData(name: eventName,
                                 dj: user,
                                 location: selectedAddress,
                                 date: dateOfEvent)

        // TODO: send event to BE
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            completion(.success(newEvent))
            self?.isLoading = false
        }
    }
}
