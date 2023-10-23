//
//  AddressResult.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation
import MapKit

struct AddressResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(title: String, subtitle: String, latitude: Double = 0, longitude: Double = 0) {
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
    }

    init(address: AddressResult, latitude: Double, longitude: Double) {
        self.title = address.title
        self.subtitle = address.subtitle
        self.latitude = latitude
        self.longitude = longitude
    }

    static var PreviewData: AddressResult {
        AddressResult(title: "Place name", subtitle: "Road name 123, Hungary")
    }
}
