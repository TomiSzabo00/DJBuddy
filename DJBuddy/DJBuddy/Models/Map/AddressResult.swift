//
//  AddressResult.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation

struct AddressResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String

    static var PreviewData: AddressResult {
        AddressResult(title: "Place name", subtitle: "Road name 123, Hungary")
    }
}
