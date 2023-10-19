//
//  CreateEventViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

final class CreateEventViewModel: ObservableObject {
    @Published var selectedAddress: AddressResult? = nil
    @Published var dateOfEvent: Date = .distantPast

    var currentAddress: String? {
        guard let selectedAddress else { return nil }
        return selectedAddress.title
    }

    var displayDate: String? {
        guard dateOfEvent != .distantPast else { return nil }
        return dateOfEvent.formatted(.dateTime.year().month().day())
    }
}
