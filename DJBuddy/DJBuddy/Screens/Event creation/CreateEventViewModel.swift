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
    @Published var formError: Error? = nil

    var currentAddress: String? {
        guard let selectedAddress else { return nil }
        return selectedAddress.title
    }

    var displayDate: String? {
        guard dateOfEvent != .distantPast else { return nil }
        return dateOfEvent.formatted(.dateTime.year().month().day())
    }

    func createEvent(by user: UserData, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let selectedAddress else {
            formError = FormError.addressMissing
            return
        }

        guard dateOfEvent != .distantPast else {
            formError = FormError.dateMissing
            return
        }

        isLoading = true

        let newEvent = EventData(name: eventName,
                                 dj: user,
                                 location: selectedAddress,
                                 date: dateOfEvent)

        API.createEvent(newEvent) { [weak self] result in
            self?.isLoading = false
            completion(result)
        }
    }
}
